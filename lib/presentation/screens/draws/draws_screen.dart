import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';
import 'draw_widgets.dart';

/// مدیریت قرعه‌کشی: ایجاد دوره و فهرست دوره‌ها.
class DrawsScreen extends StatelessWidget {
  const DrawsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قرعه‌کشی'),
        actions: [
          IconButton(
            tooltip: 'تاریخچه',
            onPressed: () => context.push('/draw-history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      floatingActionButton: context.watch<HomeCubit>().state.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/draw-create'),
              label: const Text('دوره جدید'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final open = state.draws.where((d) => d.status != DrawStatus.completed && d.status != DrawStatus.cancelled).toList();
          return RefreshIndicator(
            color: AppColors.navy,
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: open.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      EmptyView(
                        title: 'دوره بازی نیست',
                        subtitle: 'یک دوره بسازید و برنده را تصادفی یا دستی انتخاب کنید.',
                        icon: Icons.casino_outlined,
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'قرعه شفاف است. برنده هیچ‌گاه خودکار انتخاب نمی‌شود مگر با اقدام مدیر.',
                        style: TextStyle(color: AppColors.muted, height: 1.7),
                      ),
                      const SizedBox(height: 12),
                      ...open.map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DrawCard(
                            draw: d,
                            onRun: state.isAdmin ? () => context.push('/draw-run', extra: d.id) : null,
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
