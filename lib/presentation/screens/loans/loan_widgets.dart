import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../../../domain/services/finance_services.dart';

ChipTone loanTone(LoanStatus status) => switch (status) {
      LoanStatus.requested => ChipTone.warning,
      LoanStatus.approved => ChipTone.info,
      LoanStatus.active => ChipTone.success,
      LoanStatus.rejected => ChipTone.danger,
      LoanStatus.closed => ChipTone.neutral,
    };

/// کارت وام عضو یا مدیر با وضعیت فارسی.
class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.loan,
    this.onTap,
    this.footer,
  });

  final Loan loan;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(loan.memberName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  StatusChip(label: loan.status.fa, tone: loanTone(loan.status)),
                ],
              ),
              const SizedBox(height: 8),
              Text(toman(loan.amount), style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                '${faNum(loan.termMonths)} قسط • ثبت ${jalaliDate(loan.requestedAt)}',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              if (loan.reason.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(loan.reason, style: const TextStyle(height: 1.5)),
              ],
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// پیش‌نمایش جدول اقساط با کارمزد اداری ۲٪.
class InstallmentPlanCard extends StatelessWidget {
  const InstallmentPlanCard({super.key, required this.plan, this.compact = true});

  final InstallmentPlan plan;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.mutedSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('جدول اقساط (قرض‌الحسنه)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              '۲٪ هزینه اداری صندوق است و بهره بانکی (ربا) نیست. روی اقساط سرشکن می‌شود.',
              style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 10),
            Text('اصل وام: ${toman(plan.principal)}'),
            Text('هزینه اداری صندوق: ${toman(plan.fee)}'),
            Text('جمع بازپرداخت: ${toman(plan.total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('قسط تقریبی: ${toman(plan.items.first.amount)}'),
            if (!compact) ...[
              const SizedBox(height: 12),
              ...plan.items.take(6).map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('قسط ${faNum(i.sequence)} — ${jalaliDate(i.dueDate)}')),
                          Text(toman(i.amount), style: const TextStyle(fontFamily: 'VazirmatnFD')),
                        ],
                      ),
                    ),
                  ),
              if (plan.items.length > 6)
                Text('و ${faNum(plan.items.length - 6)} قسط دیگر…', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
