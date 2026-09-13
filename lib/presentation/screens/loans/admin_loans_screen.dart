import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../../../domain/services/finance_services.dart';
import '../../blocs/app_blocs.dart';
import 'loan_widgets.dart';

/// مدیریت وام برای مدیر: تأیید/رد و محاسبه خودکار اقساط با کارمزد ۲٪.
class AdminLoansScreen extends StatelessWidget {
  const AdminLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت وام'),
        actions: [
          IconButton(
            tooltip: 'پیگیری اقساط',
            onPressed: () => context.push('/installments-admin'),
            icon: const Icon(Icons.event_note_outlined),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.loading) return const LoadingView();
          final pending = state.requestedLoans;
          final others = state.loans.where((l) => l.status != LoanStatus.requested).toList();
          return RefreshIndicator(
            color: AppColors.navy,
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'با تأیید، اقساط به‌صورت خودکار با کارمزد اداری ۲٪ (نه ربا) ساخته می‌شود و از موجودی صندوق کم می‌گردد.',
                  style: TextStyle(color: AppColors.muted, height: 1.7),
                ),
                const SectionHeader('در انتظار بررسی'),
                if (pending.isEmpty)
                  const EmptyView(
                    title: 'درخواست جدیدی نیست',
                    subtitle: 'درخواست‌های اعضا اینجا برای تأیید یا رد می‌آید.',
                    icon: Icons.task_alt_outlined,
                  )
                else
                  ...pending.map((l) => _PendingLoan(loan: l)),
                const SectionHeader('سایر وام‌ها'),
                if (others.isEmpty)
                  const EmptyView(title: 'پرونده فعالی نیست', icon: Icons.handshake_outlined)
                else
                  ...others.map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LoanCard(
                        loan: l,
                        onTap: () => context.push('/loan-detail', extra: l.id),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PendingLoan extends StatelessWidget {
  const _PendingLoan({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final fund = home.fund;
    InstallmentPlan? plan;
    if (fund != null) {
      try {
        plan = sl<InstallmentCalculator>().plan(
          principal: loan.amount,
          termMonths: loan.termMonths,
          start: DateTime.now(),
          feeRate: loan.adminFeeRate,
          periodDays: fund.paymentPeriodDays,
        );
      } catch (_) {}
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LoanCard(
        loan: loan,
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (plan != null) InstallmentPlanCard(plan: plan, compact: false),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () => context.read<HomeCubit>().decideLoan(loan.id, true),
                    child: const Text('تأیید و ساخت اقساط'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                    onPressed: () async {
                      final ok = await confirmSheet(
                        context,
                        title: 'رد درخواست',
                        message: 'این وام ثبت نمی‌شود و عضو می‌تواند دوباره درخواست بدهد.',
                        confirmLabel: 'رد کردن',
                        destructive: true,
                      );
                      if (ok && context.mounted) {
                        context.read<HomeCubit>().decideLoan(loan.id, false, note: 'رد مدیر');
                      }
                    },
                    child: const Text('رد'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
