import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/repositories/repositories.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/settings/settings_cubits.dart';
import '../../widgets/fund_switcher.dart';

/// مرکز تنظیمات: پروفایل، چندصندوقی، تم، اعلان، حقوقی، خروج.
class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRepository>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات'), actions: const [FundSwitcherButton()]),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              child: Text((user?.displayName.isNotEmpty ?? false) ? user!.displayName.substring(0, 1) : 'پ'),
            ),
            title: Text(user?.displayName ?? 'کاربر'),
            subtitle: Text(user?.phone ?? ''),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/profile'),
          ),
          const Divider(),
          const ListTile(title: Text('صندوق‌ها', style: TextStyle(fontWeight: FontWeight.w700))),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: AppColors.navy),
            title: const Text('تغییر صندوق فعال'),
            subtitle: const Text('یک کاربر می‌تواند در چند صندوق عضو باشد'),
            onTap: () => showFundSwitcher(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_home_outlined, color: AppColors.navy),
            title: const Text('ایجاد صندوق جدید'),
            onTap: () => context.push('/setup'),
          ),
          ListTile(
            leading: const Icon(Icons.link, color: AppColors.navy),
            title: const Text('پیوستن با لینک / کد دعوت'),
            onTap: () => context.push('/join'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: AppColors.navy),
            title: const Text('تنظیمات اعلان‌ها'),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: AppColors.navy),
            title: const Text('تم'),
            subtitle: const Text('روشن، تاریک یا سیستم'),
            onTap: () => context.push('/theme'),
          ),
          const ListTile(
            leading: Icon(Icons.language, color: AppColors.navy),
            title: Text('زبان'),
            subtitle: Text('نسخهٔ اول فقط فارسی'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined, color: AppColors.navy),
            title: const Text('صورتحساب کارمزد من'),
            onTap: () => context.push('/billing'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('قوانین و حریم خصوصی'),
            onTap: () => context.push('/legal'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('درباره ما'),
            onTap: () => context.push('/about'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('خروج از حساب', style: TextStyle(color: AppColors.danger)),
            onTap: () async {
              final ok = await confirmSheet(
                context,
                title: 'خروج',
                message: 'از حساب خارج می‌شوید.',
                confirmLabel: 'خروج',
                destructive: true,
              );
              if (ok && context.mounted) {
                await context.read<SessionCubit>().signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('تم')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('روشن'), icon: Icon(Icons.light_mode_outlined)),
            ButtonSegment(value: ThemeMode.dark, label: Text('تاریک'), icon: Icon(Icons.dark_mode_outlined)),
            ButtonSegment(value: ThemeMode.system, label: Text('سیستم'), icon: Icon(Icons.brightness_auto_outlined)),
          ],
          selected: {mode},
          onSelectionChanged: (s) => context.read<ThemeCubit>().setMode(s.first),
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationPrefsCubit(),
      child: BlocBuilder<NotificationPrefsCubit, NotificationPrefs>(
        builder: (context, state) {
          final cubit = context.read<NotificationPrefsCubit>();
          return Scaffold(
            appBar: AppBar(title: const Text('اعلان‌ها')),
            body: ListView(
              children: [
                SwitchListTile(
                  title: const Text('یادآوری اقساط'),
                  value: state.installment,
                  onChanged: cubit.setInstallment,
                ),
                SwitchListTile(
                  title: const Text('قرعه‌کشی'),
                  value: state.draw,
                  onChanged: cubit.setDraw,
                ),
                SwitchListTile(
                  title: const Text('صورتحساب کارمزد مدیر'),
                  value: state.fee,
                  onChanged: cubit.setFee,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قوانین و حریم خصوصی')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          'صندوق خانوادگی پولاد داده‌های مالی را برای مدیریت قرض‌الحسنه خانوادگی ذخیره می‌کند. '
          'تأیید تراکنش فقط با مدیر است. کارمزد نرم‌افزار مطابق شاپرک از واریز عضو کسر نمی‌شود. '
          'پیامک بانکی فقط با رضایت مدیر روی اندروید خوانده می‌شود. '
          'اسرار بانکیما روی سرور می‌ماند و به گوشی ارسال نمی‌شود.',
          style: TextStyle(height: 1.8),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره ما')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: PoladLogo(size: 88)),
          const SizedBox(height: 16),
          const Text('صندوق خانوادگی پولاد', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('نسخه ۱.۰.۰', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          Text('پشتیبانی: ${AppConfig.supportPhone}', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// انتخاب آواتار از گالری (مسیر محلی در دمو، Storage در تولید).
Future<void> pickAvatar(BuildContext context) async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
  if (file == null) return;
  final user = sl<AuthRepository>().currentUser;
  await sl<AuthRepository>().updateProfile(
    displayName: user?.displayName ?? '',
    avatarUrl: file.path,
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آواتار ذخیره شد')));
  }
}
