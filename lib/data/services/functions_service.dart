import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../core/network/guard.dart';
import '../../core/network/network_retry.dart';
import '../models/enums.dart';

/// نام Callableهای Cloud Functions پولاد.
class CallableNames {
  const CallableNames._();

  static const createFund = 'createFund';
  static const joinFund = 'joinFund';
  static const submitPayment = 'submitPayment';
  static const approveTransaction = 'approveTransaction';
  static const rejectTransaction = 'rejectTransaction';
  static const requestLoan = 'requestLoan';
  static const decideLoan = 'decideLoan';
  static const createDraw = 'createDraw';
  static const runDraw = 'runDraw';
  static const removeMember = 'removeMember';
  static const changeRole = 'changeRole';
  static const markInvoicePaid = 'markInvoicePaid';
  static const startBankimaPayment = 'startBankimaPayment';
  static const verifyBankimaPayment = 'verifyBankimaPayment';
  static const setCustomClaims = 'setCustomClaims';

  /// TODO(bankima-docs): نام Callableها پایدار است؛ مسیر HTTP پشت آن‌ها در Functions عوض می‌شود.
  static const bankimaVerifyTransaction = 'bankimaVerifyTransaction';
  static const bankimaAccountStatement = 'bankimaAccountStatement';
  static const bankimaInstallmentInfo = 'bankimaInstallmentInfo';
  static const bankimaCreatePaymentLink = 'bankimaCreatePaymentLink';
  static const bankimaGetBalance = 'bankimaGetBalance';
  static const bankimaTransfer = 'bankimaTransfer';
}

/// فراخوانی Cloud Functions از اپ با Either و retry.
///
/// عملیات مالی حساس فقط از این لایه (نه نوشتن مستقیم کلاینت) انجام می‌شود.
abstract class FunctionsService {
  /// فراخوانی عمومی یک تابع با payload دلخواه.
  Future<AppResult<Map<String, dynamic>>> call(
    String name, [
    Map<String, dynamic>? data,
  ]);

  Future<AppResult<Map<String, dynamic>>> createFund(Map<String, dynamic> data);
  Future<AppResult<Map<String, dynamic>>> joinFund(String code);
  Future<AppResult<Map<String, dynamic>>> submitPayment(Map<String, dynamic> data);
  Future<AppResult<Unit>> approveTransaction(String transactionId, {String? note});
  Future<AppResult<Unit>> rejectTransaction(String transactionId, {required String note});
  Future<AppResult<Map<String, dynamic>>> requestLoan(Map<String, dynamic> data);
  Future<AppResult<Unit>> decideLoan({
    required String loanId,
    required bool approve,
    String? note,
  });
  Future<AppResult<Map<String, dynamic>>> createDraw(Map<String, dynamic> data);
  Future<AppResult<Map<String, dynamic>>> runDraw({
    required String drawId,
    String? manualWinnerId,
  });
  Future<AppResult<Unit>> removeMember({required String fundId, required String userId});
  Future<AppResult<Unit>> changeRole({
    required String fundId,
    required String userId,
    required UserRole role,
  });
  Future<AppResult<Unit>> markInvoicePaid(String invoiceId);
  Future<AppResult<Map<String, dynamic>>> startBankimaPayment({
    required String invoiceId,
    required int amountToman,
  });
  Future<AppResult<Unit>> verifyBankimaPayment(String orderId);

  Future<AppResult<Map<String, dynamic>>> bankimaVerifyTransaction(String receiptCode);
  Future<AppResult<Map<String, dynamic>>> bankimaAccountStatement({
    required String accountId,
    required DateTime from,
    required DateTime to,
  });
  Future<AppResult<Map<String, dynamic>>> bankimaInstallmentInfo(String loanId);
  Future<AppResult<Map<String, dynamic>>> bankimaCreatePaymentLink({
    required String memberId,
    required int amountToman,
  });
  Future<AppResult<Map<String, dynamic>>> bankimaGetBalance(String accountId);
  Future<AppResult<Map<String, dynamic>>> bankimaTransfer({
    required String rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  });

  /// تنظیم Custom Claims توسط Admin SDK (کلاینت مستقیم نمی‌تواند).
  Future<AppResult<Unit>> setCustomClaims({
    required String uid,
    required UserRole role,
    String? fundId,
  });
}

/// پیاده‌سازی httpsCallable با تبدیل خطای Functions به [Failure].
class FirebaseFunctionsService implements FunctionsService {
  FirebaseFunctionsService(this._functions, {NetworkRetry? retry})
      : _retry = retry ?? NetworkRetry.standard;

  final FirebaseFunctions _functions;
  final NetworkRetry _retry;

