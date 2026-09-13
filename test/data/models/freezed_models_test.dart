import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_test/flutter_test.dart';
import 'package:polad/data/models/models.dart';

void main() {
  final createdAt = DateTime.utc(2026, 9, 12, 10, 30);

  group('User', () {
    test('roundtrip json and copyWith', () {
      final user = User(
        uid: 'u1',
        name: 'طهمورث',
        phone: '09120000000',
        role: UserRole.admin,
        fundIds: const ['f1'],
        createdAt: createdAt,
      );

      final json = user.toJson();
      expect(json['role'], 'admin');
      expect(json['createdAt'], createdAt.toUtc().toIso8601String());

      final restored = User.fromJson(json);
      expect(restored, user);
      expect(restored.copyWith(name: 'مریم').name, 'مریم');
      expect(UserRole.admin.displayName, 'مدیر');
    });

    test('toFirestore converts dates to Timestamp and drops uid', () {
      final user = User(
        uid: 'u1',
        name: 'طهمورث',
        phone: '09120000000',
        role: UserRole.member,
        createdAt: createdAt,
      );
      final doc = user.toFirestore();
      expect(doc.containsKey('uid'), isFalse);
      expect(doc['createdAt'], isA<Timestamp>());
      expect((doc['createdAt'] as Timestamp).toDate().toUtc(), createdAt);
    });

    test('fromJson accepts Firestore Timestamp', () {
      final user = User.fromJson({
        'uid': 'u2',
        'name': 'زهرا',
        'phone': '09124444444',
        'role': 'member',
        'fundIds': <String>[],
        'createdAt': Timestamp.fromDate(createdAt),
      });
      expect(user.role, UserRole.member);
      expect(user.createdAt.toUtc(), createdAt);
    });
  });

  group('Fund', () {
    test('serializes periodType and feeRate', () {
      final fund = Fund(
        fundId: 'f1',
        name: 'صندوق خانوادگی پولاد',
        ownerId: 'u1',
        shareAmount: 5000000,
        periodType: FundPeriodType.monthly,
        feeRate: 0.005,
        createdAt: createdAt,
      );
      final json = fund.toJson();
      expect(json['periodType'], 'monthly');
      expect(Fund.fromJson(json), fund);
      expect(FundPeriodType.monthly.displayName, 'ماهانه');
    });
  });

  group('Transaction', () {
    test('uses pending_approval wire value and copyWith', () {
      final tx = Transaction(
        transactionId: 't1',
        fundId: 'f1',
        memberId: 'u2',
        amount: 5000000,
        receiptCode: '1403123456',
        date: createdAt,
        status: TransactionStatus.pendingApproval,
        type: TransactionType.installment,
        submittedAt: createdAt,
        feeAmount: 25000,
        feeApplied: true,
      );
      final json = tx.toJson();
      expect(json['status'], 'pending_approval');
      expect(json['type'], 'installment');
      expect(Transaction.fromJson(json), tx);
      expect(tx.copyWith(status: TransactionStatus.approved).status.isFinal, isTrue);
      expect(TransactionStatus.pendingApproval.displayName, 'در انتظار تأیید');
    });
  });

  group('Loan and Installment', () {
    test('roundtrip with persian display names', () {
      final loan = Loan(
        loanId: 'l1',
        fundId: 'f1',
        memberId: 'u2',
        amount: 50000000,
        installmentsCount: 10,
        status: LoanStatus.pending,
        feeRate: 0.02,
        createdAt: createdAt,
      );
      expect(Loan.fromJson(loan.toJson()), loan);
      expect(LoanStatus.active.displayName, 'فعال');

      final inst = Installment(
        installmentId: 'i1',
        loanId: 'l1',
        memberId: 'u2',
        amount: 5100000,
        dueDate: createdAt.add(const Duration(days: 30)),
        status: InstallmentStatus.overdue,
      );
      expect(Installment.fromJson(inst.toJson()), inst);
      expect(InstallmentStatus.overdue.displayName, 'معوق');
      expect(inst.toFirestore()['dueDate'], isA<Timestamp>());
    });
  });

  group('Draw and Fee', () {
    test('nullable winner and paidAt survive json', () {
      final draw = Draw(
        drawId: 'd1',
        fundId: 'f1',
        period: '1404-07',
        method: DrawMethod.random,
      );
      final json = draw.toJson();
      expect(json.containsKey('winnerId'), isFalse);
      expect(Draw.fromJson({...json, 'drawId': 'd1', 'fundId': 'f1', 'period': '1404-07', 'method': 'random'}), draw);
      expect(DrawMethod.manual.displayName, 'دستی');

      final fee = Fee(
        feeId: 'fee1',
        fundId: 'f1',
        month: '1404-06',
        totalAmount: 275000,
        status: FeeStatus.pending,
      );
      expect(Fee.fromJson(fee.toJson()), fee);
      expect(FeeStatus.pending.displayName, 'پرداخت‌نشده');
      expect(fee.copyWith(status: FeeStatus.paid, paidAt: createdAt).status.isPaid, isTrue);
    });
  });
}
