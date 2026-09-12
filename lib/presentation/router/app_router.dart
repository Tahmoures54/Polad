import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/locator.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/local/cache_store.dart';
import '../blocs/app_blocs.dart';
import '../screens/auth/auth_screens.dart';
import '../screens/home/home_screens.dart';
import '../screens/loans/loan_screens.dart';
import '../screens/reports/report_screens.dart';
import '../screens/settings/settings_screens.dart';

final _root = GlobalKey<NavigatorState>();

GoRouter createRouter(SessionCubit session) {
  return GoRouter(
    navigatorKey: _root,
    initialLocation: '/',
    refreshListenable: _GoRefresh(session),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final s = session.state;
      final onboarding = sl<CacheStore>().onboardingDone;
      if (loc == '/') return null;
      if (s.booting && loc != '/') return '/';
      if (!onboarding && loc != '/onboarding' && loc != '/') {
        return '/onboarding';
      }
      if (!s.authenticated &&
          loc != '/login' &&
          loc != '/otp' &&
          loc != '/onboarding' &&
          loc != '/') {
        return '/login';
      }
      if (s.authenticated && (loc == '/login' || loc == '/otp')) {
        return s.needsProfile ? '/profile-setup' : '/boot';
      }
      if (s.authenticated &&
          s.needsProfile &&
          loc != '/profile-setup' &&
          loc != '/boot' &&
          loc != '/') {
        return '/profile-setup';
      }
      if (s.authenticated &&
          !s.needsProfile &&
          !s.hasFund &&
          loc != '/setup' &&
          loc != '/boot' &&
          loc != '/') {
        return '/setup';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra;
          final phone = extra is String
              ? extra
              : extra is Map
                  ? extra['phone']?.toString() ?? ''
                  : '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(path: '/profile-setup', builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: '/setup', builder: (_, _) => const FundSetupScreen()),
      GoRoute(path: '/boot', builder: (_, _) => const _BootScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const _Authed(index: 0, child: _HomeSwitch()),
      ),
      GoRoute(path: '/pending', builder: (_, _) => const _Authed(index: 1, child: PendingScreen())),
      GoRoute(path: '/members', builder: (_, _) => const _Authed(index: 2, child: MembersScreen())),
      GoRoute(path: '/installments', builder: (_, _) => const _Authed(index: 1, child: InstallmentsScreen())),
      GoRoute(path: '/pay', builder: (_, state) => _Authed(index: 2, child: PaymentScreen(installmentId: state.extra as String?))),
      GoRoute(path: '/more', builder: (_, _) => const _Authed(index: 3, child: MoreScreen())),
      GoRoute(path: '/loans', builder: (_, _) => const LoansScreen()),
      GoRoute(path: '/loan-request', builder: (_, _) => const LoanRequestScreen()),
      GoRoute(path: '/draws', builder: (_, _) => const DrawsScreen()),
      GoRoute(path: '/draw-run', builder: (_, state) => DrawRunScreen(drawId: state.extra as String? ?? '')),
      GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
      GoRoute(path: '/billing', builder: (_, _) => const BillingScreen()),
      GoRoute(path: '/fund-settings', builder: (_, _) => const FundSettingsScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/sms', builder: (_, _) => const SmsMatchScreen()),
      GoRoute(path: '/join', builder: (_, _) => const FundSetupScreen()),
    ],
  );
}

class _GoRefresh extends ChangeNotifier {
  _GoRefresh(SessionCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}

class _BootScreen extends StatefulWidget {
  const _BootScreen();
  @override
  State<_BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<_BootScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<SessionCubit>().state;
      if (!s.authenticated) {
        context.go('/login');
      } else if (!s.hasFund) {
        context.go('/setup');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: LoadingView());
}

class _HomeSwitch extends StatelessWidget {
  const _HomeSwitch();
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<HomeCubit>().state.isAdmin;
    return admin ? const AdminDashboard() : const MemberDashboard();
  }
}

class _Authed extends StatelessWidget {
  const _Authed({required this.child, required this.index});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final user = session.user;
    final fundId = user?.activeFundId;
    if (user == null || fundId == null) {
      return const Scaffold(body: LoadingView());
    }
    return HomeShell(index: index, child: child);
  }
}
