import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/finance.dart';
import '../../domain/entities/people.dart';
import '../../domain/entities/reports.dart';
import '../../domain/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/finance_services.dart';
import '../../domain/services/report_builder.dart';
import '../local/cache_store.dart';
import '../reports/report_export.dart';
import '../sms/bank_sms_parser.dart';

class DemoStore {
  DemoStore(this.cache);

  final CacheStore cache;
  final _uuid = const Uuid();
  final _calc = const InstallmentCalculator();
  final _fees = const FeeCalculator();

  UserProfile? currentUser;
  String? pendingPhone;
  final funds = <String, Fund>{};
  final members = <String, List<FundMember>>{};
  final transactions = <String, List<MoneyTransaction>>{};
  final loans = <String, List<Loan>>{};
  final installments = <String, List<Installment>>{};
  final draws = <String, List<FundDraw>>{};
  final invoices = <String, List<ServiceInvoice>>{};
  final users = <String, UserProfile>{};

  final authController = StreamController<UserProfile?>.broadcast();
  final fundControllers = <String, StreamController<Fund?>>{};
  final memberControllers = <String, StreamController<List<FundMember>>>{};
  final txControllers = <String, StreamController<List<MoneyTransaction>>>{};
  final loanControllers = <String, StreamController<List<Loan>>>{};
  final instControllers = <String, StreamController<List<Installment>>>{};
  final drawControllers = <String, StreamController<List<FundDraw>>>{};
  final invoiceControllers = <String, StreamController<List<ServiceInvoice>>>{};

  Future<void> load() async {
    final raw = cache.readJson('demo_store');
    if (raw == null) {
      _seed();
      await persist();
    } else {
      _hydrate(raw);
    }
  }

  Future<void> persist() async {
    await cache.writeJson('demo_store', {
      'currentUserId': currentUser?.id,
      'users': users.values.map((e) => e.toMap()).toList(),
      'funds': funds.values.map((e) => e.toMap()).toList(),
      'members': members.map((k, v) => MapEntry(k, v.map((e) => e.toMap()).toList())),
      'transactions': transactions.map((k, v) => MapEntry(k, v.map((e) => e.toMap()).toList())),
      'loans': loans.map((k, v) => MapEntry(k, v.map((e) => e.toMap()).toList())),
      'installments': installments.map((k, v) => MapEntry(k, v.map((e) => e.toMap()).toList())),
      'draws': draws.map((k, v) => MapEntry(k, v.map((e) => e.toMap()).toList())),
      'invoices': invoices.map((k, v) => MapEntry(k, v.map((e) => e.toMap()).toList())),
    });
  }

  void _hydrate(Map<String, dynamic> raw) {
    for (final u in (raw['users'] as List).cast<Map>()) {
      final p = UserProfile.fromMap(Map<String, dynamic>.from(u));
      users[p.id] = p;
    }
    for (final f in (raw['funds'] as List).cast<Map>()) {
      final fund = Fund.fromMap(Map<String, dynamic>.from(f));
      funds[fund.id] = fund;
    }
    _readList(raw['members'], members, FundMember.fromMap);
    _readList(raw['transactions'], transactions, MoneyTransaction.fromMap);
    _readList(raw['loans'], loans, Loan.fromMap);
    _readList(raw['installments'], installments, Installment.fromMap);
    _readList(raw['draws'], draws, FundDraw.fromMap);
    _readList(raw['invoices'], invoices, ServiceInvoice.fromMap);
    final id = raw['currentUserId'] as String?;
    currentUser = id == null ? null : users[id];
  }

  void _readList<T>(
    dynamic raw,
    Map<String, List<T>> target,
    T Function(Map<String, dynamic>) parse,
  ) {
    final map = Map<String, dynamic>.from(raw as Map);
    for (final e in map.entries) {
      target[e.key] = (e.value as List)
          .map((x) => parse(Map<String, dynamic>.from(x as Map)))
          .toList();
    }
  }

