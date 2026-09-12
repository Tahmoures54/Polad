import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../core/network/guard.dart';
import '../../core/network/network_retry.dart';
import '../models/models.dart';

/// لایه دسترسی به Firestore برای همه کالکشن‌های صندوق پولاد.
///
/// نوشتن مالی حساس (تأیید تراکنش، وام، قرعه‌کشی، کارمزد) باید از Cloud Functions
/// انجام شود؛ این سرویس برای خواندن و عملیات مجاز کلاینت است.
abstract class FirestoreService {
  // ── کاربران ──────────────────────────────────────────────
  Future<AppResult<User>> getUser(String uid);
  Future<AppResult<Unit>> upsertUser(User user);
  Future<AppResult<Unit>> deleteUser(String uid);
  Stream<AppResult<User>> watchUser(String uid);

  // ── صندوق‌ها ─────────────────────────────────────────────
  Future<AppResult<Fund>> getFund(String fundId);
  Future<AppResult<List<Fund>>> listFundsForUser(String uid);
  Future<AppResult<Unit>> upsertFund(Fund fund);
  Future<AppResult<Unit>> deleteFund(String fundId);
  Stream<AppResult<Fund>> watchFund(String fundId);

  // ── تراکنش‌ها ────────────────────────────────────────────
  Future<AppResult<Transaction>> getTransaction(String id);
  Future<AppResult<List<Transaction>>> listTransactions({
    required String fundId,
    String? memberId,
    TransactionStatus? status,
    TransactionType? type,
  });
  Future<AppResult<Unit>> upsertTransaction(Transaction tx);
  Future<AppResult<Unit>> deleteTransaction(String id);
  Stream<AppResult<List<Transaction>>> watchTransactions({
    required String fundId,
    TransactionStatus? status,
  });

  // ── وام‌ها ───────────────────────────────────────────────
  Future<AppResult<Loan>> getLoan(String id);
  Future<AppResult<List<Loan>>> listLoans({required String fundId, String? memberId});
  Future<AppResult<Unit>> upsertLoan(Loan loan);
  Future<AppResult<Unit>> deleteLoan(String id);
  Stream<AppResult<List<Loan>>> watchLoans({required String fundId});

  // ── اقساط ────────────────────────────────────────────────
  Future<AppResult<Installment>> getInstallment(String id);
  Future<AppResult<List<Installment>>> listInstallments({
    required String fundId,
    String? memberId,
    String? loanId,
  });
  Future<AppResult<Unit>> upsertInstallment(Installment item);
  Future<AppResult<Unit>> deleteInstallment(String id);
  Stream<AppResult<List<Installment>>> watchInstallments({
    required String fundId,
    String? memberId,
  });

  // ── قرعه‌کشی ─────────────────────────────────────────────
  Future<AppResult<Draw>> getDraw(String id);
  Future<AppResult<List<Draw>>> listDraws({required String fundId});
  Future<AppResult<Unit>> upsertDraw(Draw draw);
  Future<AppResult<Unit>> deleteDraw(String id);
  Stream<AppResult<List<Draw>>> watchDraws({required String fundId});

  // ── کارمزد نرم‌افزار (صورتحساب ادمین) ───────────────────
  Future<AppResult<Fee>> getFee(String id);
  Future<AppResult<List<Fee>>> listFees({required String fundId});
  Future<AppResult<Unit>> upsertFee(Fee fee);
  Future<AppResult<Unit>> deleteFee(String id);
  Stream<AppResult<List<Fee>>> watchFees({required String fundId});
}

/// پیاده‌سازی Firestore با نگاشت Freezed و retry شبکه.
class FirebaseFirestoreService implements FirestoreService {
  FirebaseFirestoreService(this._db, {NetworkRetry? retry})
      : _retry = retry ?? NetworkRetry.standard;

