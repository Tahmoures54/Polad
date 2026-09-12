import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local/cache_store.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/app_blocs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      context.go('/boot');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PoladLogo(size: 120),
            SizedBox(height: 24),
            Text('پولاد', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('صندوق خانوادگی، شفاف و آرام', style: TextStyle(color: AppColors.goldLight, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  static const _pages = [
    (Icons.shield_outlined, 'صندوق بسازید', 'در کمتر از یک دقیقه صندوق خانوادگی خود را با سهم مشخص و حساب شفاف ایجاد کنید.'),
    (Icons.group_add_outlined, 'اعضا را دعوت کنید', 'با یک کد کوتاه، اعضای خانواده را اضافه کنید. هر کس فقط اطلاعات خودش را می‌بیند.'),
    (Icons.verified_outlined, 'مدیریت شفاف', 'پرداخت‌ها با تأیید مدیر ثبت می‌شود. موجودی، وام و معوقات همیشه در دسترس همه است.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              const Align(alignment: Alignment.center, child: PoladLogo(size: 72)),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.$1, size: 64, color: AppColors.gold),
                        const SizedBox(height: 24),
                        Text(p.$2, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(p.$3, style: const TextStyle(color: AppColors.muted, height: 1.8, fontSize: 16), textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.navy : AppColors.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  if (_index < _pages.length - 1) {
                    _page.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                  } else {
                    sl<CacheStore>().setOnboardingDone();
                    context.go('/login');
                  }
                },
                child: Text(_index == _pages.length - 1 ? 'شروع' : 'بعدی'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  final name = TextEditingController();

  @override
  void dispose() {
    phone.dispose();
    otp.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthFormState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('ورود به پولاد')),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('فقط با شماره موبایل وارد شوید. پیامک کد تأیید می‌آید.', style: TextStyle(color: AppColors.muted, height: 1.7)),
                const SizedBox(height: 24),
                PersianNumberField(
                  controller: phone,
                  label: 'شماره موبایل',
                  hint: '۰۹۱۲۱۲۳۴۵۶۷',
                  maxLength: 11,
                  validator: null,
                ),
                if (state.codeSent) ...[
                  const SizedBox(height: 12),
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی')),
                  const SizedBox(height: 12),
                  PersianNumberField(controller: otp, label: 'کد تأیید', maxLength: 6),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.busy
                      ? null
                      : () async {
                          final cubit = context.read<AuthCubit>();
                          if (!state.codeSent) {
                            await cubit.sendOtp(phone.text.trim());
                          } else {
                            final ok = await cubit.verify(otp.text.trim(), name: name.text.trim());
                            if (ok && context.mounted) context.go('/boot');
                          }
                        },
                  child: state.busy
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(state.codeSent ? 'ورود' : 'دریافت کد'),
                ),
                const SizedBox(height: 16),
                if (!state.codeSent)
                  Text('حالت آزمایشی: کد ${AppConstants.demoOtp}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    phone.text = AppConstants.demoAdminPhone;
                    context.read<AuthCubit>().sendOtp(AppConstants.demoAdminPhone);
                  },
                  child: const Text('ورود آزمایشی مدیر'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    phone.text = AppConstants.demoMemberPhone;
                    context.read<AuthCubit>().sendOtp(AppConstants.demoMemberPhone);
                  },
                  child: const Text('ورود آزمایشی عضو'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