  void _seed() {
    final now = DateTime.now();
    const adminId = 'user-admin';
    const memberId = 'user-member';
    const fundId = 'fund-polad';
    users[adminId] = UserProfile(
      id: adminId,
      phone: AppConstants.demoAdminPhone,
      displayName: 'طهمورث پوردهقان',
      createdAt: now.subtract(const Duration(days: 200)),
      fundIds: const [fundId],
      activeFundId: fundId,
    );
    users[memberId] = UserProfile(
      id: memberId,
      phone: AppConstants.demoMemberPhone,
      displayName: 'مریم رضایی',
      createdAt: now.subtract(const Duration(days: 180)),
      fundIds: const [fundId],
      activeFundId: fundId,
    );
    funds[fundId] = Fund(
      id: fundId,
      name: 'صندوق خانوادگی پولاد',
      inviteCode: 'POLAD1',
      adminId: adminId,
      shareAmount: AppConstants.defaultShareToman,
      paymentPeriodDays: 30,
      serviceFeeRate: 0.005,
      loanAdminFeeRate: 0.02,
      createdAt: now.subtract(const Duration(days: 200)),
      tier: SubscriptionTier.premium,
      charterText: 'هر عضو ماهانه یک سهم می‌پردازد. وام پس از تأیید مدیر و بدون ربا پرداخت می‌شود. کارمزد خدمات نرم‌افزاری فقط از مدیر دریافت می‌گردد.',
      bankIban: 'IR120120000000000000000001',
      bankAccount: '1234567890',
      isCharity: false,
      memberCount: 5,
      balance: 185000000,
    );
    members[fundId] = [
      FundMember(userId: adminId, fundId: fundId, role: UserRole.admin, displayName: 'طهمورث پوردهقان', phone: AppConstants.demoAdminPhone, joinedAt: now.subtract(const Duration(days: 200)), shareBalance: 40000000, debt: 0, credit: 0),
      FundMember(userId: memberId, fundId: fundId, role: UserRole.member, displayName: 'مریم رضایی', phone: AppConstants.demoMemberPhone, joinedAt: now.subtract(const Duration(days: 180)), shareBalance: 25000000, debt: 10200000, credit: 0),
      FundMember(userId: 'user-3', fundId: fundId, role: UserRole.member, displayName: 'حسین محمدی', phone: '09123333333', joinedAt: now.subtract(const Duration(days: 150)), shareBalance: 30000000, debt: 0, credit: 5000000),
      FundMember(userId: 'user-4', fundId: fundId, role: UserRole.member, displayName: 'زهرا کاظمی', phone: '09124444444', joinedAt: now.subtract(const Duration(days: 120)), shareBalance: 20000000, debt: 5100000, credit: 0),
      FundMember(userId: 'user-5', fundId: fundId, role: UserRole.member, displayName: 'علی نوری', phone: '09125555555', joinedAt: now.subtract(const Duration(days: 90)), shareBalance: 15000000, debt: 0, credit: 0),
    ];
    transactions[fundId] = [
      MoneyTransaction(
        id: 'tx-1',
        fundId: fundId,
        memberId: memberId,
        memberName: 'مریم رضایی',
        type: TransactionType.sharePayment,
        amount: 5000000,
        status: TransactionStatus.pending,
        occurredAt: now.subtract(const Duration(days: 1)),
        submittedAt: now.subtract(const Duration(hours: 5)),
        trackingCode: '1403123456',
      ),
      MoneyTransaction(
        id: 'tx-2',
        fundId: fundId,
        memberId: 'user-4',
        memberName: 'زهرا کاظمی',
        type: TransactionType.installmentPayment,
        amount: 5100000,
        status: TransactionStatus.pending,
        occurredAt: now.subtract(const Duration(days: 2)),
        submittedAt: now.subtract(const Duration(hours: 20)),
        trackingCode: '99887766',
        relatedInstallmentId: 'inst-z-1',
      ),
      MoneyTransaction(
        id: 'tx-3',
        fundId: fundId,
        memberId: memberId,
        memberName: 'مریم رضایی',
        type: TransactionType.sharePayment,
        amount: 5000000,
        status: TransactionStatus.approved,
        occurredAt: now.subtract(const Duration(days: 32)),
        submittedAt: now.subtract(const Duration(days: 32)),
        trackingCode: '11122233',
      ),
    ];
    const loanId = 'loan-maryam';
    loans[fundId] = [
      Loan(
        id: loanId,
        fundId: fundId,
        memberId: memberId,
        memberName: 'مریم رضایی',
        amount: 50000000,
        termMonths: 10,
        reason: 'تعمیر خانه',
        status: LoanStatus.active,
        adminFeeRate: 0.02,
        requestedAt: now.subtract(const Duration(days: 70)),
        decidedAt: now.subtract(const Duration(days: 68)),
        decidedBy: adminId,
      ),
      Loan(
        id: 'loan-req',
        fundId: fundId,
        memberId: 'user-5',
        memberName: 'علی نوری',
        amount: 20000000,
        termMonths: 6,
        reason: 'هزینه درمان',
        status: LoanStatus.requested,
        adminFeeRate: 0.02,
        requestedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
    final plan = _calc.plan(principal: 50000000, termMonths: 10, start: now.subtract(const Duration(days: 68)));
    installments[fundId] = [
      for (var i = 0; i < plan.items.length; i++)
        Installment(
          id: 'inst-m-$i',
          loanId: loanId,
          fundId: fundId,
          memberId: memberId,
          sequence: plan.items[i].sequence,
          amount: plan.items[i].amount,
          dueDate: plan.items[i].dueDate,
          status: i < 2
              ? InstallmentStatus.paid
              : _calc.statusOf(plan.items[i].dueDate),
          principalPart: plan.items[i].principalPart,
          feePart: plan.items[i].feePart,
        ),
      Installment(
        id: 'inst-z-1',
        loanId: 'loan-zahra',
        fundId: fundId,
        memberId: 'user-4',
        sequence: 1,
        amount: 5100000,
        dueDate: now.subtract(const Duration(days: 4)),
        status: InstallmentStatus.overdue,
      ),
    ];
    draws[fundId] = [
      FundDraw(
        id: 'draw-1',
        fundId: fundId,
        title: 'قرعه‌کشی پاییز',
        periodStart: now.subtract(const Duration(days: 20)),
        periodEnd: now.add(const Duration(days: 10)),
        status: DrawStatus.ready,
        mode: DrawSelectionMode.random,
        prizeAmount: 10000000,
        eligibleMemberIds: members[fundId]!.map((m) => m.userId).toList(),
      ),
    ];
    invoices[fundId] = [
      ServiceInvoice(
        id: 'inv-1',
        fundId: fundId,
        adminId: adminId,
        year: now.year,
        month: now.month,
        transactionVolume: 55000000,
        feeAmount: _fees.softwareServiceFee(55000000, 0.005),
        status: InvoiceStatus.accruing,
        rate: 0.005,
      ),
    ];
  }

  StreamController<T> _ctrl<T>(Map<String, StreamController<T>> map, String key) {
    return map.putIfAbsent(key, StreamController<T>.broadcast);
  }

  void emitFund(String id) {
    fundControllers[id]?.add(funds[id]);
    memberControllers[id]?.add(List.of(members[id] ?? const []));
    txControllers[id]?.add(List.of(transactions[id] ?? const []));
    loanControllers[id]?.add(List.of(loans[id] ?? const []));
    instControllers[id]?.add(List.of(installments[id] ?? const []));
    drawControllers[id]?.add(List.of(draws[id] ?? const []));
    invoiceControllers[id]?.add(List.of(invoices[id] ?? const []));
  }

  String get requireFundId {
    final id = currentUser?.activeFundId;
    if (id == null) throw const AppFailure('صندوق فعالی انتخاب نشده');
    return id;
  }

  FundMember? me(String fundId) {
    final uid = currentUser?.id;
    if (uid == null) return null;
    return (members[fundId] ?? const []).where((m) => m.userId == uid).firstOrNull;
  }

  bool isAdmin(String fundId) => me(fundId)?.isAdmin ?? false;

  String newId() => _uuid.v4();
}

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this.store);
  final DemoStore store;

