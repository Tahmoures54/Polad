import 'package:flutter_test/flutter_test.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/entities/people.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/presentation/blocs/app_blocs.dart';
import 'package:polad/presentation/blocs/billing/billing_cubit.dart';
import 'package:polad/presentation/blocs/billing/fee_rate_cubit.dart';

Fund _fund({bool charity = false, double rate = 0.005}) => Fund(
      id: 'f1',
      name: 'پولاد',
      inviteCode: 'POLAD1',
      adminId: 'a1',
      shareAmount: 5000000,
      paymentPeriodDays: 30,
      serviceFeeRate: rate,
      loanAdminFeeRate: 0.02,
      createdAt: DateTime(2026, 1, 1),
      tier: SubscriptionTier.free,
      isCharity: charity,
    );

MoneyTransaction _tx() => MoneyTransaction(
      id: 't1',
      fundId: 'f1',
      memberId: 'u1',
      memberName: 'سارا',
      type: TransactionType.sharePayment,
      amount: 8000000,
      status: TransactionStatus.approved,
      occurredAt: DateTime(2026, 9, 5),
      submittedAt: DateTime(2026, 9, 5),
    );

void main() {
  test('billing cubit snapshot charges admin 0.5% for september', () async {
    final cubit = BillingCubit()..setMonth(DateTime(2026, 9, 1));
    final home = HomeState(
      loading: false,
      fund: _fund(),
      transactions: [_tx()],
    );
    final snap = cubit.snapshot(home);
    expect(snap.feeTotal, 40000);
    expect(snap.lines.single.tx.memberName, 'سارا');
    await cubit.close();
  });

  test('charity fund snapshot is zero fee', () async {
    final cubit = BillingCubit()..setMonth(DateTime(2026, 9, 1));
    final snap = cubit.snapshot(
      HomeState(loading: false, fund: _fund(charity: true), transactions: [_tx()]),
    );
    expect(snap.feeTotal, 0);
    expect(snap.charityZeroFee, isTrue);
    expect(snap.needsPayment, isFalse);
    await cubit.close();
  });

  test('fee rate cubit clamps to shaparak band', () async {
    final cubit = FeeRateCubit(fund: _fund(rate: 0.007));
    expect(cubit.state.rate, 0.007);
    cubit.rateChanged(0.02);
    expect(cubit.state.rate, 0.01);
    cubit.charityChanged(true);
    expect(cubit.state.charity, isTrue);
    await cubit.close();
  });
}
