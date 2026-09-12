import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/finance.dart';
import '../../domain/entities/people.dart';
import '../../domain/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/finance_services.dart';
import 'firebase_repos.dart';

Map<String, dynamic> _norm(String id, Map<String, dynamic> data) {
  final out = Map<String, dynamic>.from(data);
  out['id'] = out['id'] ?? id;
  for (final key in out.keys.toList()) {
    if (out[key] is Timestamp) out[key] = (out[key] as Timestamp).toDate().toIso8601String();
  }
  return out;
}

class FirebaseFundRepository implements FundRepository {
  FirebaseFundRepository(this._db, this._auth, this._fn);
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseCallable _fn;

  String get _uid => _auth.currentUser!.uid;

  @override
  Stream<Fund?> watchFund(String fundId) {
    return _db.collection(CollectionPaths.funds).doc(fundId).snapshots().map((d) {
      if (!d.exists) return null;
      return Fund.fromMap(_norm(d.id, d.data()!));
    });
  }

  @override
  Stream<List<FundMember>> watchMembers(String fundId) {
    return _db.collection(CollectionPaths.fundMembers(fundId)).snapshots().map(
          (s) => s.docs.map((d) => FundMember.fromMap(_norm(d.id, d.data()))).toList(),
        );
  }

  @override
  Future<Result<Fund>> createFund(CreateFundInput input) async {
    final res = await _fn.call('createFund', {
      'name': input.name,
      'shareAmount': input.shareAmount,
      'paymentPeriodDays': input.paymentPeriodDays,
      'serviceFeeRate': input.serviceFeeRate,
      'charterText': input.charterText,
      'bankIban': input.bankIban,
      'bankAccount': input.bankAccount,
      'isCharity': input.isCharity,
    });
    return res.when(ok: (m) => Ok(Fund.fromMap(m)), err: Err.new);
  }

  @override
  Future<Result<Fund>> joinByInvite(String code) async {
    final res = await _fn.call('joinFund', {'code': code});
    return res.when(ok: (m) => Ok(Fund.fromMap(m)), err: Err.new);
  }

  @override
  Future<Result<void>> updateFund(Fund fund) async {
    if (_auth.currentUser == null) return const Err('وارد نشده‌اید');
    await _db.collection(CollectionPaths.funds).doc(fund.id).update(fund.toMap());
    return const Ok(null);
  }

  @override
  Future<Result<void>> removeMember(String fundId, String userId) =>
      _fn.call('removeMember', {'fundId': fundId, 'userId': userId}).then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));

  @override
  Future<Result<void>> changeRole(String fundId, String userId, UserRole role) =>
      _fn.call('changeRole', {'fundId': fundId, 'userId': userId, 'role': role.name})
          .then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));

  @override
  Future<List<Fund>> myFunds() async {
    final user = await _db.collection(CollectionPaths.users).doc(_uid).get();
    final ids = (user.data()?['fundIds'] as List?)?.cast<String>() ?? const [];
    if (ids.isEmpty) return const [];
    final snaps = await Future.wait(ids.map((id) => _db.collection(CollectionPaths.funds).doc(id).get()));
    return snaps.where((s) => s.exists).map((s) => Fund.fromMap(_norm(s.id, s.data()!))).toList();
  }

  @override
  Future<Result<void>> setActiveFund(String fundId) async {
    await _db.collection(CollectionPaths.users).doc(_uid).update({'activeFundId': fundId});
    return const Ok(null);
  }

  @override
  Future<String> inviteLink(Fund fund) async => 'https://polad.app/join?code=${fund.inviteCode}';
}

class FirebaseTransactionRepository implements TransactionRepository {
  FirebaseTransactionRepository(this._db, this._auth, this._fn, this._storage);
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseCallable _fn;
  final FirebaseStorage _storage;

