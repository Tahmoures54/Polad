import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/draws/draw_run_cubit.dart';

/// صفحه انیمیشن انتخاب برنده.
class DrawRunScreen extends StatelessWidget {
  const DrawRunScreen({super.key, required this.drawId});

  final String drawId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DrawRunCubit(drawId: drawId),
      child: const _DrawRunView(),
    );
  }
}

class _DrawRunView extends StatelessWidget {
  const _DrawRunView();

  @override
  Widget build(BuildContext context) {
    final members = context.watch<HomeCubit>().state.members;
    return BlocConsumer<DrawRunCubit, DrawRunState>(
      listenWhen: (p, c) => p.error != c.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<DrawRunCubit>();
        final won = state.winner != null;
        return Scaffold(
          appBar: AppBar(title: const Text('انتخاب برنده')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'نام‌ها چند لحظه می‌چرخند؛ نتیجه فقط با اقدام مدیر ثبت می‌شود.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.7),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: won ? AppColors.gold : AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.navy.withValues(alpha: 0.2)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 90),
                    child: Text(
                      state.spinningName ?? '—',
                      key: ValueKey(state.spinningName),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
                if (won) ...[
                  const SizedBox(height: 16),
                  Text(
                    'برنده این دوره: ${state.winner!.winnerName}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.success),
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: state.running || won ? null : () => cubit.spinRandom(members),
                  child: Text(state.running ? 'در حال چرخش…' : 'قرعه تصادفی'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: state.running || won
                      ? null
                      : () async {
                          final id = await showModalBottomSheet<String>(
                            context: context,
                            builder: (ctx) => ListView(
                              children: members
                                  .map(
                                    (m) => ListTile(
                                      title: Text(m.displayName),
                                      onTap: () => Navigator.pop(ctx, m.userId),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                          if (id != null && context.mounted) cubit.pickManual(id);
                        },
                  child: const Text('انتخاب دستی'),
                ),
                if (won) ...[
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => context.pop(), child: const Text('بازگشت به فهرست')),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
