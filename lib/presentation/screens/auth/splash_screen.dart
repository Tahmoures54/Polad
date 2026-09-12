import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/auth/splash_cubit.dart';
import '../../blocs/app_blocs.dart';

/// صفحهٔ آغازین: لوگو، بررسی نشست، هدایت به مسیر مناسب.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SplashCubit(session: ctx.read<SessionCubit>()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _go(SplashDestination dest) {
    final location = switch (dest) {
      SplashDestination.loading => null,
      SplashDestination.onboarding => '/onboarding',
      SplashDestination.login => '/login',
      SplashDestination.profileSetup => '/profile-setup',
      SplashDestination.setup => '/setup',
      SplashDestination.home => '/home',
    };
    if (location != null) context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (p, c) => p.destination != c.destination,
      listener: (context, state) => _go(state.destination),
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PoladLogo(size: 128),
                  const SizedBox(height: 24),
                  const Text(
                    'پولاد',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'صندوق خانوادگی، شفاف و آرام',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: AppColors.gold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