  @override
  UserProfile? get currentUser => store.currentUser;

  @override
  Stream<UserProfile?> authState() async* {
    yield store.currentUser;
    yield* store.authController.stream;
  }

  @override
  Future<Result<void>> sendOtp(String phone) async {
    store.pendingPhone = phone;
    return const Ok(null);
  }

  @override
  Future<Result<UserProfile>> verifyOtp({
    required String phone,
    required String smsCode,
    String? displayName,
  }) async {
    if (smsCode != AppConstants.demoOtp) {
      return const Err('کد تأیید نادرست است. در حالت آزمایشی کد ۱۲۳۴۵۶ است.');
    }
    final existing = store.users.values.where((u) => u.phone == phone).firstOrNull;
    if (existing != null) {
      store.currentUser = existing;
      store.authController.add(existing);
      await store.persist();
      return Ok(existing);
    }
    final id = store.newId();
    final user = UserProfile(
      id: id,
      phone: phone,
      displayName: (displayName == null || displayName.trim().isEmpty) ? 'کاربر جدید' : displayName.trim(),
      createdAt: DateTime.now(),
    );
    store.users[id] = user;
    store.currentUser = user;
    store.authController.add(user);
    await store.persist();
    return Ok(user);
  }

  @override
  Future<Result<void>> updateProfile({required String displayName, String? avatarUrl}) async {
    final user = store.currentUser;
    if (user == null) return const Err('وارد نشده‌اید');
    final next = user.copyWith(displayName: displayName, avatarUrl: avatarUrl ?? user.avatarUrl);
    store.users[user.id] = next;
    store.currentUser = next;
    store.authController.add(next);
    await store.persist();
    return const Ok(null);
  }