  @override
  Future<AppResult<Map<String, dynamic>>> call(
    String name, [
    Map<String, dynamic>? data,
  ]) {
    return guardNetwork(() async {
      try {
        final res = await _functions.httpsCallable(name).call(data ?? {});
        return _asMap(res.data);
      } on FirebaseFunctionsException catch (e) {
        throw Failure.from(e);
      }
    }, retry: _retry);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  Future<AppResult<Unit>> _okCall(String name, [Map<String, dynamic>? data]) async {
    final res = await call(name, data);
    return res.map((_) => unit);
  }

  @override
  Future<AppResult<Map<String, dynamic>>> createFund(Map<String, dynamic> data) =>
      call(CallableNames.createFund, data);

  @override
  Future<AppResult<Map<String, dynamic>>> joinFund(String code) =>
      call(CallableNames.joinFund, {'code': code});

  @override
  Future<AppResult<Map<String, dynamic>>> submitPayment(Map<String, dynamic> data) =>
      call(CallableNames.submitPayment, data);

  @override
  Future<AppResult<Unit>> approveTransaction(String transactionId, {String? note}) =>
      _okCall(CallableNames.approveTransaction, {'transactionId': transactionId, 'note': note});

  @override
  Future<AppResult<Unit>> rejectTransaction(String transactionId, {required String note}) =>
      _okCall(CallableNames.rejectTransaction, {'transactionId': transactionId, 'note': note});

  @override
  Future<AppResult<Map<String, dynamic>>> requestLoan(Map<String, dynamic> data) =>
      call(CallableNames.requestLoan, data);

  @override
  Future<AppResult<Unit>> decideLoan({
    required String loanId,
    required bool approve,
    String? note,
  }) =>
      _okCall(CallableNames.decideLoan, {'loanId': loanId, 'approve': approve, 'note': note});

  @override
  Future<AppResult<Map<String, dynamic>>> createDraw(Map<String, dynamic> data) =>
      call(CallableNames.createDraw, data);

  @override
  Future<AppResult<Map<String, dynamic>>> runDraw({
    required String drawId,
    String? manualWinnerId,
  }) =>
      call(CallableNames.runDraw, {'drawId': drawId, 'manualWinnerId': manualWinnerId});

  @override
  Future<AppResult<Unit>> removeMember({required String fundId, required String userId}) =>
      _okCall(CallableNames.removeMember, {'fundId': fundId, 'userId': userId});

  @override
  Future<AppResult<Unit>> changeRole({
    required String fundId,
    required String userId,
    required UserRole role,
  }) =>
      _okCall(CallableNames.changeRole, {
        'fundId': fundId,
        'userId': userId,
        'role': role.firestoreValue,
      });

  @override
  Future<AppResult<Unit>> markInvoicePaid(String invoiceId) =>
      _okCall(CallableNames.markInvoicePaid, {'invoiceId': invoiceId});

  @override
  Future<AppResult<Map<String, dynamic>>> startBankimaPayment({
    required String invoiceId,
    required int amountToman,
  }) =>
      call(CallableNames.startBankimaPayment, {
        'invoiceId': invoiceId,
        'amountToman': amountToman,
      });

  @override
  Future<AppResult<Unit>> verifyBankimaPayment(String orderId) =>
      _okCall(CallableNames.verifyBankimaPayment, {'orderId': orderId});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaVerifyTransaction(String receiptCode) =>
      call(CallableNames.bankimaVerifyTransaction, {'receiptCode': receiptCode});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaAccountStatement({
    required String accountId,
    required DateTime from,
    required DateTime to,
  }) =>
      call(CallableNames.bankimaAccountStatement, {
        'accountId': accountId,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaInstallmentInfo(String loanId) =>
      call(CallableNames.bankimaInstallmentInfo, {'loanId': loanId});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaCreatePaymentLink({
    required String memberId,
    required int amountToman,
  }) =>
      call(CallableNames.bankimaCreatePaymentLink, {
        'memberId': memberId,
        'amountToman': amountToman,
      });

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaGetBalance(String accountId) =>
      call(CallableNames.bankimaGetBalance, {'accountId': accountId});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaTransfer({
    required String rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) =>
      call(CallableNames.bankimaTransfer, {
        'rail': rail,
        'destinationIban': destinationIban,
        'amountToman': amountToman,
        'description': description,
        'trackId': trackId,
      });

  @override
  Future<AppResult<Unit>> setCustomClaims({
    required String uid,
    required UserRole role,
    String? fundId,
  }) =>
      _okCall(CallableNames.setCustomClaims, {
        'targetUid': uid,
        'role': role.firestoreValue,
        'fundId': fundId,
      });
}

/// دمو: پاسخ ساختگی بدون سرور.
class DemoFunctionsService implements FunctionsService {
  DemoFunctionsService();

  final calls = <Map<String, dynamic>>[];
  final claims = <String, Map<String, dynamic>>{};

  @override
  Future<AppResult<Map<String, dynamic>>> call(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    calls.add({'name': name, 'data': data ?? {}});
    return right({'ok': true, 'name': name, ...?data});
  }

  Future<AppResult<Unit>> _ok(String name, [Map<String, dynamic>? data]) async {
    await call(name, data);
    return right(unit);
  }

  @override
  Future<AppResult<Map<String, dynamic>>> createFund(Map<String, dynamic> data) =>
      call(CallableNames.createFund, data);

  @override
  Future<AppResult<Map<String, dynamic>>> joinFund(String code) =>
      call(CallableNames.joinFund, {'code': code});

  @override
  Future<AppResult<Map<String, dynamic>>> submitPayment(Map<String, dynamic> data) =>
      call(CallableNames.submitPayment, data);

  @override
  Future<AppResult<Unit>> approveTransaction(String transactionId, {String? note}) =>
      _ok(CallableNames.approveTransaction, {'transactionId': transactionId, 'note': note});

  @override
  Future<AppResult<Unit>> rejectTransaction(String transactionId, {required String note}) =>
      _ok(CallableNames.rejectTransaction, {'transactionId': transactionId, 'note': note});

  @override
  Future<AppResult<Map<String, dynamic>>> requestLoan(Map<String, dynamic> data) =>
      call(CallableNames.requestLoan, data);

  @override
  Future<AppResult<Unit>> decideLoan({
    required String loanId,
    required bool approve,
    String? note,
  }) =>
      _ok(CallableNames.decideLoan, {'loanId': loanId, 'approve': approve, 'note': note});

  @override
  Future<AppResult<Map<String, dynamic>>> createDraw(Map<String, dynamic> data) =>
      call(CallableNames.createDraw, data);

  @override
  Future<AppResult<Map<String, dynamic>>> runDraw({
    required String drawId,
    String? manualWinnerId,
  }) =>
      call(CallableNames.runDraw, {'drawId': drawId, 'manualWinnerId': manualWinnerId});

  @override
  Future<AppResult<Unit>> removeMember({required String fundId, required String userId}) =>
      _ok(CallableNames.removeMember, {'fundId': fundId, 'userId': userId});

  @override
  Future<AppResult<Unit>> changeRole({
    required String fundId,
    required String userId,
    required UserRole role,
  }) =>
      _ok(CallableNames.changeRole, {
        'fundId': fundId,
        'userId': userId,
        'role': role.firestoreValue,
      });

  @override
  Future<AppResult<Unit>> markInvoicePaid(String invoiceId) =>
      _ok(CallableNames.markInvoicePaid, {'invoiceId': invoiceId});

  @override
  Future<AppResult<Map<String, dynamic>>> startBankimaPayment({
    required String invoiceId,
    required int amountToman,
  }) =>
      call(CallableNames.startBankimaPayment, {
        'invoiceId': invoiceId,
        'amountToman': amountToman,
      });

  @override
  Future<AppResult<Unit>> verifyBankimaPayment(String orderId) =>
      _ok(CallableNames.verifyBankimaPayment, {'orderId': orderId});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaVerifyTransaction(String receiptCode) =>
      call(CallableNames.bankimaVerifyTransaction, {'receiptCode': receiptCode});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaAccountStatement({
    required String accountId,
    required DateTime from,
    required DateTime to,
  }) =>
      call(CallableNames.bankimaAccountStatement, {
        'accountId': accountId,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaInstallmentInfo(String loanId) =>
      call(CallableNames.bankimaInstallmentInfo, {'loanId': loanId});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaCreatePaymentLink({
    required String memberId,
    required int amountToman,
  }) =>
      call(CallableNames.bankimaCreatePaymentLink, {
        'memberId': memberId,
        'amountToman': amountToman,
      });

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaGetBalance(String accountId) =>
      call(CallableNames.bankimaGetBalance, {'accountId': accountId});

  @override
  Future<AppResult<Map<String, dynamic>>> bankimaTransfer({
    required String rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) =>
      call(CallableNames.bankimaTransfer, {
        'rail': rail,
        'destinationIban': destinationIban,
        'amountToman': amountToman,
        'description': description,
        'trackId': trackId,
      });

  @override
  Future<AppResult<Unit>> setCustomClaims({
    required String uid,
    required UserRole role,
    String? fundId,
  }) async {
    claims[uid] = {'role': role.firestoreValue, 'fundId': fundId};
    return _ok(CallableNames.setCustomClaims, claims[uid]);
  }
}
