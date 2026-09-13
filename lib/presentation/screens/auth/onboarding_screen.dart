import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/auth/onboarding_cubit.dart';
import 'auth_widgets.dart';

/// سه اسلاید معرفی با انیمیشن صفحه و نقاط پیشرفت.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.cubit});

  final OnboardingCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(value: cubit!, child: const _OnboardingView());
    }
    return BlocProvider(create: (_) => OnboardingCubit(), child: const _OnboardingView());
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _page = PageController();

  IconData _icon(String name) => switch (name) {
        'invite' => Icons.group_add_outlined,
        'verify' => Icons.verified_outlined,
        _ => Icons.shield_outlined,
      };

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: BlocConsumer<OnboardingCubit, OnboardingState>(
            listenWhen: (p, c) => p.index != c.index,
            listener: (context, state) {
              if (_page.hasClients && _page.page?.round() != state.index) {
                _page.animateToPage(
                  state.index,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<OnboardingCubit>();
              return Column(
                children: [
                  const PoladLogo(size: 72),
                  const SizedBox(height: 12),
                  const GoldHairline(),
                  Expanded(
                    child: PageView.builder(
                      controller: _page,
                      itemCount: state.pageCount,
                      onPageChanged: cubit.goTo,
                      itemBuilder: (_, i) {
                        final slide = OnboardingState.slides[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_icon(slide.iconName), size: 72, color: AppColors.gold),
                              const SizedBox(height: 28),
                              Text(
                                slide.title,
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide.body,
                                style: const TextStyle(color: AppColors.muted, height: 1.9, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(state.pageCount, (i) {
                      final active = i == state.index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.navy : AppColors.divider,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: state.isLast ? 'شروع' : 'بعدی',
                    onPressed: () async {
                      if (!state.isLast) {
                        cubit.next();
                        return;
                      }
                      await cubit.complete();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