  @override
  Future<void> signOut() async {
    store.currentUser = null;
    store.authController.add(null);
    await store.persist();
  }
}

class DemoFundRepository implements FundRepository {
  DemoFundRepository(this.store);
  final DemoStore store;

  @override
  Stream<Fund?> watchFund(String fundId) async* {
    yield store.funds[fundId];
    yield* store._ctrl(store.fundControllers, fundId).stream;
  }

  @override
  Stream<List<FundMember>> watchMembers(String fundId) async* {
    yield List<FundMember>.from(store.members[fundId] ?? const []);
    yield* store._ctrl(store.memberControllers, fundId).stream;
  }

  @override
  Future<Result<Fund>> createFund(CreateFundInput input) async {
    final user = store.currentUser;
    if (user == null) return const Err('وارد نشده‌اید');
    final ownedFunds = store.funds.values.where((f) => f.adminId == user.id).toList();
    final premium = ownedFunds.any((f) => f.isPremium);
    if (!const SubscriptionPolicy().canCreateAnotherFund(premium: premium, ownedFunds: ownedFunds.length)) {
      return const Err('پلن رایگان فقط یک صندوق دارد. برای صندوق بیشتر، پریمیوم را فعال کنید.');
    }
    if (input.serviceFeeRate < AppConstants.minServiceFeeRate ||
        input.serviceFeeRate > AppConstants.maxServiceFeeRate) {
      return const Err('نرخ هزینه خدمات باید بین ۰٫۵٪ تا ۱٪ باشد');
    }
    final id = store.newId();
    final fund = Fund(
      id: id,
      name: input.name,
      inviteCode: InviteCode.generate(),
      adminId: user.id,
      shareAmount: input.shareAmount,
      paymentPeriodDays: input.paymentPeriodDays,
      serviceFeeRate: input.serviceFeeRate,
      loanAdminFeeRate: AppConstants.loanAdminFeeRate,
      createdAt: DateTime.now(),
      tier: SubscriptionTier.free,
      charterText: input.charterText,
      bankIban: input.bankIban,
      bankAccount: input.bankAccount,
      isCharity: input.isCharity,
      memberCount: 1,
      balance: 0,
    );
    store.funds[id] = fund;
    store.members[id] = [
      FundMember(
        userId: user.id,
        fundId: id,
        role: UserRole.admin,
        displayName: user.displayName,
        phone: user.phone,
        joinedAt: DateTime.now(),
      ),
    ];
    store.transactions[id] = [];
    store.loans[id] = [];
    store.installments[id] = [];
    store.draws[id] = [];
    store.invoices[id] = [];
    final next = user.copyWith(fundIds: [...user.fundIds, id], activeFundId: id);
    store.users[user.id] = next;
    store.currentUser = next;
    store.authController.add(next);
    store.emitFund(id);
    await store.persist();
    return Ok(fund);
  }

  @override
  Future<Result<Fund>> joinByInvite(String code) async {
    final user = store.currentUser;
    if (user == null) return const Err('وارد نشده‌اید');
    final normalized = InviteCode.normalize(code);
    final fund = store.funds.values.where((f) => f.inviteCode == normalized).firstOrNull;
    if (fund == null) return const Err('کد دعوت نادرست است');
    final list = store.members[fund.id] ?? [];
    if (list.any((m) => m.userId == user.id)) {
      final next = user.copyWith(activeFundId: fund.id);
      store.currentUser = next;
      store.users[user.id] = next;
      store.authController.add(next);
      await store.persist();
      return Ok(fund);
    }
    if (!fund.isPremium && list.length >= fund.memberLimit) {
      return const Err('ظرفیت نسخه رایگان تکمیل است. مدیر باید اشتراک پریمیوم تهیه کند.');
    }
    list.add(FundMember(
      userId: user.id,
      fundId: fund.id,
      role: UserRole.member,
      displayName: user.displayName,
      phone: user.phone,
      joinedAt: DateTime.now(),
    ));
    store.members[fund.id] = list;
    store.funds[fund.id] = fund.copyWith(memberCount: list.length);
    final next = user.copyWith(fundIds: [...user.fundIds, fund.id], activeFundId: fund.id);
    store.users[user.id] = next;
    store.currentUser = next;
    store.authController.add(next);
    store.emitFund(fund.id);
    await store.persist();
    return Ok(fund);
  }

