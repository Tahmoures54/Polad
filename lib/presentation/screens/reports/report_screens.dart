import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';
import '../../blocs/app_blocs.dart';

class DrawsScreen extends StatelessWidget {
  const DrawsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قرعه‌کشی')),
      floatingActionButton: context.watch<HomeCubit>().state.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final title = TextEditingController(text: 'قرعه‌کشی جدید');
                final prize = TextEditingController(text: '10000000');
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('دوره جدید'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان')),
                      TextField(controller: prize, decoration: const InputDecoration(labelText: 'جایزه (تومان)'), keyboardType: TextInputType.number),
                    ]),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ایجاد')),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<HomeCubit>().createDraw(title: title.text, prize: int.tryParse(prize.text) ?? 0);
                }
              },
              label: const Text('دوره جدید'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.draws.isEmpty) return const EmptyView(title: 'هنوز قرعه‌کشی تعریف نشده', icon: Icons.casino_outlined);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: state.draws.map((d) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('جایزه ${toman(d.prizeAmount)}'),
                      if (d.winnerName != null) Text('برنده: ${d.winnerName}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                      if (d.status != DrawStatus.completed && state.isAdmin) ...[
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.push('/draw-run', extra: d.id),
                          child: const Text('انتخاب برنده'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DrawRunScreen extends StatefulWidget {
  const DrawRunScreen({super.key, required this.drawId});
  final String drawId;
  @override
  State<DrawRunScreen> createState() => _DrawRunScreenState();
}

class _DrawRunScreenState extends State<DrawRunScreen> {
  Timer? _timer;
  String? spinningName;
  bool running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<HomeCubit>().state.members;
    return Scaffold(
      appBar: AppBar(title: const Text('انتخاب برنده')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('قرعه‌کشی شفاف است؛ یا تصادفی یا با انتخاب دستی مدیر.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.7)),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              child: Text(
                spinningName ?? '—',
                key: ValueKey(spinningName),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.navy),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: running
                  ? null
                  : () async {
                      setState(() => running = true);
                      var i = 0;
                      _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
                        if (members.isEmpty) return;
                        setState(() => spinningName = members[i % members.length].displayName);
                        i++;
                      });
                      await Future<void>.delayed(const Duration(seconds: 2));
                      _timer?.cancel();
                      if (!context.mounted) return;
                      await context.read<HomeCubit>().runDraw(widget.drawId);
                      if (context.mounted) context.pop();
                    },
              child: const Text('قرعه تصادفی'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final id = await showModalBottomSheet<String>(
                  context: context,
                  builder: (ctx) => ListView(
                    children: members.map((m) => ListTile(title: Text(m.displayName), onTap: () => Navigator.pop(ctx, m.userId))).toList(),
                  ),
                );
                if (id != null && context.mounted) {
                  await context.read<HomeCubit>().runDraw(widget.drawId, winnerId: id);
                  if (context.mounted) context.pop();
                }
              },
              child: const Text('انتخاب دستی'),
            ),
          ],
        ),
      ),
    );
  }
}

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
