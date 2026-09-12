import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/auth/profile_setup_cubit.dart';
import 'auth_widgets.dart';

/// نام نمایشی و انتخاب نقش؛ اولین کاربر صندوق مدیر است.
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key, this.cubit});

  final ProfileSetupCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(value: cubit!, child: const _ProfileSetupView());
    }
    return BlocProvider(create: (_) => ProfileSetupCubit(), child: const _ProfileSetupView());
  }
}

class _ProfileSetupView extends StatelessWidget {
  const _ProfileSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
      listenWhen: (p, c) => p.saved != c.saved || p.error != c.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.saved) {
          context.read<SessionCubit>().reload();
          context.go('/setup');
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProfileSetupCubit>();
        return AuthScaffold(
          title: 'ساخت پروفایل',
          subtitle: state.isFirstUser
              ? 'اولین کاربر صندوق مدیر می‌شود. اگر با کد دعوت می‌آیید، نقش عضو را انتخاب کنید.'
              : 'نام خود را وارد کنید تا اعضای صندوق شما را بشناسند.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: state.name,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'نام و نام خانوادگی',
                  hintText: 'مثلاً طهمورث پوردهقان',
                  errorText: state.nameError,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.navy),
                ),
                onChanged: cubit.nameChanged,
              ),
              const SizedBox(height: 20),
              Text('نقش شما', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              _RoleCard(
                selected: state.role == UserRole.admin,
                title: 'مدیر صندوق',
                subtitle: 'ایجاد صندوق، تأیید پرداخت‌ها، وام و گزارش',
                icon: Icons.admin_panel_settings_outlined,
                onTap: () => cubit.roleChanged(UserRole.admin),
              ),
              const SizedBox(height: 10),
              _RoleCard(
                selected: state.role == UserRole.member,
                title: 'عضو',
                subtitle: 'پیوستن با کد دعوت و ثبت پرداخت سهم',
                icon: Icons.people_outline,
                onTap: () => cubit.roleChanged(UserRole.member),
              ),
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: 'ادامه',
                busy: state.busy,
                onPressed: cubit.save,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.divider,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.navy : AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.gold : AppColors.divider,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