  @override
  Future<Result<void>> updateFund(Fund fund) async {
    if (!store.isAdmin(fund.id)) return const Err('فقط مدیر می‌تواند تنظیمات را تغییر دهد');
    store.funds[fund.id] = fund;
    store.emitFund(fund.id);
    await store.persist();
    return const Ok(null);
  }

  @override
  Future<Result<void>> removeMember(String fundId, String userId) async {
    if (!store.isAdmin(fundId)) return const Err('فقط مدیر');
    if (userId == store.currentUser?.id) return const Err('مدیر نمی‌تواند خودش را حذف کند');
    store.members[fundId] = (store.members[fundId] ?? []).where((m) => m.userId != userId).toList();
    store.funds[fundId] = store.funds[fundId]!.copyWith(memberCount: store.members[fundId]!.length);
    store.emitFund(fundId);
    await store.persist();
    return const Ok(null);
  }

  @override
  Future<Result<void>> changeRole(String fundId, String userId, UserRole role) async {
    if (!store.isAdmin(fundId)) return const Err('فقط مدیر');
    store.members[fundId] = (store.members[fundId] ?? [])
        .map((m) => m.userId == userId ? m.copyWith(role: role) : m)
        .toList();
    store.emitFund(fundId);
    await store.persist();
    return const Ok(null);
  }

  @override
  Future<List<Fund>> myFunds() async {
    final ids = store.currentUser?.fundIds ?? const [];
    return ids.map((id) => store.funds[id]).whereType<Fund>().toList();
  }

  @override
  Future<Result<void>> setActiveFund(String fundId) async {
    final user = store.currentUser;
    if (user == null) return const Err('وارد نشده‌اید');
    final next = user.copyWith(activeFundId: fundId);
    store.currentUser = next;
    store.users[user.id] = next;
    store.authController.add(next);
    await store.persist();
    return const Ok(null);
  }

  @override
  Future<String> inviteLink(Fund fund) async =>
      'https://polad.app/join?code=${fund.inviteCode}';
}

class DemoTransactionRepository implements TransactionRepository {
  DemoTransactionRepository(this.store);
  final DemoStore store;
  final _fees = const FeeCalculator();

  @override
  Stream<List<MoneyTransaction>> watchForFund(String fundId) async* {
    yield List<MoneyTransaction>.from(store.transactions[fundId] ?? const []);
    yield* store._ctrl(store.txControllers, fundId).stream;
  }

  @override
  Stream<List<MoneyTransaction>> watchForMember(String fundId, String userId) {
    return watchForFund(fundId).map((list) => list.where((t) => t.memberId == userId).toList());
  }

  @override
  Future<Result<MoneyTransaction>> submit(SubmitPaymentInput input) async {
    final user = store.currentUser;
    if (user == null) return const Err('وارد نشده‌اید');
    final fundId = user.activeFundId;
    if (fundId == null) return const Err('صندوق فعالی ندارید');
    if (input.source == PaymentSource.smsMatch && !store.isAdmin(fundId)) {
      return const Err('فقط مدیر می‌تواند پیشنهاد پیامک ثبت کند');
    }
    // پیشنهاد پیامک و لینک بانکیما همیشه pending می‌مانند؛ تأیید خودکار نداریم.
    final tx = MoneyTransaction(
      id: store.newId(),
      fundId: fundId,
      memberId: input.memberId ?? user.id,
      memberName: input.memberName ?? user.displayName,
      type: input.type,
      amount: input.amount,
      status: TransactionStatus.pending,
      occurredAt: input.occurredAt,
      submittedAt: DateTime.now(),
      trackingCode: input.trackingCode,
      receiptUrl: input.receiptPath,
      relatedInstallmentId: input.relatedInstallmentId,
      relatedLoanId: input.relatedLoanId,
      source: input.source,
      reviewNote: input.note,
    );
    store.transactions[fundId] = [...store.transactions[fundId] ?? const [], tx];
    store.emitFund(fundId);
    await store.persist();
    return Ok(tx);
  }

