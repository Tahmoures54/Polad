import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/auth/login_cubit.dart';
import 'auth_widgets.dart';

/// ورود با شماره موبایل ایران.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.cubit});

  final LoginCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(value: cubit!, child: const _LoginView());
    }
    return BlocProvider(create: (_) => LoginCubit(), child: const _LoginView());
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (p, c) => p.otpSent != c.otpSent || p.error != c.error || p.phone != c.phone,
      listener: (context, state) {
        if (state.phone.isNotEmpty && _phone.text != state.phone) {
          _phone.text = state.phone;
          _phone.selection = TextSelection.collapsed(offset: _phone.text.length);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.otpSent) {
          context.go('/otp', extra: state.phone);
        }
      },
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();
        return AuthScaffold(
          title: 'ورود به پولاد',
          subtitle: 'فقط با شماره موبایل وارد شوید. کد تأیید پیامک می‌شود.',
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩]')),
                  ],
                  style: const TextStyle(fontFamily: 'VazirmatnFD', fontSize: 20, letterSpacing: 1.2),
                  decoration: InputDecoration(
                    labelText: 'شماره موبایل',
                    hintText: '۰۹۱۲۱۲۳۴۵۶۷',
                    counterText: '',
                    errorText: state.phoneError,
                    prefixIcon: const Icon(Icons.phone_iphone_outlined, color: AppColors.navy),
                  ),
                  validator: Validators.phone,
                  onChanged: cubit.phoneChanged,
                  onFieldSubmitted: (_) => cubit.submit(),
                ),
                const SizedBox(height: 24),
                AuthPrimaryButton(
                  label: 'دریافت کد تأیید',
                  busy: state.busy,
                  onPressed: cubit.submit,
                ),
                if (AppConfig.demoMode) ...[
                  const SizedBox(height: 20),
                  Text(
                    'حالت آزمایشی: کد ${faNum(AppConstants.demoOtp)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      cubit.fillDemo(AppConstants.demoAdminPhone);
                      cubit.submit();
                    },
                    child: Text('ورود آزمایشی مدیر ${faNum(AppConstants.demoAdminPhone)}'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      cubit.fillDemo(AppConstants.demoMemberPhone);
                      cubit.submit();
                    },
                    child: Text('ورود آزمایشی عضو ${faNum(AppConstants.demoMemberPhone)}'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
