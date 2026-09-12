import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../../blocs/member/member_dashboard_cubit.dart';

/// کارت خلاصهٔ سهم / بدهی / طلب با ارقام فارسی.
class MemberStatCard extends StatelessWidget {
  const MemberStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            tomanCompact(value),
            style: TextStyle(
              fontFamily: 'VazirmatnFD',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// کارت قسط قابل کلیک با رنگ وضعیت.
class MemberInstallmentCard extends StatelessWidget {
  const MemberInstallmentCard({
    super.key,
    required this.item,
    this.memberName,
    this.onRemind,
  });

  final Installment item;
  final String? memberName;
  final VoidCallback? onRemind;

  String get _statusLabel => switch (item.status) {
        InstallmentStatus.paid => 'پرداخت‌شده',
        InstallmentStatus.overdue => 'معوق',
        InstallmentStatus.upcoming => 'در انتظار',
      };

  ChipTone get _tone => switch (item.status) {
        InstallmentStatus.paid => ChipTone.success,
        InstallmentStatus.overdue => ChipTone.danger,
        InstallmentStatus.upcoming => ChipTone.warning,
      };

  Color get _accent => switch (item.status) {
        InstallmentStatus.paid => AppColors.success,
        InstallmentStatus.overdue => AppColors.danger,
        InstallmentStatus.upcoming => AppColors.gold,
      };

  @override
  Widget build(BuildContext context) {
    final paid = item.status == InstallmentStatus.paid;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: paid ? null : () => context.push('/pay', extra: item.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName == null ? 'قسط ${faNum(item.sequence)}' : '$memberName — قسط ${faNum(item.sequence)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سررسید ${jalaliDate(item.dueDate)}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    toman(item.amount),
                    style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: _statusLabel, tone: _tone),
                ],
              ),
              if (onRemind != null && !paid) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'یادآوری دستی',
                  onPressed: onRemind,
                  icon: const Icon(Icons.notifications_active_outlined, color: AppColors.navy),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ردیف تاریخچهٔ تراکنش عضو.
class MemberTxTile extends StatelessWidget {
  const MemberTxTile({super.key, required this.tx});

  final MoneyTransaction tx;

  @override
  Widget build(BuildContext context) {
    final tone = switch (tx.status) {
      TransactionStatus.approved => ChipTone.success,
      TransactionStatus.rejected => ChipTone.danger,
      TransactionStatus.pending => ChipTone.warning,
    };
    return Card(
      child: ListTile(
        title: Text(tx.type.fa),
        subtitle: Text(
          '${jalaliDate(tx.occurredAt)} • کد ${faNum(tx.trackingCode ?? '—')}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(toman(tx.amount), style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            StatusChip(label: tx.status.fa, tone: tone),
          ],
        ),
      ),
    );
  }
}

/// فیلتر تاریخچه: همه / تأییدشده / در انتظار.
class TxHistoryFilterBar extends StatelessWidget {
  const TxHistoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TxHistoryFilter selected;
  final ValueChanged<TxHistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: TxHistoryFilter.values.map((f) {
        final isSelected = selected == f;
        return ChoiceChip(
          label: Text(f.label),
          selected: isSelected,
          selectedColor: AppColors.navy,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
          onSelected: (_) => onSelected(f),
        );
      }).toList(),
    );
  }
}
