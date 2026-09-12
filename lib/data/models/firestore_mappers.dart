import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import 'draw.dart';
import 'fee.dart';
import 'fund.dart';
import 'installment.dart';
import 'loan.dart';
import 'transaction.dart';
import 'user.dart';

/// کلیدهایی که در JSON به صورت ISO-8601 ذخیره و در فایراستور به Timestamp تبدیل می‌شوند.
const _dateKeys = <String>{
  'createdAt',
  'date',
  'submittedAt',
  'approvedAt',
  'dueDate',
  'drawnAt',
  'paidAt',
};

/// استخراج Map سند و تزریق شناسه در صورت نبودن فیلد id.
Map<String, dynamic> _payload(DocumentSnapshot doc, String idField) {
  final raw = doc.data();
  if (raw is! Map) {
    throw StateError('سند ${doc.id} خالی است یا قالب نامعتبر دارد');
  }
  final map = Map<String, dynamic>.from(raw);
  map.putIfAbsent(idField, () => doc.id);
  return map;
}

/// تبدیل فیلدهای تاریخ رشته‌ای به [Timestamp] برای نوشتن در فایراستور.
Map<String, dynamic> _toFirestore(Map<String, dynamic> json, String idField) {
  final map = Map<String, dynamic>.from(json)..remove(idField);
  for (final key in _dateKeys) {
    final value = map[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        map[key] = Timestamp.fromDate(parsed);
      }
    } else if (value is DateTime) {
      map[key] = Timestamp.fromDate(value);
    }
  }
  return map;
}

/// تبدیل [DocumentSnapshot] به مدل [User] و برعکس.
extension UserDocumentSnapshotX on DocumentSnapshot {
  /// خواندن کاربر از سند `users/{uid}`.
  User toUser() => User.fromJson(_payload(this, 'uid'));
}

/// نوشتن مدل کاربر در فایراستور (uid همان شناسه سند است و داخل داده تکرار نمی‌شود).
extension UserFirestoreWriteX on User {
  /// Map آماده برای `set` / `update`.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'uid');
}

/// تبدیل سند صندوق به [Fund].
extension FundDocumentSnapshotX on DocumentSnapshot {
  /// خواندن صندوق از سند `funds/{fundId}`.
  Fund toFund() => Fund.fromJson(_payload(this, 'fundId'));
}

/// نوشتن مدل صندوق در فایراستور.
extension FundFirestoreWriteX on Fund {
  /// Map آماده برای ذخیره سند صندوق.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'fundId');
}

/// تبدیل سند تراکنش به [Transaction].
extension TransactionDocumentSnapshotX on DocumentSnapshot {
  /// خواندن تراکنش از سند `transactions/{transactionId}`.
  Transaction toTransaction() => Transaction.fromJson(_payload(this, 'transactionId'));
}

/// نوشتن مدل تراکنش در فایراستور.
extension TransactionFirestoreWriteX on Transaction {
  /// Map آماده برای ذخیره سند تراکنش.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'transactionId');
}

/// تبدیل سند وام به [Loan].
extension LoanDocumentSnapshotX on DocumentSnapshot {
  /// خواندن وام از سند `loans/{loanId}`.
  Loan toLoan() => Loan.fromJson(_payload(this, 'loanId'));
}

/// نوشتن مدل وام در فایراستور.
extension LoanFirestoreWriteX on Loan {
  /// Map آماده برای ذخیره سند وام.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'loanId');
}

/// تبدیل سند قسط به [Installment].
extension InstallmentDocumentSnapshotX on DocumentSnapshot {
  /// خواندن قسط از سند `installments/{installmentId}`.
  Installment toInstallment() => Installment.fromJson(_payload(this, 'installmentId'));
}

/// نوشتن مدل قسط در فایراستور.
extension InstallmentFirestoreWriteX on Installment {
  /// Map آماده برای ذخیره سند قسط.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'installmentId');
}

/// تبدیل سند قرعه به [Draw].
extension DrawDocumentSnapshotX on DocumentSnapshot {
  /// خواندن قرعه از سند `draws/{drawId}`.
  Draw toDraw() => Draw.fromJson(_payload(this, 'drawId'));
}

/// نوشتن مدل قرعه در فایراستور.
extension DrawFirestoreWriteX on Draw {
  /// Map آماده برای ذخیره سند قرعه‌کشی.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'drawId');
}

/// تبدیل سند هزینه خدمات به [Fee].
extension FeeDocumentSnapshotX on DocumentSnapshot {
  /// خواندن صورتحساب از سند `service_invoices/{feeId}` یا `fees/{feeId}`.
  Fee toFee() => Fee.fromJson(_payload(this, 'feeId'));
}

/// نوشتن مدل هزینه خدمات در فایراستور.
extension FeeFirestoreWriteX on Fee {
  /// Map آماده برای ذخیره سند صورتحساب مدیر.
  Map<String, dynamic> toFirestore() => _toFirestore(toJson(), 'feeId');
}
