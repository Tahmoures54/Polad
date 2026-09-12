import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';

/// کارت دوره قرعه‌کشی.
class DrawCard extends StatelessWidget {
  const DrawCard({super.key, required this.draw, this.onRun});

  final FundDraw draw;
  final VoidCallback? onRun;

  @override
  Widget build(BuildContext context) {
    final done = draw.status == DrawStatus.completed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(draw.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                StatusChip(
                  label: draw.status.fa,
                  tone: done ? ChipTone.success : ChipTone.info,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('جایزه ${toman(draw.prizeAmount)}', style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${jalaliDate(draw.periodStart)} تا ${jalaliDate(draw.periodEnd)} • ${draw.mode.fa}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            if (draw.winnerName != null) ...[
              const SizedBox(height: 8),
              Text('برنده: ${draw.winnerName}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
            ],
            if (onRun != null && !done) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRun,
                icon: const Icon(Icons.casino_outlined),
                label: const Text('انتخاب برنده'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
