import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/auth/otp_cubit.dart';
import 'auth_widgets.dart';

/// وارد کردن کد ۶ رقمی OTP با شمارش معکوس و ارسال مجدد.
class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.phone, this.cubit});

  final String phone;
  final OtpCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(value: cubit!, child: const _OtpView());
    }
    return BlocProvider(
      create: (_) => OtpCubit(phone: phone),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (p, c) => p.error != c.error || p.verifiedUser != c.verifiedUser,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        final user = state.verifiedUser;
        if (user != null) {
          context.go(user.needsProfile ? '/profile-setup' : '/boot');
        }
      },
      builder: (context, state) {
        final cubit = context.read<OtpCubit>();
        return AuthScaffold(
          title: 'کد تأیید',
          subtitle: 'کد ۶ رقمی پیامک‌شده به ${iranianPhonePretty(state.phone)} را وارد کنید.',
          showLogo: false,
          appBar: AppBar(
            title: const Text('تأیید شماره'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => context.go('/login'),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OtpPinField(
                code: state.code,
                enabled: !state.busy,
                error: state.error != null,
                onChanged: cubit.codeChanged,
              ),
              const SizedBox(height: 16),
              Text(
                state.secondsLeft > 0
                    ? 'ارسال مجدد تا ${faNum(state.secondsLeft)} ثانیه دیگر'
                    : 'کد را دریافت نکردید؟',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.canResend ? cubit.resend : null,
                child: Text(
                  'ارسال مجدد کد',
                  style: TextStyle(
                    color: state.canResend ? AppColors.navy : AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AuthPrimaryButton(
                label: 'تأیید و ادامه',
                busy: state.busy,
                onPressed: cubit.verify,
              ),
              if (AppConfig.demoMode) ...[
                const SizedBox(height: 16),
                Text(
                  'کد آزمایشی: ${faNum(AppConstants.demoOtp)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
