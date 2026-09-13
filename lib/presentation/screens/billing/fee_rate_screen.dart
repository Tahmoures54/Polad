import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/services/finance_services.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/billing/fee_rate_cubit.dart';
import '../auth/auth_widgets.dart';

/// تنظیم نرخ کارمزد نرم‌افزار (۰٫۵٪ تا ۱٪) و حالت خیریه.
class FeeRateScreen extends StatelessWidget {
  const FeeRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fund = context.read<HomeCubit>().state.fund;
    return BlocProvider(
      create: (_) => FeeRateCubit(fund: fund),
      child: const _FeeRateView(),
    );
  }
}

class _FeeRateView extends StatelessWidget {
  const _FeeRateView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeeRateCubit, FeeRateState>(
      builder: (context, state) {
        final cubit = context.read<FeeRateCubit>();
        final preview = const FeeCalculator().softwareServiceFee(
          10000000,
          state.rate,
          charityZeroFee: state.charity,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('نرخ کارمزد نرم‌افزار')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(RevenueService.shaparakGuide, style: const TextStyle(color: AppColors.muted, height: 1.7)),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: state.charity,
                title: const Text('صندوق خیریه — کارمزد صفر'),
                subtitle: const Text('هیچ مبلغی از مدیر یا عضو بابت خدمات نرم‌افزار گرفته نمی‌شود.'),
                onChanged: cubit.charityChanged,
              ),
              const SizedBox(height: 8),
              Text(
                'نرخ صورتحساب مدیر: ${percentFa(state.rate)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Slider(
                value: state.rate,
                min: AppConstants.minServiceFeeRate,
                max: AppConstants.maxServiceFeeRate,
                divisions: 5,
                label: percentFa(state.rate),
                onChanged: state.charity ? null : cubit.rateChanged,
              ),
              Text(
                'نمونه: تراکنش ۱۰ میلیون تومانی → کارمزد مدیر ${toman(preview)} (از عضو ۰ تومان).',
                style: const TextStyle(color: AppColors.muted, height: 1.6),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'ذخیره در صندوق',
                onPressed: () async {
                  await context.read<HomeCubit>().saveServiceFee(rate: state.rate, charity: state.charity);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نرخ کارمزد ذخیره شد')));
                    context.pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