  final FirebaseFirestore _db;
  final NetworkRetry _retry;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(CollectionPaths.users);
  CollectionReference<Map<String, dynamic>> get _funds =>
      _db.collection(CollectionPaths.funds);
  CollectionReference<Map<String, dynamic>> get _txs =>
      _db.collection(CollectionPaths.transactions);
  CollectionReference<Map<String, dynamic>> get _loans =>
      _db.collection(CollectionPaths.loans);
  CollectionReference<Map<String, dynamic>> get _inst =>
      _db.collection(CollectionPaths.installments);
  CollectionReference<Map<String, dynamic>> get _draws =>
      _db.collection(CollectionPaths.draws);
  CollectionReference<Map<String, dynamic>> get _fees =>
      _db.collection(CollectionPaths.fees);

  Map<String, dynamic> _withId(DocumentSnapshot<Map<String, dynamic>> snap, String idField) {
    return {...?snap.data(), idField: snap.id};
  }

  Future<AppResult<T>> _get<T>(
    DocumentReference<Map<String, dynamic>> ref,
    T Function(Map<String, dynamic>) map,
    String idField,
  ) {
    return guardNetwork(() async {
      final snap = await ref.get();
      if (!snap.exists) {
        throw NotFoundFailure(message: 'سند ${ref.path} یافت نشد');
      }
      return map(_withId(snap, idField));
    }, retry: _retry);
  }

  Future<AppResult<Unit>> _set(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) {
    return guardNetwork(() async {
      await ref.set(data, SetOptions(merge: true));
      return unit;
    }, retry: _retry);
  }

  Future<AppResult<Unit>> _delete(DocumentReference<Map<String, dynamic>> ref) {
    return guardNetwork(() async {
      await ref.delete();
      return unit;
    }, retry: _retry);
  }

  Future<AppResult<List<T>>> _query<T>(
    Query<Map<String, dynamic>> q,
    T Function(Map<String, dynamic>) map,
    String idField,
  ) {
    return guardNetwork(() async {
      final snap = await q.get();
      return snap.docs.map((d) => map(_withId(d, idField))).toList();
    }, retry: _retry);
  }

  Stream<AppResult<T>> _watchDoc<T>(
    DocumentReference<Map<String, dynamic>> ref,
    T Function(Map<String, dynamic>) map,
    String idField,
    String missing,
  ) {
    return guardSnapshots(ref.snapshots(), (s) {
      if (!s.exists) throw NotFoundFailure(message: missing);
      return map(_withId(s, idField));
    });
  }

  Stream<AppResult<List<T>>> _watchQuery<T>(
    Query<Map<String, dynamic>> q,
    T Function(Map<String, dynamic>) map,
    String idField,
  ) {
    return guardSnapshots(
      q.snapshots(),
      (s) => s.docs.map((d) => map(_withId(d, idField))).toList(),
    );
  }

  // ── کاربران ──────────────────────────────────────────────
  @override
  Future<AppResult<User>> getUser(String uid) =>
      _get(_users.doc(uid), User.fromJson, 'uid');

  @override
  Future<AppResult<Unit>> upsertUser(User user) =>
      _set(_users.doc(user.uid), user.toFirestore());

  @override
  Future<AppResult<Unit>> deleteUser(String uid) => _delete(_users.doc(uid));

  @override
  Stream<AppResult<User>> watchUser(String uid) =>
      _watchDoc(_users.doc(uid), User.fromJson, 'uid', 'کاربر یافت نشد');

  // ── صندوق‌ها ─────────────────────────────────────────────
  @override
  Future<AppResult<Fund>> getFund(String fundId) =>
      _get(_funds.doc(fundId), Fund.fromJson, 'fundId');

  @override
  Future<AppResult<List<Fund>>> listFundsForUser(String uid) {
    return guardNetwork(() async {
      final user = await _users.doc(uid).get();
      if (!user.exists) return <Fund>[];
      final ids = List<String>.from((user.data()?['fundIds'] as List?) ?? const []);
      if (ids.isEmpty) return <Fund>[];
      final out = <Fund>[];
      for (final id in ids) {
        final snap = await _funds.doc(id).get();
        if (snap.exists) out.add(Fund.fromJson(_withId(snap, 'fundId')));
      }
      return out;
    }, retry: _retry);
  }

  @override
  Future<AppResult<Unit>> upsertFund(Fund fund) =>
      _set(_funds.doc(fund.fundId), fund.toFirestore());

  @override
  Future<AppResult<Unit>> deleteFund(String fundId) => _delete(_funds.doc(fundId));