  @override
  Future<Result<void>> approve(String transactionId, {String? note}) async {
    final fundId = store.currentUser?.activeFundId;
    if (fundId == null || !store.isAdmin(fundId)) return const Err('فقط مدیر می‌تواند تأیید کند');
    final list = store.transactions[fundId] ?? [];
    final idx = list.indexWhere((t) => t.id == transactionId);
    if (idx < 0) return const Err('تراکنش پیدا نشد');
    final tx = list[idx];
    if (tx.status != TransactionStatus.pending) return const Err('این تراکنش قابل تأیید نیست');
    list[idx] = tx.copyWith(status: TransactionStatus.approved, reviewerId: store.currentUser!.id, reviewNote: note);
    store.transactions[fundId] = list;
    final fund = store.funds[fundId]!;
    store.funds[fundId] = fund.copyWith(balance: fund.balance + tx.amount);
    store.members[fundId] = (store.members[fundId] ?? []).map((m) {
      if (m.userId != tx.memberId) return m;
      if (tx.type == TransactionType.sharePayment) {
        return m.copyWith(shareBalance: m.shareBalance + tx.amount);
      }
      if (tx.type == TransactionType.installmentPayment) {
        return m.copyWith(debt: max(0, m.debt - tx.amount));
      }
      return m;
    }).toList();
    if (tx.relatedInstallmentId != null) {
      store.installments[fundId] = (store.installments[fundId] ?? [])
          .map((i) => i.id == tx.relatedInstallmentId
              ? i.copyWith(status: InstallmentStatus.paid, paidTransactionId: tx.id)
              : i)
          .toList();
    }
    _accrueFee(fund, tx.amount);
    store.emitFund(fundId);
    await store.persist();
    return const Ok(null);
  }

  void _accrueFee(Fund fund, int amount) {
    if (fund.isCharity) return;
    final now = DateTime.now();
    final list = store.invoices[fund.id] ?? [];
    final existing = list.where((i) => i.year == now.year && i.month == now.month && i.status == InvoiceStatus.accruing);
    final fee = _fees.softwareServiceFee(amount, fund.serviceFeeRate);
    if (existing.isEmpty) {
      list.add(ServiceInvoice(
        id: store.newId(),
        fundId: fund.id,
        adminId: fund.adminId,
        year: now.year,
        month: now.month,
        transactionVolume: amount,
        feeAmount: fee,
        status: InvoiceStatus.accruing,
        rate: fund.serviceFeeRate,
      ));
    } else {
      final inv = existing.first;
      list[list.indexOf(inv)] = ServiceInvoice(
        id: inv.id,
        fundId: inv.fundId,
        adminId: inv.adminId,
        year: inv.year,
        month: inv.month,
        transactionVolume: inv.transactionVolume + amount,
        feeAmount: inv.feeAmount + fee,
        status: inv.status,
        rate: inv.rate,
      );
    }
    store.invoices[fund.id] = list;
  }

  @override
  Future<Result<void>> reject(String transactionId, {required String note}) async {
    final fundId = store.currentUser?.activeFundId;
    if (fundId == null || !store.isAdmin(fundId)) return const Err('فقط مدیر');
    final list = store.transactions[fundId] ?? [];
    final idx = list.indexWhere((t) => t.id == transactionId);
    if (idx < 0) return const Err('تراکنش پیدا نشد');
    list[idx] = list[idx].copyWith(status: TransactionStatus.rejected, reviewerId: store.currentUser!.id, reviewNote: note);
    store.transactions[fundId] = list;
    store.emitFund(fundId);
    await store.persist();
    return const Ok(null);
  }
}

class DemoLoanRepository implements LoanRepository {
  DemoLoanRepository(this.store);
  final DemoStore store;
  final _calc = const InstallmentCalculator();
  final _elig = const LoanEligibility();

  @override
  Stream<List<Loan>> watchLoans(String fundId) async* {
    yield List<Loan>.from(store.loans[fundId] ?? const []);
    yield* store._ctrl(store.loanControllers, fundId).stream;
  }

  @override
  Stream<List<Installment>> watchInstallments(String fundId, {String? memberId}) async* {
    List<Installment> filter(List<Installment> list) =>
        memberId == null ? list : list.where((i) => i.memberId == memberId).toList();
    yield filter(store.installments[fundId] ?? const []);
    yield* store._ctrl(store.instControllers, fundId).stream.map(filter);
  }

