import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class PoladLogo extends StatelessWidget {
  const PoladLogo({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/polad_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText(this.value, {super.key, this.style, this.muted = false});
  final int value;
  final TextStyle? style;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      toman(value),
      textDirection: TextDirection.ltr,
      style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
        fontFamily: 'VazirmatnFD',
        color: muted ? AppColors.muted : AppColors.text,
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color = AppColors.navy,
  });

  final String title;
  final int value;
  final String? subtitle;
  final IconData? icon;
  final Color color;

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
          Row(
            children: [
              if (icon != null) Icon(icon, color: color, size: 18),
              if (icon != null) const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tomanCompact(value),
            style: TextStyle(
              fontFamily: 'VazirmatnFD',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});
  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      ChipTone.success => (AppColors.successSoft, AppColors.success),
      ChipTone.danger => (AppColors.dangerSoft, AppColors.danger),
      ChipTone.warning => (AppColors.warningSoft, AppColors.warning),
      ChipTone.neutral => (AppColors.mutedSurface, AppColors.muted),
      ChipTone.info => (const Color(0xFFE8F0FE), AppColors.info),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

enum ChipTone { success, danger, warning, neutral, info }

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.subtitle, this.icon = Icons.inbox_outlined});
  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.gold),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'در حال بارگذاری…'});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.navy),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AppColors.warningSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Text(
        'اتصال اینترنت ضعیف یا قطع است. آخرین داده‌های ذخیره‌شده نمایش داده می‌شود.',
        style: TextStyle(color: AppColors.warning, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          ?action,
        ],
      ),
    );
  }
}

Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأیید',
  bool destructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.muted, height: 1.7)),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? AppColors.danger : AppColors.navy,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
        ],
      ),
    ),
  );
  return result ?? false;
}

class PersianNumberField extends StatelessWidget {
  const PersianNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.number,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: 'VazirmatnFD', fontSize: 18, letterSpacing: 1),
      decoration: InputDecoration(labelText: label, hintText: hint, counterText: ''),
    );
  }
}

String faNum(Object v) => v.toString().toPersianDigit();
