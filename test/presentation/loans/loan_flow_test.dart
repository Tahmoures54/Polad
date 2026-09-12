import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polad/core/theme/app_theme.dart';
import 'package:polad/core/utils/result.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/entities/people.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/domain/repositories/repositories.dart';
import 'package:polad/domain/services/finance_services.dart';
import 'package:polad/presentation/blocs/app_blocs.dart';
import 'package:polad/presentation/blocs/loans/installment_tracker_cubit.dart';
import 'package:polad/presentation/blocs/loans/loan_request_cubit.dart';
import 'package:polad/presentation/screens/loans/loan_widgets.dart';

class FakeLoanRepo implements LoanRepository {
  SubmitCall? last;
  Result<Loan> result = const Err('not set');
  int calls = 0;

  @override
  Future<Result<Loan>> requestLoan({required int amount, required int termMonths, required String reason}) async {
    calls++;
    last = SubmitCall(amount, termMonths, reason);
    return result;
  }

  @override
  Future<Result<void>> decide({required String loanId, required bool approve, String? note}) => throw UnimplementedError();

  @override
  Stream<List<Installment>> watchInstallments(String fundId, {String? memberId}) => const Stream.empty();

  @override
  Stream<List<Loan>> watchLoans(String fundId) => const Stream.empty();
}

class SubmitCall {
  SubmitCall(this.amount, this.termMonths, this.reason);
  final int amount;
  final int termMonths;
  final String reason;
}

Fund _fund() => Fund(
      id: 'f1',
      name: 'پولاد',
      inviteCode: 'POLAD1',
      adminId: 'a1',
      shareAmount: 5000000,
      paymentPeriodDays: 30,
      serviceFeeRate: 0.005,
      loanAdminFeeRate: 0.02,
      createdAt: DateTime(2026, 1, 1),
      tier: SubscriptionTier.free,
      balance: 100000000,
    );

FundMember _me({int share = 10000000, int overdueDebt = 0}) => FundMember(
      userId: 'u1',
      fundId: 'f1',
      role: UserRole.member,
      displayName: 'سارا',
      phone: '09121111111',
      joinedAt: DateTime(2026, 1, 1),
      shareBalance: share,
      debt: overdueDebt,
    );

HomeState _home({List<Installment> inst = const [], FundMember? me}) => HomeState(
      loading: false,
      fund: _fund(),
      me: me ?? _me(),
      members: [me ?? _me()],
      installments: inst,
    );

Loan _loan() => Loan(
      id: 'l1',
      fundId: 'f1',
      memberId: 'u1',
      memberName: 'سارا',
      amount: 20000000,
      termMonths: 6,
      reason: 'ازدواج',
      status: LoanStatus.requested,
      adminFeeRate: 0.02,
      requestedAt: DateTime(2026, 3, 1),
    );

void main() {
  test('loan request preview uses 2% admin fee not riba', () async {
    final cubit = LoanRequestCubit(loans: FakeLoanRepo());
    cubit.amountChanged('10000000');
    cubit.monthsChanged(4);
    final plan = cubit.previewOf(_fund());
    expect(plan!.fee, 200000);
    expect(plan.total, 10200000);
    expect(plan.items.length, 4);
    expect(cubit.feeLabel(_fund()), contains('٪'));
    await cubit.close();
  });

  test('loan request does not call repo when reason empty', () async {
    final repo = FakeLoanRepo();
    final cubit = LoanRequestCubit(loans: repo);
    cubit.amountChanged('20000000');
    await cubit.submit(_home());
    expect(cubit.state.reasonError, isNotNull);
    expect(repo.calls, 0);
    await cubit.close();
  });

  test('overdue member is denied before submit', () async {
    final repo = FakeLoanRepo();
    final cubit = LoanRequestCubit(loans: repo, eligibility: const LoanEligibility());
    cubit.amountChanged('20000000');
    cubit.reasonChanged('تعمیر خانه');
    final home = _home(
      inst: [
        Installment(
          id: 'i1',
          loanId: 'old',
          fundId: 'f1',
          memberId: 'u1',
          sequence: 1,
          amount: 1,
          dueDate: DateTime(2026, 1, 1),
          status: InstallmentStatus.overdue,
        ),
      ],
    );
    await cubit.submit(home);
    expect(cubit.state.error, contains('معوق'));
    expect(repo.calls, 0);
    await cubit.close();
  });

  test('successful request stores amount and term', () async {
    final repo = FakeLoanRepo()
      ..result = Ok(_loan());
    final cubit = LoanRequestCubit(loans: repo);
    cubit.amountChanged('۲۰٬۰۰۰٬۰۰۰');
    cubit.monthsChanged(6);
    cubit.reasonChanged('ازدواج');
    await cubit.submit(_home());
    expect(repo.calls, 1);
    expect(repo.last!.amount, 20000000);
    expect(repo.last!.termMonths, 6);
    expect(cubit.state.success, isTrue);
    await cubit.close();
  });

  test('admin installment filter isolates overdue', () async {
    final cubit = InstallmentTrackerCubit();
    final home = _home(
      inst: [
        Installment(
          id: 'a',
          loanId: 'l',
          fundId: 'f1',
          memberId: 'u1',
          sequence: 1,
          amount: 1,
          dueDate: DateTime(2026, 2, 1),
          status: InstallmentStatus.upcoming,
        ),
        Installment(
          id: 'b',
          loanId: 'l',
          fundId: 'f1',
          memberId: 'u1',
          sequence: 2,
          amount: 1,
          dueDate: DateTime(2026, 1, 1),
          status: InstallmentStatus.overdue,
        ),
      ],
    );
    cubit.setFilter(AdminInstFilter.overdue);
    expect(cubit.filtered(home).single.id, 'b');
    expect(cubit.memberName(home, 'u1'), 'سارا');
    await cubit.close();
  });

  testWidgets('loan card shows persian status', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: LoanCard(loan: _loan())),
      ),
    );
    expect(find.text('در انتظار بررسی'), findsOneWidget);
    expect(find.text('سارا'), findsOneWidget);
  });
}
