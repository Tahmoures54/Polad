import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/brand/polad_voice.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../../../domain/services/finance_services.dart';
import '../../blocs/app_blocs.dart';
import '../../widgets/fund_switcher.dart';
import 'home_screens.dart';

/// داشبورد مدیر — تأیید نهایی تراکنش فقط اینجا و هرگز خودکار نیست.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (!state.isAdmin) {
          return const EmptyView(title: 'این صفحه فقط برای مدیر است', icon: Icons.lock_outline);
        }
        if (state.loading || state.fund == null) return const LoadingView();
        final fund = state.fund!;
        final snap = const RevenueService().forMonth(
          fund: fund,
          transactions: state.transactions,
          invoices: state.invoices,
        );
        return RefreshIndicator(
          color: AppColors.navy,
          onRefresh: () => context.read<HomeCubit>().refresh(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(fund.name),
                actions: const [FundSwitcherButton()],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                sliver: SliverList.list(
                  children: [
                    const FundSwitcherStrip(),
                    const SizedBox(height: 8),
                    _SummaryGrid(state: state),
                    SectionHeader(
                      'در انتظار تأیید',
                      action: TextButton(
                        onPressed: () => context.go('/pending'),
                        child: Text('${faDigits(state.pending.length)} مورد'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            PoladVoice.adminQueueHint,
                            style: TextStyle(height: 1.6, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          if (state.pending.isEmpty)
                            const EmptyView(
                              title: 'مورد معلقی نیست',
                              subtitle: 'پرداخت‌های اعضا اینجا ظاهر می‌شود.',
                              icon: Icons.verified_outlined,
                            )
                          else
                            ...state.pending.take(4).map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: PendingTxCard(tx: t, expanded: true),
                                )),
                        ],
                      ),
                    ),
                    const SectionHeader('خلاصه مالی ماهانه'),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'کارمزد نرم‌افزار',
                            value: snap.feeTotal,
                            color: AppColors.gold,
                            subtitle: snap.charityZeroFee ? 'خیریه: صفر' : 'بدهی مدیر',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SummaryCard(
                            title: 'سود خالص صندوق',
                            value: fund.balance,
                            color: AppColors.success,
                            subtitle: 'خروجی وام جداست',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هزینه‌ها در این مدل همان پرداخت وام است و کارمزد از عضو کسر نمی‌شود.',
                      style: const TextStyle(color: AppColors.muted, height: 1.6, fontSize: 13),
                    ),
                    const SectionHeader('میان‌برها'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Quick('اعضا', Icons.groups_outlined, () => context.go('/members')),
                        _Quick('وام‌ها', Icons.handshake_outlined, () => context.push('/loans')),
                        _Quick('اقساط', Icons.event_note_outlined, () => context.push('/installments-admin')),
                        _Quick('قرعه‌کشی', Icons.casino_outlined, () => context.push('/draws')),
                        _Quick('گزارش', Icons.insights_outlined, () => context.push('/reports')),
                        _Quick('تنظیمات صندوق', Icons.tune, () => context.push('/fund-settings')),
                        _Quick('صورتحساب من', Icons.receipt_long_outlined, () => context.push('/billing')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final fund = state.fund!;
    final spark = _spark(state.transactions);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 168,
          child: _SparkCard(
            title: 'موجودی صندوق',
            value: fund.balance,
            color: AppColors.navy,
            icon: Icons.account_balance_wallet_outlined,
            spark: spark,
          ),
        ),
        SizedBox(
          width: 168,
          child: SummaryCard(title: 'اعضا', value: fund.memberCount, icon: Icons.groups_outlined, color: AppColors.gold),
        ),
        SizedBox(
          width: 168,
          child: SummaryCard(title: 'وام فعال', value: state.activeLoans, icon: Icons.handshake_outlined, color: AppColors.info),
        ),
        SizedBox(
          width: 168,
          child: SummaryCard(
            title: 'اقساط معوق',
            value: state.overdueCount,
            icon: Icons.warning_amber_outlined,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }

  List<double> _spark(List<MoneyTransaction> txs) {
    final approved = txs.where((t) => t.status == TransactionStatus.approved).toList();
    if (approved.isEmpty) return const [0, 0, 0, 0];
    approved.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return approved.take(8).map((t) => t.amount.toDouble()).toList();
  }
}

class _SparkCard extends StatelessWidget {
  const _SparkCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.spark,
  });

  final String title;
  final int value;
  final Color color;
  final IconData icon;
  final List<double> spark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          Text(tomanCompact(value), style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: LineChart(
              LineChartData(
                minY: 0,
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (var i = 0; i < spark.length; i++) FlSpot(i.toDouble(), spark[i])],
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    isCurved: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.navy),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.divider),
    );
  }
}
