import 'package:flutter_test/flutter_test.dart';
import 'package:polad/core/utils/result.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/domain/repositories/repositories.dart';
import 'package:polad/presentation/blocs/member/payment_cubit.dart';

class FakeTxRepo implements TransactionRepository {
  SubmitPaymentInput? last;
  Result<MoneyTransaction> result = const Err('not set');
  int submitCount = 0;

  @override
  Future<Result<MoneyTransaction>> submit(SubmitPaymentInput input) async {
    last = input;
    submitCount++;
    return result;
  }

  @override
  Future<Result<void>> approve(String transactionId, {String? note}) => throw UnimplementedError();

  @override
  Future<Result<void>> reject(String transactionId, {required String note}) => throw UnimplementedError();

  @override
  Stream<List<MoneyTransaction>> watchForFund(String fundId) => const Stream.empty();

  @override
  Stream<List<MoneyTransaction>> watchForMember(String fundId, String userId) => const Stream.empty();
}

MoneyTransaction pendingTx(SubmitPaymentInput input) {
  return MoneyTransaction(
    id: 'tx-new',
    fundId: 'f1',
    memberId: 'u1',
    memberName: 'سارا',
    type: input.type,
    amount: input.amount,
    status: TransactionStatus.pending,
    occurredAt: input.occurredAt,
    submittedAt: DateTime(2026, 9, 12),
    trackingCode: input.trackingCode,
    receiptUrl: input.receiptPath,
    relatedInstallmentId: input.relatedInstallmentId,
  );
}

void main() {
  test('rejects empty amount and tracking without calling repository', () async {
    final repo = FakeTxRepo();
    final cubit = PaymentCubit(txs: repo, resolveFirestore: false);
    await cubit.submit();
    expect(cubit.state.submitted, isTrue);
    expect(cubit.state.amountError, isNotNull);
    expect(cubit.state.trackingError, isNotNull);
    expect(cubit.state.success, isFalse);
    expect(repo.submitCount, 0);
    await cubit.close();
  });

  test('submit writes pending_approval on domain transaction map', () async {
    final repo = FakeTxRepo();
    repo.result = Ok(pendingTx(SubmitPaymentInput(
      amount: 5000000,
      occurredAt: DateTime(2026, 9, 1),
      trackingCode: '987654321',
      type: TransactionType.sharePayment,
    )));
    final cubit = PaymentCubit(txs: repo, resolveFirestore: false);
    cubit.amountChanged('۵٬۰۰۰٬۰۰۰');
    cubit.trackingChanged('۹۸۷۶۵۴۳۲۱');
    cubit.dateChanged(DateTime(2026, 9, 1));
    cubit.receiptPicked('/tmp/fish.jpg');
    await cubit.submit();

    expect(repo.submitCount, 1);
    expect(repo.last!.amount, 5000000);
    expect(repo.last!.trackingCode, '987654321');
    expect(repo.last!.receiptPath, '/tmp/fish.jpg');
    expect(repo.last!.type, TransactionType.sharePayment);
    expect(cubit.state.success, isTrue);
    expect(cubit.state.created!.status, TransactionStatus.pending);
    expect(cubit.state.created!.toMap()['status'], 'pending_approval');
    await cubit.close();
  });

  test('preset installment id selects installment payment type', () async {
    final cubit = PaymentCubit(
      txs: FakeTxRepo(),
      resolveFirestore: false,
      installmentId: 'inst-1',
      presetAmount: 2500000,
    );
    expect(cubit.state.type, TransactionType.installmentPayment);
    expect(cubit.state.amountText, '2500000');
    await cubit.close();
  });

  test('repository error surfaces as persian message', () async {
    final repo = FakeTxRepo()..result = const Err('شبکه در دسترس نیست');
    final cubit = PaymentCubit(txs: repo, resolveFirestore: false);
    cubit.amountChanged('100000');
    cubit.trackingChanged('123456');
    await cubit.submit();
    expect(cubit.state.success, isFalse);
    expect(cubit.state.error, 'شبکه در دسترس نیست');
    await cubit.close();
  });
}
