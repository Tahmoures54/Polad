import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/entities/reports.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/reports/report_cubit.dart';

/// صفحهٔ گزارش‌های مدیر: نمودارها، معوقات، کارمزد، عملکرد اعضا، Excel/PDF.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.watch<HomeCubit>().state.isAdmin) {
      return const Scaffold(body: EmptyView(title: 'فقط مدیر به گزارش‌ها دسترسی دارد', icon: Icons.lock_outline));
    }
    return BlocProvider(
      create: (_) => ReportCubit(fundId: context.read<HomeCubit>().fundId)..load(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    return BlocConsumer<ReportCubit, ReportUiState>(
      listener: (context, state) {
        final msg = state.error ?? state.message;
        if (msg != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<ReportCubit>();
        final report = state.report;
        return Scaffold(
          appBar: AppBar(
            title: const Text('گزارش‌ها'),
            actions: [
              IconButton(
                tooltip: 'خروجی اکسل',
                onPressed: state.busy ? null : cubit.exportExcel,
                icon: const Icon(Icons.grid_on_outlined),
              ),
              IconButton(
                tooltip: 'خروجی PDF',
                onPressed: state.busy ? null : cubit.exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
              ),
            ],
          ),
          body: report == null
              ? (state.busy ? const LoadingView() : EmptyView(title: state.error ?? 'گزارشی نیست'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _Filters(home: home, filter: state.filter),
                    const SizedBox(height: 8),
                    _SummaryRow(report: report),
                    const SectionHeader('جریان نقدی ماهانه'),
                    _CashflowCharts(points: report.summary.points),
                    const SectionHeader('توزیع وام‌ها'),
                    _LoanPie(slices: report.loanSlices),
                    const SectionHeader('اقساط معوق'),
                    if (report.overdue.isEmpty)
                      const EmptyView(title: 'قسط معوقی با این فیلتر نیست', icon: Icons.verified_outlined)
                    else
                      ...report.overdue.map(
                        (i) => Card(
                          child: ListTile(
                            title: Text('قسط ${faDigits(i.sequence)} — ${toman(i.amount)}'),
                            subtitle: Text('سررسید ${jalaliDate(i.dueDate)}'),
                            trailing: const StatusChip(label: 'معوق', tone: ChipTone.danger),
                          ),
                        ),
                      ),
                    const SectionHeader('درآمد کارمزد ماهانه (بدهی مدیر)'),
                    Text(
                      report.summary.charityZeroFee
                          ? 'صندوق خیریه است؛ کارمزد نرم‌افزار صفر است و از عضو چیزی کم نشده.'
                          : 'نرخ ${percentFa(report.summary.serviceFeeRate)} فقط از مدیر دریافت می‌شود.',
                      style: const TextStyle(color: AppColors.muted, height: 1.6),
                    ),
                    const SizedBox(height: 8),
                    SummaryCard(
                      title: 'صورتحساب مدیر',
                      value: report.summary.softwareFeeToAdmin,
                      color: AppColors.gold,
                      subtitle: 'از عضو: ۰ تومان',
                    ),
                    if (report.feePoints.isNotEmpty) _FeeBars(points: report.feePoints),
                    const SectionHeader('عملکرد اعضا'),
                    ...report.members.map(
                      (m) => Card(
                        child: ListTile(
                          title: Text(m.member.displayName),
                          subtitle: Text(
                            'پرداخت ${faDigits(m.paidCount)} • ${toman(m.paidAmount)}\nمعوق ${faDigits(m.overdueCount)} • بدهی ${toman(m.member.debt)}',
                          ),
                          isThreeLine: true,
                          trailing: Text(m.member.role.fa, style: const TextStyle(color: AppColors.muted)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: state.busy ? null : cubit.exportExcel,
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('اشتراک‌گذاری Excel'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: state.busy ? null : cubit.exportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('اشتراک‌گذاری PDF'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.home, required this.filter});
  final HomeState home;
  final ReportFilter filter;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showPersianDatePicker(
                    context: context,
                    initialDate: Jalali.now(),
                    firstDate: Jalali(1398, 1),
                    lastDate: Jalali.now(),
                  );
                  if (picked != null) {
                    cubit.setJalaliRange(picked, filter.to == null ? Jalali.now() : Jalali.fromDateTime(filter.to!));
                  }
                },
                child: Text(filter.from == null ? 'از تاریخ' : jalaliDate(filter.from!)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showPersianDatePicker(
                    context: context,
                    initialDate: Jalali.now(),
                    firstDate: Jalali(1398, 1),
                    lastDate: Jalali.now(),
                  );
                  if (picked != null) {
                    cubit.setJalaliRange(
                      filter.from == null ? Jalali(1398, 1) : Jalali.fromDateTime(filter.from!),
                      picked,
                    );
                  }
                },
                child: Text(filter.to == null ? 'تا تاریخ' : jalaliDate(filter.to!)),
              ),
            ),
            IconButton(
              tooltip: 'حذف بازه',
              onPressed: () => cubit.setJalaliRange(null, null),
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: filter.memberId,
          decoration: const InputDecoration(labelText: 'عضو'),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('همهٔ اعضا')),
            ...home.members.map((m) => DropdownMenuItem(value: m.userId, child: Text(m.displayName))),
          ],
          onChanged: cubit.setMember,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TransactionType?>(
          initialValue: filter.type,
          decoration: const InputDecoration(labelText: 'نوع تراکنش'),
          items: [
            const DropdownMenuItem<TransactionType?>(value: null, child: Text('همهٔ انواع')),
            ...TransactionType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.fa))),
          ],
          onChanged: cubit.setType,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.report});
  final PoladReport report;

  @override
  Widget build(BuildContext context) {
    final s = report.summary;
    return Column(
      children: [
        Row(children: [
          Expanded(child: SummaryCard(title: 'ورودی', value: s.totalIn, color: AppColors.success)),
          const SizedBox(width: 8),
          Expanded(child: SummaryCard(title: 'خروجی', value: s.totalOut, color: AppColors.danger)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: SummaryCard(title: 'خالص', value: s.net, color: AppColors.navy)),
          const SizedBox(width: 8),
          Expanded(
            child: SummaryCard(
              title: 'معوقات',
              value: s.overdueAmount,
              subtitle: '${faDigits(s.overdueCount)} قسط',
              color: AppColors.warning,
            ),
          ),
        ]),
      ],
    );
  }
}

class _CashflowCharts extends StatelessWidget {
  const _CashflowCharts({required this.points});
  final List<CashflowPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const EmptyView(title: 'هنوز نموداری نیست');
    Widget bottomTitle(double v, TitleMeta _) {
      final i = v.toInt();
      if (i < 0 || i >= points.length) return const SizedBox.shrink();
      return Text(faDigits(points[i].label), style: const TextStyle(fontSize: 9));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitle, interval: 1)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].inflow.toDouble())],
                  color: AppColors.success,
                  isCurved: true,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].outflow.toDouble())],
                  color: AppColors.danger,
                  isCurved: true,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitle)),
              ),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: points[i].inflow.toDouble(), color: AppColors.success, width: 8),
                    BarChartRodData(toY: points[i].outflow.toDouble(), color: AppColors.danger, width: 8),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoanPie extends StatelessWidget {
  const _LoanPie({required this.slices});
  final List<LoanSlice> slices;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) return const EmptyView(title: 'وامی ثبت نشده');
    final total = slices.fold<int>(0, (a, b) => a + b.amount);
    final colors = [AppColors.navy, AppColors.gold, AppColors.success, AppColors.warning, AppColors.info];
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: [
                for (var i = 0; i < slices.length; i++)
                  PieChartSectionData(
                    value: slices[i].amount.toDouble().clamp(1, double.infinity),
                    color: colors[i % colors.length],
                    title: slices[i].status.fa,
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'Vazirmatn'),
                    radius: 58,
                  ),
              ],
            ),
          ),
        ),
        ...slices.map(
          (s) => ListTile(
            dense: true,
            title: Text(s.status.fa),
            trailing: Text('${faDigits(s.count)} • ${toman(s.amount)}'),
            subtitle: total == 0 ? null : Text('${faDigits(((s.amount / total) * 100).round())}٪'),
          ),
        ),
      ],
    );
  }
}

class _FeeBars extends StatelessWidget {
  const _FeeBars({required this.points});
  final List<MonthlyFeePoint> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  return Text(faDigits(points[i].label), style: const TextStyle(fontSize: 9));
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [BarChartRodData(toY: points[i].feeAmount.toDouble(), color: AppColors.gold, width: 12)],
              ),
          ],
        ),
      ),
    );
  }
}