  @override
  Stream<AppResult<Fund>> watchFund(String fundId) =>
      _watchDoc(_funds.doc(fundId), Fund.fromJson, 'fundId', 'صندوق یافت نشد');

  // ── تراکنش‌ها ────────────────────────────────────────────
  @override
  Future<AppResult<Transaction>> getTransaction(String id) =>
      _get(_txs.doc(id), Transaction.fromJson, 'transactionId');

  @override
  Future<AppResult<List<Transaction>>> listTransactions({
    required String fundId,
    String? memberId,
    TransactionStatus? status,
    TransactionType? type,
  }) {
    Query<Map<String, dynamic>> q =
        _txs.where('fundId', isEqualTo: fundId).orderBy('date', descending: true);
    if (memberId != null) q = q.where('memberId', isEqualTo: memberId);
    if (status != null) q = q.where('status', isEqualTo: status.firestoreValue);
    if (type != null) q = q.where('type', isEqualTo: type.firestoreValue);
    return _query(q, Transaction.fromJson, 'transactionId');
  }

  @override
  Future<AppResult<Unit>> upsertTransaction(Transaction tx) =>
      _set(_txs.doc(tx.transactionId), tx.toFirestore());

  @override
  Future<AppResult<Unit>> deleteTransaction(String id) => _delete(_txs.doc(id));

  @override
  Stream<AppResult<List<Transaction>>> watchTransactions({
    required String fundId,
    TransactionStatus? status,
  }) {
    Query<Map<String, dynamic>> q =
        _txs.where('fundId', isEqualTo: fundId).orderBy('date', descending: true);
    if (status != null) q = q.where('status', isEqualTo: status.firestoreValue);
    return _watchQuery(q, Transaction.fromJson, 'transactionId');
  }

  // ── وام‌ها ───────────────────────────────────────────────
  @override
  Future<AppResult<Loan>> getLoan(String id) => _get(_loans.doc(id), Loan.fromJson, 'loanId');

  @override
  Future<AppResult<List<Loan>>> listLoans({required String fundId, String? memberId}) {
    Query<Map<String, dynamic>> q =
        _loans.where('fundId', isEqualTo: fundId).orderBy('createdAt', descending: true);
    if (memberId != null) q = q.where('memberId', isEqualTo: memberId);
    return _query(q, Loan.fromJson, 'loanId');
  }

  @override
  Future<AppResult<Unit>> upsertLoan(Loan loan) =>
      _set(_loans.doc(loan.loanId), loan.toFirestore());

  @override
  Future<AppResult<Unit>> deleteLoan(String id) => _delete(_loans.doc(id));

  @override
  Stream<AppResult<List<Loan>>> watchLoans({required String fundId}) {
    return _watchQuery(
      _loans.where('fundId', isEqualTo: fundId).orderBy('createdAt', descending: true),
      Loan.fromJson,
      'loanId',
    );
  }

  // ── اقساط ────────────────────────────────────────────────
  @override
  Future<AppResult<Installment>> getInstallment(String id) =>
      _get(_inst.doc(id), Installment.fromJson, 'installmentId');

  @override
  Future<AppResult<List<Installment>>> listInstallments({
    required String fundId,
    String? memberId,
    String? loanId,
  }) {
    // اسناد قسط در سرور فیلد fundId دارند (حتی اگر در مدل Freezed تکرار نشود).
    Query<Map<String, dynamic>> q = _inst.where('fundId', isEqualTo: fundId);
    if (memberId != null) q = q.where('memberId', isEqualTo: memberId);
    if (loanId != null) q = q.where('loanId', isEqualTo: loanId);
    q = q.orderBy('dueDate');
    return _query(q, Installment.fromJson, 'installmentId');
  }

  @override
  Future<AppResult<Unit>> upsertInstallment(Installment item) =>
      _set(_inst.doc(item.installmentId), item.toFirestore());

  @override
  Future<AppResult<Unit>> deleteInstallment(String id) => _delete(_inst.doc(id));

