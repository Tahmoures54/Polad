import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:polad/core/theme/app_theme.dart';
import 'package:polad/core/utils/formatters.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/entities/people.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/presentation/blocs/app_blocs.dart';
import 'package:polad/presentation/blocs/member/member_dashboard_cubit.dart';
import 'package:polad/presentation/screens/home/member_shimmer.dart';
import 'package:polad/presentation/screens/home/member_widgets.dart';
import 'package:shimmer/shimmer.dart';

MoneyTransaction _tx({
  required String id,
  required TransactionStatus status,
  DateTime? occurredAt,
  int amount = 1000000,
}) {
  final at = occurredAt ?? DateTime(2026, 1, 1);
  return MoneyTransaction(
    id: id,
    fundId: 'f1',
    memberId: 'u1',
    memberName: 'علی',
    type: TransactionType.sharePayment,
    amount: amount,
    status: status,
    occurredAt: at,
    submittedAt: at,
    trackingCode: '12345678',
  );
}

Installment _inst({
  required String id,
  required InstallmentStatus status,
  required int sequence,
  DateTime? due,
}) {
  return Installment(
    id: id,
    loanId: 'l1',
    fundId: 'f1',
    memberId: 'u1',
    sequence: sequence,
    amount: 2500000,
    dueDate: due ?? DateTime(2026, 2, sequence),
    status: status,
  );
}

HomeState _home({
  List<MoneyTransaction> txs = const [],
  List<Installment> installments = const [],
}) {
  return HomeState(
    loading: false,
    me: FundMember(
      userId: 'u1',
      fundId: 'f1',
      role: UserRole.member,
      displayName: 'علی',
      phone: '09121111111',
      joinedAt: DateTime(2026, 1, 1),
    ),
    transactions: txs,
    installments: installments,
  );
}

void main() {
  group('MemberDashboardCubit', () {
    test('filters history and sorts newest first', () {
      final cubit = MemberDashboardCubit();
      final home = _home(
        txs: [
          _tx(id: 'old', status: TransactionStatus.approved, occurredAt: DateTime(2026, 1, 1)),
          _tx(id: 'new-pending', status: TransactionStatus.pending, occurredAt: DateTime(2026, 3, 1)),
          _tx(id: 'mid', status: TransactionStatus.approved, occurredAt: DateTime(2026, 2, 1), amount: 2000000),
        ],
      );

      expect(cubit.historyOf(home).map((t) => t.id).toList(), ['new-pending', 'mid', 'old']);

      cubit.setFilter(TxHistoryFilter.approved);
      expect(cubit.historyOf(home).map((t) => t.id).toList(), ['mid', 'old']);

      cubit.setFilter(TxHistoryFilter.pending);
      expect(cubit.historyOf(home).single.id, 'new-pending');
      cubit.close();
    });

    test('orders installments overdue then upcoming then paid', () {
      final cubit = MemberDashboardCubit();
      final home = _home(
        installments: [
          _inst(id: 'paid', status: InstallmentStatus.paid, sequence: 1, due: DateTime(2026, 1, 1)),
          _inst(id: 'late', status: InstallmentStatus.overdue, sequence: 2, due: DateTime(2026, 2, 1)),
          _inst(id: 'next', status: InstallmentStatus.upcoming, sequence: 3, due: DateTime(2026, 3, 1)),
        ],
      );
      expect(cubit.upcomingOf(home).map((i) => i.id).toList(), ['late', 'next', 'paid']);
      cubit.close();
    });
  });

  group('Persian amount formatter', () {
    test('groups with persian digits', () {
      final formatter = PersianAmountFormatter();
      final next = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '5000000'),
      );
      expect(next.text, groupedFaAmount(5000000));
      expect(next.text, isNot(contains('5')));
      expect(TransactionStatus.pending.firestoreValue, 'pending_approval');
    });

    test('MoneyTransaction.toMap writes pending_approval', () {
      final map = _tx(id: 't1', status: TransactionStatus.pending).toMap();
      expect(map['status'], 'pending_approval');
    });
  });

  testWidgets('stat cards, filters and installment statuses render RTL', (tester) async {
    var filter = TxHistoryFilter.all;
    final overdue = _inst(id: 'i1', status: InstallmentStatus.overdue, sequence: 2);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ListView(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: MemberStatCard(
                        title: 'سهم من',
                        value: 12000000,
                        color: Color(0xFF1A237E),
                        icon: Icons.savings_outlined,
                      ),
                    ),
                  ],
                ),
                MemberInstallmentCard(item: overdue),
                MemberTxTile(tx: _tx(id: 't', status: TransactionStatus.pending)),
                StatefulBuilder(
                  builder: (context, setState) => TxHistoryFilterBar(
                    selected: filter,
                    onSelected: (f) => setState(() => filter = f),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('سهم من'), findsOneWidget);
    expect(find.text('معوق'), findsOneWidget);
    expect(find.text('در انتظار تأیید'), findsOneWidget);
    expect(find.text('همه'), findsOneWidget);
    expect(find.text('تأییدشده'), findsOneWidget);
    expect(find.text('در انتظار'), findsOneWidget);

    await tester.tap(find.text('تأییدشده'));
    await tester.pump();
    expect(filter, TxHistoryFilter.approved);
  });

  testWidgets('member dashboard shimmer paints skeleton', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MemberDashboardShimmer()),
      ),
    );
    expect(find.byType(Shimmer), findsOneWidget);
  });

  testWidgets('unpaid installment card navigates to pay', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: MemberInstallmentCard(
              item: _inst(id: 'inst-9', status: InstallmentStatus.upcoming, sequence: 1),
            ),
          ),
        ),
        GoRoute(
          path: '/pay',
          builder: (_, state) => Scaffold(body: Text('pay:${state.extra}')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
    await tester.tap(find.text('در انتظار'));
    await tester.pumpAndSettle();
    expect(find.text('pay:inst-9'), findsOneWidget);
  });
}
