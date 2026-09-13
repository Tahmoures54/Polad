import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../data/payments/bankima_models.dart';
import '../../../data/payments/bankima_service.dart';
import '../../../data/sms/sms_parser_service.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/entities/people.dart';
import '../../../domain/enums.dart';

/// Cubit اسکن پیامک بانکی مدیر. هیچ‌گاه approve صدا نمی‌زند.
class SmsInboxCubit extends Cubit<SmsInboxState> {
  SmsInboxCubit({SmsParserService? service})
      : _service = service ?? sl<SmsParserService>(),
        super(const SmsInboxState());

  final SmsParserService _service;

  Future<void> scan({
    required bool isAdmin,
    required List<MoneyTransaction> existing,
    required List<FundMember> members,
  }) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.ingestAdminInbox(
      isAdmin: isAdmin,
      existing: existing,
      members: members,
    );
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (report) {
        assert(!report.autoApproved, 'تأیید خودکار پیامک ممنوع است');
        emit(state.copyWith(busy: false, report: report));
      },
    );
  }
}

class SmsInboxState extends Equatable {
  const SmsInboxState({this.busy = false, this.report, this.error});

  final bool busy;
  final SmsIngestReport? report;
  final String? error;

  List<SmsSuggestion> get items => report?.items ?? const [];

  SmsInboxState copyWith({
    bool? busy,
    SmsIngestReport? report,
    String? error,
    bool clearError = false,
  }) {
    return SmsInboxState(
      busy: busy ?? this.busy,
      report: report ?? this.report,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [busy, report, error];
}

/// ابزارهای بانکیما برای مدیر. استعلام موفق = پیشنهاد، نه تأیید.
class BankimaCubit extends Cubit<BankimaUiState> {
  BankimaCubit({BankimaService? service})
      : _service = service ?? sl<BankimaService>(),
        super(const BankimaUiState());

  final BankimaService _service;

  Future<void> loadBalance(String accountId) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.getBalance(accountId);
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (b) => emit(state.copyWith(busy: false, balance: b)),
    );
  }

  Future<void> verify(String receiptCode) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.verifyTransaction(receiptCode);
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (tx) => emit(state.copyWith(busy: false, verified: tx, message: 'استعلام شد — تأیید صندوق با مدیر است')),
    );
  }

  Future<void> statement(String accountId, DateTime from, DateTime to) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.getAccountStatement(accountId, DateRange(from: from, to: to));
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (s) => emit(state.copyWith(busy: false, statement: s)),
    );
  }

  Future<void> installments(String loanId) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.getInstallmentInfo(loanId);
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (i) => emit(state.copyWith(busy: false, installments: i)),
    );
  }

  Future<void> paymentLink(String memberId, int amountToman) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.createPaymentLink(memberId, amountToman);
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (l) => emit(state.copyWith(busy: false, paymentLink: l, message: 'لینک ساخته شد. پرداخت عضو را مدیر بعداً تأیید می‌کند.')),
    );
  }

  Future<void> sendTransfer({
    required BankTransferRail rail,
    required String iban,
    required int amountToman,
    required String description,
  }) async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _service.transfer(
      rail: rail,
      destinationIban: iban,
      amountToman: amountToman,
      description: description,
    );
    res.fold(
      (f) => emit(state.copyWith(busy: false, error: f.message)),
      (t) => emit(state.copyWith(busy: false, transfer: t, message: 'انتقال ${rail.fa} ثبت شد')),
    );
  }
}

class BankimaUiState extends Equatable {
  const BankimaUiState({
    this.busy = false,
    this.error,
    this.message,
    this.balance,
    this.verified,
    this.statement,
    this.installments,
    this.paymentLink,
    this.transfer,
  });

  final bool busy;
  final String? error;
  final String? message;
  final BankimaBalance? balance;
  final BankimaVerifiedTx? verified;
  final BankimaStatement? statement;
  final BankimaInstallmentInfo? installments;
  final BankimaPaymentLink? paymentLink;
  final BankimaTransferResult? transfer;

  BankimaUiState copyWith({
    bool? busy,
    String? error,
    String? message,
    BankimaBalance? balance,
    BankimaVerifiedTx? verified,
    BankimaStatement? statement,
    BankimaInstallmentInfo? installments,
    BankimaPaymentLink? paymentLink,
    BankimaTransferResult? transfer,
    bool clearError = false,
  }) {
    return BankimaUiState(
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      message: clearError ? null : (message ?? this.message),
      balance: balance ?? this.balance,
      verified: verified ?? this.verified,
      statement: statement ?? this.statement,
      installments: installments ?? this.installments,
      paymentLink: paymentLink ?? this.paymentLink,
      transfer: transfer ?? this.transfer,
    );
  }

  @override
  List<Object?> get props =>
      [busy, error, message, balance, verified, statement, installments, paymentLink, transfer];
}