  @override
  Stream<AppResult<List<Installment>>> watchInstallments({
    required String fundId,
    String? memberId,
  }) {
    Query<Map<String, dynamic>> q = _inst.where('fundId', isEqualTo: fundId);
    if (memberId != null) q = q.where('memberId', isEqualTo: memberId);
    q = q.orderBy('dueDate');
    return _watchQuery(q, Installment.fromJson, 'installmentId');
  }

  // ── قرعه‌کشی ─────────────────────────────────────────────
  @override
  Future<AppResult<Draw>> getDraw(String id) => _get(_draws.doc(id), Draw.fromJson, 'drawId');

  @override
  Future<AppResult<List<Draw>>> listDraws({required String fundId}) {
    return _query(
      _draws.where('fundId', isEqualTo: fundId).orderBy('period', descending: true),
      Draw.fromJson,
      'drawId',
    );
  }

  @override
  Future<AppResult<Unit>> upsertDraw(Draw draw) =>
      _set(_draws.doc(draw.drawId), draw.toFirestore());

  @override
  Future<AppResult<Unit>> deleteDraw(String id) => _delete(_draws.doc(id));

  @override
  Stream<AppResult<List<Draw>>> watchDraws({required String fundId}) {
    return _watchQuery(
      _draws.where('fundId', isEqualTo: fundId).orderBy('period', descending: true),
      Draw.fromJson,
      'drawId',
    );
  }

  // ── کارمزد ───────────────────────────────────────────────
  @override
  Future<AppResult<Fee>> getFee(String id) => _get(_fees.doc(id), Fee.fromJson, 'feeId');

  @override
  Future<AppResult<List<Fee>>> listFees({required String fundId}) {
    return _query(
      _fees.where('fundId', isEqualTo: fundId).orderBy('month', descending: true),
      Fee.fromJson,
      'feeId',
    );
  }

  @override
  Future<AppResult<Unit>> upsertFee(Fee fee) => _set(_fees.doc(fee.feeId), fee.toFirestore());

  @override
  Future<AppResult<Unit>> deleteFee(String id) => _delete(_fees.doc(id));

  @override
  Stream<AppResult<List<Fee>>> watchFees({required String fundId}) {
    return _watchQuery(
      _fees.where('fundId', isEqualTo: fundId).orderBy('month', descending: true),
      Fee.fromJson,
      'feeId',
    );
  }
}

/// حافظهٔ درون‌پردازه‌ای برای حالت دمو و تست واحد.
class InMemoryFirestoreService implements FirestoreService {
  final users = <String, User>{};
  final funds = <String, Fund>{};
  final txs = <String, Transaction>{};
  final loans = <String, Loan>{};
  final inst = <String, Installment>{};
  final draws = <String, Draw>{};
  final fees = <String, Fee>{};

  AppResult<T> _ok<T>(T v) => right(v);
  AppResult<T> _miss<T>(String m) => left(NotFoundFailure(message: m));

  @override
  Future<AppResult<User>> getUser(String uid) async =>
      users[uid] != null ? _ok(users[uid]!) : _miss('کاربر یافت نشد');

