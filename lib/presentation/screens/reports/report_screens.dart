import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/repositories/repositories.dart';
import '../../blocs/app_blocs.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  FundReport? report;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = context.read<HomeCubit>().fundId;
      try {
        final r = await sl<ReportRepository>().build(id);
        if (mounted) setState(() => report = r);
      } catch (e) {
        if (mounted) setState(() => error = e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = report;
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش‌ها')),
      body: r == null
          ? (error == null ? const LoadingView() : EmptyView(title: error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  Expanded(child: SummaryCard(title: 'ورودی', value: r.totalIn, color: AppColors.success)),
                  const SizedBox(width: 8),
                  Expanded(child: SummaryCard(title: 'خروجی', value: r.totalOut, color: AppColors.danger)),
                ]),
                const SizedBox(height: 8),
                SummaryCard(title: 'معوقات', value: r.overdueAmount, subtitle: '${faNum(r.overdueCount)} قسط', color: AppColors.warning),
                const SectionHeader('جریان نقدی'),
                SizedBox(
                  height: 220,
                  child: r.points.isEmpty
                      ? const EmptyView(title: 'هنوز نموداری نیست')
                      : BarChart(
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
                                    if (i < 0 || i >= r.points.length) return const SizedBox.shrink();
                                    return Text(r.points[i].label, style: const TextStyle(fontSize: 9));
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              for (var i = 0; i < r.points.length; i++)
                                BarChartGroupData(x: i, barRods: [
                                  BarChartRodData(toY: r.points[i].inflow.toDouble(), color: AppColors.success, width: 8),
                                  BarChartRodData(toY: r.points[i].outflow.toDouble(), color: AppColors.danger, width: 8),
                                ]),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final res = await sl<ReportRepository>().exportExcel(context.read<HomeCubit>().fundId);
                    if (!context.mounted) return;
                    res.when(
                      ok: (_) {},
                      err: (m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))),
                    );
                  },
                  child: const Text('خروجی Excel'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final res = await sl<ReportRepository>().exportPdf(context.read<HomeCubit>().fundId);
                    if (!context.mounted) return;
                    res.when(
                      ok: (_) {},
                      err: (m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))),
                    );
                  },
                  child: const Text('خروجی PDF'),
                ),
              ],
            ),
    );
  }
}