  @override
  Future<Result<Loan>> requestLoan({required int amount, required int termMonths, required String reason}) async {
    final user = store.currentUser;
    final fundId = user?.activeFundId;
    if (user == null || fundId == null) return const Err('وارد نشده‌اید');
    final fund = store.funds[fundId]!;
    final member = store.me(fundId)!;
    final overdue = (store.installments[fundId] ?? []).where((i) => i.memberId == user.id && i.status == InstallmentStatus.overdue).length;
    final deny = _elig.denyReason(
      requested: amount,
      shareAmount: fund.shareAmount,
      memberShareBalance: member.shareBalance,
      overdueCount: overdue,
      fundBalance: fund.balance,
      isActiveMember: member.status == MemberStatus.active,
    );
    if (deny != null) return Err(deny);
    final loan = Loan(
      id: store.newId(),
      fundId: fundId,
      memberId: user.id,
      memberName: user.displayName,
      amount: amount,
      termMonths: termMonths,
      reason: reason,
      status: LoanStatus.requested,
      adminFeeRate: fund.loanAdminFeeRate,
      requestedAt: DateTime.now(),
    );
    store.loans[fundId] = [...store.loans[fundId] ?? const [], loan];
    store.emitFund(fundId);
    await store.persist();
    return Ok(loan);
  }

  @override
  Future<Result<void>> decide({required String loanId, required bool approve, String? note}) async {
    final fundId = store.currentUser?.activeFundId;
    if (fundId == null || !store.isAdmin(fundId)) return const Err('فقط مدیر');
    final list = store.loans[fundId] ?? [];
    final idx = list.indexWhere((l) => l.id == loanId);
    if (idx < 0) return const Err('وام پیدا نشد');
    final loan = list[idx];
    if (!approve) {
      list[idx] = loan.copyWith(status: LoanStatus.rejected, decidedAt: DateTime.now(), decidedBy: store.currentUser!.id, decisionNote: note);
      store.loans[fundId] = list;
      store.emitFund(fundId);
      await store.persist();
      return const Ok(null);
    }
    final fund = store.funds[fundId]!;
    if (fund.balance < loan.amount) return const Err('موجودی صندوق کافی نیست');
    list[idx] = loan.copyWith(status: LoanStatus.active, decidedAt: DateTime.now(), decidedBy: store.currentUser!.id, decisionNote: note);
    store.loans[fundId] = list;
    store.funds[fundId] = fund.copyWith(balance: fund.balance - loan.amount);
    final plan = _calc.plan(principal: loan.amount, termMonths: loan.termMonths, start: DateTime.now(), feeRate: loan.adminFeeRate, periodDays: fund.paymentPeriodDays);
    store.installments[fundId] = [
      ...store.installments[fundId] ?? const [],
      for (final item in plan.items)
        Installment(
          id: store.newId(),
          loanId: loan.id,
          fundId: fundId,
          memberId: loan.memberId,
          sequence: item.sequence,
          amount: item.amount,
          dueDate: item.dueDate,
          status: InstallmentStatus.upcoming,
          principalPart: item.principalPart,
          feePart: item.feePart,
        ),
    ];
    store.members[fundId] = (store.members[fundId] ?? [])
        .map((m) => m.userId == loan.memberId ? m.copyWith(debt: m.debt + plan.total) : m)
        .toList();
    store.emitFund(fundId);
    await store.persist();
    return const Ok(null);
  }
}

class DemoDrawRepository implements DrawRepository {
  DemoDrawRepository(this.store);
  final DemoStore store;
  final _selector = const DrawSelector();

  @override
  Stream<List<FundDraw>> watch(String fundId) async* {
    yield List.of(store.draws[fundId] ?? const []);
    yield* store._ctrl(store.drawControllers, fundId).stream;
  }

  @override
  Future<Result<FundDraw>> create({
    required String title,
    required DateTime start,
    required DateTime end,
    required int prizeAmount,
    required DrawSelectionMode mode,
  }) async {
    final fundId = store.currentUser?.activeFundId;
    if (fundId == null || !store.isAdmin(fundId)) return const Err('فقط مدیر');
    final draw = FundDraw(
      id: store.newId(),
      fundId: fundId,
      title: title,
      periodStart: start,
      periodEnd: end,
      status: DrawStatus.ready,
      mode: mode,
      prizeAmount: prizeAmount,
      eligibleMemberIds: (store.members[fundId] ?? []).map((m) => m.userId).toList(),
    );
    store.draws[fundId] = [...store.draws[fundId] ?? const [], draw];
    store.emitFund(fundId);
    await store.persist();
    return Ok(draw);
  }

