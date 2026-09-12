import 'dart:async';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/di/locator.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/entities/people.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';

class SessionState extends Equatable {
  const SessionState({
    this.booting = true,
    this.user,
    this.online = true,
  });

  final bool booting;
  final UserProfile? user;
  final bool online;

  bool get authenticated => user != null;
  bool get hasFund => user?.activeFundId != null && (user?.fundIds.isNotEmpty ?? false);
  bool get needsProfile => user?.needsProfile ?? false;

  SessionState copyWith({bool? booting, UserProfile? user, bool? online, bool clearUser = false}) {
    return SessionState(
      booting: booting ?? this.booting,
      user: clearUser ? null : (user ?? this.user),
      online: online ?? this.online,
    );
  }

  @override
  List<Object?> get props => [booting, user, online];
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({AuthRepository? auth})
      : _auth = auth ?? sl<AuthRepository>(),
        super(const SessionState()) {
    _subs.add(_auth.authState().listen((user) {
      emit(state.copyWith(booting: false, user: user, clearUser: user == null));
    }));
    _subs.add(Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      emit(state.copyWith(online: online));
    }));
  }

  final AuthRepository _auth;
  final _subs = <StreamSubscription>[];

  Future<void> signOut() => _auth.signOut();

  /// همگام‌سازی فوری پس از به‌روزرسانی پروفایل (وقتی استریم Auth دوباره شلیک نمی‌کند).
  void reload() => emit(state.copyWith(booting: false, user: _auth.currentUser));

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    return super.close();
  }
}

class HomeState extends Equatable {
  const HomeState({
    this.loading = true,
    this.fund,
    this.me,
    this.members = const [],
    this.transactions = const [],
    this.loans = const [],
    this.installments = const [],
    this.draws = const [],
    this.invoices = const [],
    this.message,
  });

  final bool loading;
  final Fund? fund;
  final FundMember? me;
  final List<FundMember> members;
  final List<MoneyTransaction> transactions;
  final List<Loan> loans;
  final List<Installment> installments;
  final List<FundDraw> draws;
  final List<ServiceInvoice> invoices;
  final String? message;

  bool get isAdmin => me?.isAdmin ?? false;
  List<MoneyTransaction> get pending =>
      transactions.where((t) => t.status == TransactionStatus.pending).toList();
  List<Installment> get myInstallments =>
      installments.where((i) => i.memberId == me?.userId).toList();
  List<Loan> get requestedLoans => loans.where((l) => l.status == LoanStatus.requested).toList();
  int get activeLoans => loans.where((l) => l.status == LoanStatus.active).length;
  int get overdueCount => installments.where((i) => i.status == InstallmentStatus.overdue).length;

  HomeState copyWith({
    bool? loading,
    Fund? fund,
    FundMember? me,
    List<FundMember>? members,
    List<MoneyTransaction>? transactions,
    List<Loan>? loans,
    List<Installment>? installments,
    List<FundDraw>? draws,
    List<ServiceInvoice>? invoices,
    String? message,
    bool clearMessage = false,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      fund: fund ?? this.fund,
      me: me ?? this.me,
      members: members ?? this.members,
      transactions: transactions ?? this.transactions,
      loans: loans ?? this.loans,
      installments: installments ?? this.installments,
      draws: draws ?? this.draws,
      invoices: invoices ?? this.invoices,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [loading, fund, me, members, transactions, loans, installments, draws, invoices, message];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.fundId,
    required this.userId,
    FundRepository? funds,
    TransactionRepository? txs,
    LoanRepository? loans,
    DrawRepository? draws,
    BillingRepository? billing,
  })  : _funds = funds ?? sl<FundRepository>(),
        _txs = txs ?? sl<TransactionRepository>(),
        _loans = loans ?? sl<LoanRepository>(),
        _draws = draws ?? sl<DrawRepository>(),
        _billing = billing ?? sl<BillingRepository>(),
        super(const HomeState()) {
    _sub = Rx.combineLatest6(
      _funds.watchFund(fundId),
      _funds.watchMembers(fundId),
      _txs.watchForFund(fundId),
      _loans.watchLoans(fundId),
      _loans.watchInstallments(fundId),
      _draws.watch(fundId),
      (Fund? fund, List<FundMember> members, List<MoneyTransaction> txs, List<Loan> loans, List<Installment> inst, List<FundDraw> draws) {
        return (
          fund: fund,
          members: members,
          txs: txs,
          loans: loans,
          inst: inst,
          draws: draws,
        );
      },
    ).listen((tuple) {
      emit(state.copyWith(
        loading: false,
        fund: tuple.fund,
        members: tuple.members,
        transactions: tuple.txs,
        loans: tuple.loans,
        installments: tuple.inst,
        draws: tuple.draws,
        me: tuple.members.where((m) => m.userId == userId).firstOrNull,
      ));
    });
    _billSub = _billing.watch(fundId).listen((inv) => emit(state.copyWith(invoices: inv)));
  }

  final String fundId;
  final String userId;
  final FundRepository _funds;
  final TransactionRepository _txs;
  final LoanRepository _loans;
  final DrawRepository _draws;
  final BillingRepository _billing;
  StreamSubscription? _sub;
  StreamSubscription? _billSub;

  Future<void> approveTx(String id) async {
    final r = await _txs.approve(id);
    r.when(ok: (_) => emit(state.copyWith(message: 'تراکنش تأیید شد', clearMessage: false)), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<void> rejectTx(String id, String note) async {
    final r = await _txs.reject(id, note: note);
    r.when(ok: (_) => emit(state.copyWith(message: 'تراکنش رد شد')), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<void> decideLoan(String id, bool approve, {String? note}) async {
    final r = await _loans.decide(loanId: id, approve: approve, note: note);
    r.when(ok: (_) => emit(state.copyWith(message: approve ? 'وام تأیید شد' : 'وام رد شد')), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<void> removeMember(String userId) async {
    final r = await _funds.removeMember(fundId, userId);
    r.when(ok: (_) => emit(state.copyWith(message: 'عضو حذف شد')), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<void> changeRole(String userId, UserRole role) async {
    final r = await _funds.changeRole(fundId, userId, role);
    r.when(ok: (_) => emit(state.copyWith(message: 'نقش به‌روز شد')), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<void> updateFund(Fund fund) async {
    final r = await _funds.updateFund(fund);
    r.when(ok: (_) => emit(state.copyWith(message: 'تنظیمات ذخیره شد')), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<String> inviteLink() async {
    final fund = state.fund;
    if (fund == null) return '';
    return _funds.inviteLink(fund);
  }

  Future<void> runDraw(String id, {String? winnerId}) async {
    final r = await sl<DrawRepository>().run(drawId: id, manualWinnerId: winnerId);
    r.when(ok: (d) => emit(state.copyWith(message: 'برنده: ${d.winnerName}')), err: (m) => emit(state.copyWith(message: m)));
  }

  Future<void> createDraw({required String title, required int prize}) async {
    final now = DateTime.now();
    final r = await sl<DrawRepository>().create(
      title: title,
      start: now,
      end: now.add(const Duration(days: 30)),
      prizeAmount: prize,
      mode: DrawSelectionMode.random,
    );
    r.when(ok: (_) => emit(state.copyWith(message: 'دوره قرعه‌کشی ساخته شد')), err: (m) => emit(state.copyWith(message: m)));
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _billSub?.cancel();
    return super.close();
  }
}