  @override
  Stream<List<MoneyTransaction>> watchForFund(String fundId) {
    return _db
        .collection(CollectionPaths.transactions)
        .where('fundId', isEqualTo: fundId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => MoneyTransaction.fromMap(_norm(d.id, d.data()))).toList());
  }

  @override
  Stream<List<MoneyTransaction>> watchForMember(String fundId, String userId) {
    return _db
        .collection(CollectionPaths.transactions)
        .where('fundId', isEqualTo: fundId)
        .where('memberId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => MoneyTransaction.fromMap(_norm(d.id, d.data()))).toList());
  }

  @override
  Future<Result<MoneyTransaction>> submit(SubmitPaymentInput input) async {
    String? url;
    if (input.receiptPath != null) {
      final ref = _storage.ref(
        'receipts/${_auth.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(File(input.receiptPath!));
      url = await ref.getDownloadURL();
    }
    final res = await _fn.call('submitPayment', {
      'amount': input.amount,
      'occurredAt': input.occurredAt.toIso8601String(),
      'trackingCode': input.trackingCode,
      'type': input.type.name,
      'receiptUrl': url,
      'relatedInstallmentId': input.relatedInstallmentId,
      'relatedLoanId': input.relatedLoanId,
    });
    return res.when(ok: (m) => Ok(MoneyTransaction.fromMap(m)), err: Err.new);
  }

  @override
  Future<Result<void>> approve(String transactionId, {String? note}) =>
      _fn.call('approveTransaction', {'transactionId': transactionId, 'note': note})
          .then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));

  @override
  Future<Result<void>> reject(String transactionId, {required String note}) =>
      _fn.call('rejectTransaction', {'transactionId': transactionId, 'note': note})
          .then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));
}

class FirebaseLoanRepository implements LoanRepository {
  FirebaseLoanRepository(this._db, this._fn);
  final FirebaseFirestore _db;
  final FirebaseCallable _fn;

  @override
  Stream<List<Loan>> watchLoans(String fundId) {
    return _db
        .collection(CollectionPaths.loans)
        .where('fundId', isEqualTo: fundId)
        .snapshots()
        .map((s) => s.docs.map((d) => Loan.fromMap(_norm(d.id, d.data()))).toList());
  }

  @override
  Stream<List<Installment>> watchInstallments(String fundId, {String? memberId}) {
    Query<Map<String, dynamic>> q = _db.collection(CollectionPaths.installments).where('fundId', isEqualTo: fundId);
    if (memberId != null) q = q.where('memberId', isEqualTo: memberId);
    return q.snapshots().map((s) => s.docs.map((d) => Installment.fromMap(_norm(d.id, d.data()))).toList());
  }

  @override
  Future<Result<Loan>> requestLoan({required int amount, required int termMonths, required String reason}) async {
    final res = await _fn.call('requestLoan', {'amount': amount, 'termMonths': termMonths, 'reason': reason});
    return res.when(ok: (m) => Ok(Loan.fromMap(m)), err: Err.new);
  }

  @override
  Future<Result<void>> decide({required String loanId, required bool approve, String? note}) =>
      _fn.call('decideLoan', {'loanId': loanId, 'approve': approve, 'note': note})
          .then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));
}

class FirebaseDrawRepository implements DrawRepository {
  FirebaseDrawRepository(this._db, this._fn);
  final FirebaseFirestore _db;
  final FirebaseCallable _fn;

  @override
  Stream<List<FundDraw>> watch(String fundId) {
    return _db
        .collection(CollectionPaths.draws)
        .where('fundId', isEqualTo: fundId)
        .snapshots()
        .map((s) => s.docs.map((d) => FundDraw.fromMap(_norm(d.id, d.data()))).toList());
  }

  @override
  Future<Result<FundDraw>> create({
    required String title,
    required DateTime start,
    required DateTime end,
    required int prizeAmount,
    required DrawSelectionMode mode,
  }) async {
    final res = await _fn.call('createDraw', {
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'prizeAmount': prizeAmount,
      'mode': mode.name,
    });
    return res.when(ok: (m) => Ok(FundDraw.fromMap(m)), err: Err.new);
  }

