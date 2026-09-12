import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:polad/data/sms/bank_sms_parser.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/domain/services/finance_services.dart';

void main() {
  group('InstallmentCalculator', () {
    const calc = InstallmentCalculator();

    test('splits principal plus 2% fee across months without leftover rials', () {
      final plan = calc.plan(
        principal: 10000000,
        termMonths: 4,
        start: DateTime(2026, 1, 1),
      );
      expect(plan.fee, 200000);
      expect(plan.total, 10200000);
      expect(plan.items.length, 4);
      expect(plan.items.fold<int>(0, (a, b) => a + b.amount), 10200000);
      expect(plan.items.last.dueDate, DateTime(2026, 1, 1).add(const Duration(days: 120)));
    });

    test('marks overdue after due date', () {
      expect(
        calc.statusOf(DateTime(2026, 1, 1), now: DateTime(2026, 1, 2)),
        InstallmentStatus.overdue,
      );
      expect(
        calc.statusOf(DateTime(2026, 1, 2), now: DateTime(2026, 1, 2), paid: true),
        InstallmentStatus.paid,
      );
    });
  });

  group('FeeCalculator Shaparak compliance', () {
    const fees = FeeCalculator();

    test('bills admin 0.5% and never mutates member amount', () {
      const memberPayment = 5000000;
      final fee = fees.softwareServiceFee(memberPayment, 0.005);
      expect(fee, 25000);
      expect(memberPayment, 5000000);
    });

    test('rejects rates outside 0.5%–1%', () {
      expect(() => fees.softwareServiceFee(1000, 0.004), throwsArgumentError);
      expect(() => fees.softwareServiceFee(1000, 0.011), throwsArgumentError);
    });
  });

  group('LoanEligibility', () {
    const elig = LoanEligibility();

    test('denies overdue members', () {
      expect(
        elig.denyReason(
          requested: 20000000,
          shareAmount: 5000000,
          memberShareBalance: 10000000,
          overdueCount: 1,
          fundBalance: 100000000,
          isActiveMember: true,
        ),
        contains('معوق'),
      );
    });

    test('allows a clean member under the 10× share cap', () {
      expect(
        elig.denyReason(
          requested: 20000000,
          shareAmount: 5000000,
          memberShareBalance: 10000000,
          overdueCount: 0,
          fundBalance: 100000000,
          isActiveMember: true,
        ),
        isNull,
      );
    });
  });

  group('InviteCode', () {
    test('is 6 chars and normalizes spaces', () {
      final code = InviteCode.generate();
      expect(code.length, 6);
      expect(InviteCode.normalize(' po lad '), 'POLAD');
    });
  });

  group('DrawSelector', () {
    test('picks only from eligible ids', () {
      final ids = ['a', 'b', 'c'];
      final pick = const DrawSelector().pickRandom(ids, Random(42));
      expect(ids.contains(pick), isTrue);
    });

    test('throws when nobody is eligible', () {
      expect(
        () => const DrawSelector().pickRandom(const [], Random()),
        throwsStateError,
      );
    });
  });

  group('BankSmsParser', () {
    final parser = BankSmsParser();

    test('reads Mellat-style credit SMS', () {
      const body = 'بانک ملت\nواریز: ۵٬۰۰۰٬۰۰۰ تومان\nکد پیگیری: 1403123456';
      final sms = parser.parse('BankMellat', body, DateTime(2026, 9, 1));
      expect(sms.amount, 5000000);
      expect(sms.trackingCode, '1403123456');
      expect(sms.isCredit, isTrue);
    });

    test('matches pending transaction by tracking code', () {
      const body = 'واریز مبلغ 5100000 تومان پیگیری 99887766';
      final sms = parser.parse('Mellat', body, DateTime(2026, 9, 1, 12));
      final pending = [
        MoneyTransaction(
          id: '1',
          fundId: 'f',
          memberId: 'u',
          memberName: 'زهرا',
          type: TransactionType.installmentPayment,
          amount: 5100000,
          status: TransactionStatus.pending,
          occurredAt: DateTime(2026, 9, 1, 10),
          submittedAt: DateTime(2026, 9, 1, 11),
          trackingCode: '99887766',
        ),
      ];
      final result = parser.match(sms: sms, pending: pending);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.id, '1');
    });
  });
}
