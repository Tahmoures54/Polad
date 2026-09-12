import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';
import 'draw_widgets.dart';

/// تاریخچه قرعه‌کشی‌های انجام‌شده.
class DrawHistoryScreen extends StatelessWidget {
  const DrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه قرعه‌کشی')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final done = state.draws.where((d) => d.status == DrawStatus.completed).toList()
            ..sort((a, b) => b.periodEnd.compareTo(a.periodEnd));
          if (done.isEmpty) {
            return const EmptyView(
              title: 'هنوز برنده‌ای ثبت نشده',
              subtitle: 'پس از اجرای قرعه، نام برنده و جایزه اینجا می‌ماند.',
              icon: Icons.emoji_events_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: done
                .map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DrawCard(draw: d),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