  @override
  Future<Result<FundDraw>> run({required String drawId, String? manualWinnerId}) async {
    final fundId = store.currentUser?.activeFundId;
    if (fundId == null || !store.isAdmin(fundId)) return const Err('فقط مدیر');
    final list = store.draws[fundId] ?? [];
    final idx = list.indexWhere((d) => d.id == drawId);
    if (idx < 0) return const Err('قرعه پیدا نشد');
    final draw = list[idx];
    final winnerId = manualWinnerId ?? _selector.pickRandom(draw.eligibleMemberIds, Random());
    final winner = (store.members[fundId] ?? []).where((m) => m.userId == winnerId).firstOrNull;
    final next = draw.copyWith(status: DrawStatus.completed, winnerMemberId: winnerId, winnerName: winner?.displayName ?? 'نامشخص');
    list[idx] = next;
    store.draws[fundId] = list;
    store.emitFund(fundId);
    await store.persist();
    return Ok(next);
  }
}

class DemoBillingRepository implements BillingRepository {
  DemoBillingRepository(this.store);
  final DemoStore store;

  @override
  Stream<List<ServiceInvoice>> watch(String fundId) async* {
    yield List.of(store.invoices[fundId] ?? const []);
    yield* store._ctrl(store.invoiceControllers, fundId).stream;
  }

  @override
  Future<Result<void>> markPaid(String invoiceId) async {
    final fundId = store.currentUser?.activeFundId;
    if (fundId == null || !store.isAdmin(fundId)) return const Err('فقط مدیر');
    store.invoices[fundId] = (store.invoices[fundId] ?? []).map((i) {
      if (i.id != invoiceId) return i;
      return ServiceInvoice(
        id: i.id,
        fundId: i.fundId,
        adminId: i.adminId,
        year: i.year,
        month: i.month,
        transactionVolume: i.transactionVolume,
        feeAmount: i.feeAmount,
        status: InvoiceStatus.paid,
        rate: i.rate,
        note: i.note,
      );
    }).toList();
    store.emitFund(fundId);
    await store.persist();
    return const Ok(null);
  }
}

class DemoReportRepository implements ReportRepository {
  DemoReportRepository(this.store);
  final DemoStore store;
  final _builder = const ReportBuilder();
  final _export = const ReportExporter();

  @override
  Future<PoladReport> build(String fundId, {ReportFilter filter = const ReportFilter()}) async {
    final fund = store.funds[fundId];
    if (fund == null) {
      throw StateError('صندوق نیست');
    }
    return _builder.build(
      fund: fund,
      transactions: store.transactions[fundId] ?? const [],
      installments: store.installments[fundId] ?? const [],
      loans: store.loans[fundId] ?? const [],
      members: store.members[fundId] ?? const [],
      invoices: store.invoices[fundId] ?? const [],
      filter: filter,
    );
  }

  @override
  Future<Result<String>> exportExcel(String fundId, {ReportFilter filter = const ReportFilter(), bool share = true}) async {
    final fund = store.funds[fundId];
    if (fund == null) return const Err('صندوق نیست');
    final report = await build(fundId, filter: filter);
    return _export.excel(fund, report, share: share);
  }

  @override
  Future<Result<String>> exportPdf(String fundId, {ReportFilter filter = const ReportFilter(), bool share = true}) async {
    final fund = store.funds[fundId];
    if (fund == null) return const Err('صندوق نیست');
    final report = await build(fundId, filter: filter);
    return _export.pdf(fund, report, share: share);
  }
}

class MethodChannelSmsInbox implements SmsInbox {
  static const _channel = MethodChannel('ir.polad.polad/sms');
  final parser = BankSmsParser();

  @override
  Future<bool> requestPermission() async {
    try {
      final ok = await _channel.invokeMethod<bool>('requestPermission');
      return ok ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<List<BankSms>> readRecent({Duration window = const Duration(days: 7)}) async {
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('readInbox', {
        'sinceMs': DateTime.now().subtract(window).millisecondsSinceEpoch,
      });
      return (raw ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map((m) => parser.parse(
                m['sender'] as String? ?? '',
                m['body'] as String? ?? '',
                DateTime.fromMillisecondsSinceEpoch(m['date'] as int? ?? 0),
              ))
          .toList();
    } on MissingPluginException {
      return const [];
    }
  }
}

class DemoPaymentGateway implements PaymentGateway {
  @override
  Future<Result<String>> startSoftwareFeePayment({required String invoiceId, required int amountToman}) async {
    return const Ok('demo-order');
  }

  @override
  Future<Result<void>> verify(String orderId) async => const Ok(null);
}
