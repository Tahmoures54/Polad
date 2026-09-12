import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/app_blocs.dart';
import '../auth/auth_widgets.dart';

/// مقایسه پلن رایگان و پریمیوم برای مدیر.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final fund = state.fund;
        final premium = fund?.isPremium ?? false;
        return Scaffold(
          appBar: AppBar(title: const Text('اشتراک پولاد')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'پلن رایگان برای یک صندوق خانوادگی کوچک است. پریمیوم سقف اعضا و امکانات گزارش را باز می‌کند.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'رایگان',
                selected: !premium,
                items: const [
                  'تا ۱۰ عضو',
                  '۱ صندوق',
                  'ثبت پرداخت و تأیید مدیر',
                  'وام قرض‌الحسنه و اقساط',
                ],
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'پریمیوم',
                selected: premium,
                highlight: true,
                items: const [
                  'عضو نامحدود',
                  'چند صندوق برای یک مدیر',
                  'خروجی Excel و PDF',
                  'گزارش‌ها و امکانات پیشرفته',
                ],
              ),
              const SizedBox(height: 20),
              if (premium)
                const Text(
                  'این صندوق روی پلن پریمیوم است.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700),
                )
              else
                AuthPrimaryButton(
                  label: 'ارتقا به پریمیوم',
                  onPressed: () => context.read<HomeCubit>().upgradePremium(),
                ),
              const SizedBox(height: 12),
              Text(
                'سقف رایگان: ${faNum(AppConstants.freeMemberLimit)} عضو و ${faNum(AppConstants.freeFundLimit)} صندوق.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.items,
    required this.selected,
    this.highlight = false,
  });

  final String title;
  final List<String> items;
  final bool selected;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.navy : AppColors.divider, width: selected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: highlight ? AppColors.navy : AppColors.text,
                ),
              ),
              const Spacer(),
              if (selected) StatusChip(label: 'پلن فعلی', tone: ChipTone.info),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