  @override
  Future<AppResult<Unit>> upsertUser(User user) async {
    users[user.uid] = user;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteUser(String uid) async {
    users.remove(uid);
    return right(unit);
  }

  @override
  Stream<AppResult<User>> watchUser(String uid) async* {
    yield await getUser(uid);
  }

  @override
  Future<AppResult<Fund>> getFund(String fundId) async =>
      funds[fundId] != null ? _ok(funds[fundId]!) : _miss('صندوق یافت نشد');

  @override
  Future<AppResult<List<Fund>>> listFundsForUser(String uid) async {
    final u = users[uid];
    if (u == null) return right(const []);
    return right(u.fundIds.map((id) => funds[id]).whereType<Fund>().toList());
  }

  @override
  Future<AppResult<Unit>> upsertFund(Fund fund) async {
    funds[fund.fundId] = fund;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteFund(String fundId) async {
    funds.remove(fundId);
    return right(unit);
  }

  @override
  Stream<AppResult<Fund>> watchFund(String fundId) async* {
    yield await getFund(fundId);
  }

  @override
  Future<AppResult<Transaction>> getTransaction(String id) async =>
      txs[id] != null ? _ok(txs[id]!) : _miss('تراکنش یافت نشد');

  @override
  Future<AppResult<List<Transaction>>> listTransactions({
    required String fundId,
    String? memberId,
    TransactionStatus? status,
    TransactionType? type,
  }) async {
    var list = txs.values.where((t) => t.fundId == fundId);
    if (memberId != null) list = list.where((t) => t.memberId == memberId);
    if (status != null) list = list.where((t) => t.status == status);
    if (type != null) list = list.where((t) => t.type == type);
    return right(list.toList());
  }

  @override
  Future<AppResult<Unit>> upsertTransaction(Transaction tx) async {
    txs[tx.transactionId] = tx;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteTransaction(String id) async {
    txs.remove(id);
    return right(unit);
  }

  @override
  Stream<AppResult<List<Transaction>>> watchTransactions({
    required String fundId,
    TransactionStatus? status,
  }) async* {
    yield await listTransactions(fundId: fundId, status: status);
  }

  @override
  Future<AppResult<Loan>> getLoan(String id) async =>
      loans[id] != null ? _ok(loans[id]!) : _miss('وام یافت نشد');

  @override
  Future<AppResult<List<Loan>>> listLoans({required String fundId, String? memberId}) async {
    var list = loans.values.where((l) => l.fundId == fundId);
    if (memberId != null) list = list.where((l) => l.memberId == memberId);
    return right(list.toList());
  }

  @override
  Future<AppResult<Unit>> upsertLoan(Loan loan) async {
    loans[loan.loanId] = loan;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteLoan(String id) async {
    loans.remove(id);
    return right(unit);
  }

  @override
  Stream<AppResult<List<Loan>>> watchLoans({required String fundId}) async* {
    yield await listLoans(fundId: fundId);
  }

  @override
  Future<AppResult<Installment>> getInstallment(String id) async =>
      inst[id] != null ? _ok(inst[id]!) : _miss('قسط یافت نشد');

  @override
  Future<AppResult<List<Installment>>> listInstallments({
    required String fundId,
    String? memberId,
    String? loanId,
  }) async {
    var list = inst.values.where((i) {
      final loan = loans[i.loanId];
      return loan?.fundId == fundId;
    });
    if (memberId != null) list = list.where((i) => i.memberId == memberId);
    if (loanId != null) list = list.where((i) => i.loanId == loanId);
    return right(list.toList());
  }

  @override
  Future<AppResult<Unit>> upsertInstallment(Installment item) async {
    inst[item.installmentId] = item;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteInstallment(String id) async {
    inst.remove(id);
    return right(unit);
  }

  @override
  Stream<AppResult<List<Installment>>> watchInstallments({
    required String fundId,
    String? memberId,
  }) async* {
    yield await listInstallments(fundId: fundId, memberId: memberId);
  }

  @override
  Future<AppResult<Draw>> getDraw(String id) async =>
      draws[id] != null ? _ok(draws[id]!) : _miss('قرعه‌کشی یافت نشد');

  @override
  Future<AppResult<List<Draw>>> listDraws({required String fundId}) async =>
      right(draws.values.where((d) => d.fundId == fundId).toList());

  @override
  Future<AppResult<Unit>> upsertDraw(Draw draw) async {
    draws[draw.drawId] = draw;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteDraw(String id) async {
    draws.remove(id);
    return right(unit);
  }

  @override
  Stream<AppResult<List<Draw>>> watchDraws({required String fundId}) async* {
    yield await listDraws(fundId: fundId);
  }

  @override
  Future<AppResult<Fee>> getFee(String id) async =>
      fees[id] != null ? _ok(fees[id]!) : _miss('صورتحساب یافت نشد');

  @override
  Future<AppResult<List<Fee>>> listFees({required String fundId}) async =>
      right(fees.values.where((f) => f.fundId == fundId).toList());

  @override
  Future<AppResult<Unit>> upsertFee(Fee fee) async {
    fees[fee.feeId] = fee;
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteFee(String id) async {
    fees.remove(id);
    return right(unit);
  }

  @override
  Stream<AppResult<List<Fee>>> watchFees({required String fundId}) async* {
    yield await listFees(fundId: fundId);
  }
}