  @override
  Future<Result<FundDraw>> run({required String drawId, String? manualWinnerId}) async {
    final res = await _fn.call('runDraw', {'drawId': drawId, 'manualWinnerId': manualWinnerId});
    return res.when(ok: (m) => Ok(FundDraw.fromMap(m)), err: Err.new);
  }
}

class FirebaseBillingRepository implements BillingRepository {
  FirebaseBillingRepository(this._db, this._fn);
  final FirebaseFirestore _db;
  final FirebaseCallable _fn;

  @override
  Stream<List<ServiceInvoice>> watch(String fundId) {
    return _db
        .collection(CollectionPaths.invoices)
        .where('fundId', isEqualTo: fundId)
        .snapshots()
        .map((s) => s.docs.map((d) => ServiceInvoice.fromMap(_norm(d.id, d.data()))).toList());
  }

  @override
  Future<Result<void>> markPaid(String invoiceId) =>
      _fn.call('markInvoicePaid', {'invoiceId': invoiceId}).then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));
}

class FirebasePaymentGateway implements PaymentGateway {
  FirebasePaymentGateway(this._fn);
  final FirebaseCallable _fn;

  @override
  Future<Result<String>> startSoftwareFeePayment({required String invoiceId, required int amountToman}) async {
    final res = await _fn.call('startBankimaPayment', {'invoiceId': invoiceId, 'amountToman': amountToman});
    return res.when(ok: (m) => Ok(m['redirectUrl'] as String? ?? ''), err: Err.new);
  }

  @override
  Future<Result<void>> verify(String orderId) =>
      _fn.call('verifyBankimaPayment', {'orderId': orderId}).then((r) => r.when(ok: (_) => const Ok(null), err: Err.new));
}

class FirebaseReportRepository implements ReportRepository {
  FirebaseReportRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<FundReport> build(String fundId) async {
    final fund = await _db.collection(CollectionPaths.funds).doc(fundId).get();
    final txs = await _db.collection(CollectionPaths.transactions).where('fundId', isEqualTo: fundId).get();
    final inst = await _db.collection(CollectionPaths.installments).where('fundId', isEqualTo: fundId).get();
    final approved = txs.docs
        .map((d) => MoneyTransaction.fromMap(_norm(d.id, d.data())))
        .where((t) => t.status == TransactionStatus.approved);
    final overdue = inst.docs
        .map((d) => Installment.fromMap(_norm(d.id, d.data())))
        .where((i) => i.status == InstallmentStatus.overdue);
    final inSum = approved
        .where((t) => t.type != TransactionType.loanDisbursement && t.type != TransactionType.withdrawal)
        .fold<int>(0, (a, b) => a + b.amount);
    final outSum = approved
        .where((t) => t.type == TransactionType.loanDisbursement || t.type == TransactionType.withdrawal)
        .fold<int>(0, (a, b) => a + b.amount);
    return FundReport(
      balance: (fund.data()?['balance'] as int?) ?? 0,
      totalIn: inSum,
      totalOut: outSum,
      overdueCount: overdue.length,
      overdueAmount: overdue.fold(0, (a, b) => a + b.amount),
      points: const [],
      softwareFeeToAdmin: const FeeCalculator().accrue(
        approved.map((t) => t.amount),
        (fund.data()?['serviceFeeRate'] as num?)?.toDouble() ?? 0.005,
        charityZeroFee: fund.data()?['isCharity'] as bool? ?? false,
      ),
      serviceFeeRate: (fund.data()?['serviceFeeRate'] as num?)?.toDouble() ?? 0.005,
      charityZeroFee: fund.data()?['isCharity'] as bool? ?? false,
    );
  }

  @override
  Future<Result<String>> exportExcel(String fundId) async => const Err('خروجی اکسل از طریق سرور تولید می‌شود');

  @override
  Future<Result<String>> exportPdf(String fundId) async => const Err('خروجی PDF از طریق سرور تولید می‌شود');
}
