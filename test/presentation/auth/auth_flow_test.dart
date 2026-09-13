import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polad/core/theme/app_theme.dart';
import 'package:polad/core/utils/result.dart';
import 'package:polad/domain/entities/people.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/domain/repositories/repositories.dart';
import 'package:polad/presentation/blocs/app_blocs.dart';
import 'package:polad/presentation/blocs/auth/auth_blocs.dart';
import 'package:polad/presentation/screens/auth/auth_screens.dart';

class FakeAuth implements AuthRepository {
  FakeAuth({this.user, this.send = const Ok(null), UserProfile? verifyUser})
      : verifyUser = verifyUser ??
            UserProfile(
              id: 'u1',
              phone: '09120000000',
              displayName: '',
              createdAt: DateTime(2026, 1, 1),
            );

  UserProfile? user;
  Result<void> send;
  Result<void> update = const Ok(null);
  UserProfile verifyUser;
  var sendCount = 0;
  final controller = StreamController<UserProfile?>.broadcast();

  @override
  UserProfile? get currentUser => user;

  @override
  Stream<UserProfile?> authState() async* {
    yield user;
    yield* controller.stream;
  }

  @override
  Future<Result<void>> sendOtp(String phone) async {
    sendCount++;
    return send;
  }

  @override
  Future<Result<UserProfile>> verifyOtp({
    required String phone,
    required String smsCode,
    String? displayName,
  }) async {
    if (smsCode != '123456') return const Err('کد تأیید نادرست است');
    user = verifyUser.copyWith(displayName: displayName ?? verifyUser.displayName);
    return Ok(user!);
  }

  @override
  Future<Result<void>> updateProfile({required String displayName, String? avatarUrl}) async {
    user = user?.copyWith(displayName: displayName);
    return update;
  }

  @override
  Future<void> signOut() async {
    user = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  UserProfile profile({String name = '', List<String> funds = const []}) {
    return UserProfile(
      id: 'u1',
      phone: '09120000000',
      displayName: name,
      createdAt: DateTime(2026, 1, 1),
      fundIds: funds,
      activeFundId: funds.isEmpty ? null : funds.first,
    );
  }

  group('LoginCubit', () {
    test('rejects invalid iranian phone', () async {
      final cubit = LoginCubit(auth: FakeAuth());
      cubit.phoneChanged('123');
      await cubit.submit();
      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.phoneError, isNotNull);
      await cubit.close();
    });

    test('sends otp for valid phone', () async {
      final cubit = LoginCubit(auth: FakeAuth());
      cubit.phoneChanged('۰۹۱۲۰۰۰۰۰۰۰');
      expect(cubit.state.phone, '09120000000');
      await cubit.submit();
      expect(cubit.state.otpSent, isTrue);
      await cubit.close();
    });
  });

  group('OtpCubit', () {
    test('verifies demo code and counts down', () async {
      final cubit = OtpCubit(phone: '09120000000', auth: FakeAuth(), resendSeconds: 2);
      expect(cubit.state.secondsLeft, 2);
      cubit.codeChanged('۱۲۳۴۵۶');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.verifiedUser, isNotNull);
      expect(cubit.state.verifiedUser!.needsProfile, isTrue);
      await cubit.close();
    });

    test('resend waits for countdown', () async {
      final auth = FakeAuth();
      final cubit = OtpCubit(phone: '09120000000', auth: auth, resendSeconds: 1);
      expect(cubit.state.canResend, isFalse);
      await cubit.resend();
      expect(auth.sendCount, 0);
      await cubit.close();
    });
  });

  group('ProfileSetupCubit', () {
    test('first user defaults to admin and saves name', () async {
      final auth = FakeAuth(user: profile());
      final cubit = ProfileSetupCubit(auth: auth);
      expect(cubit.state.role, UserRole.admin);
      expect(cubit.state.isFirstUser, isTrue);
      cubit.nameChanged('طهمورث');
      await cubit.save();
      expect(cubit.state.saved, isTrue);
      expect(auth.currentUser?.displayName, 'طهمورث');
      await cubit.close();
    });

    test('rejects short name', () async {
      final cubit = ProfileSetupCubit(auth: FakeAuth(user: profile()));
      cubit.nameChanged('ا');
      await cubit.save();
      expect(cubit.state.saved, isFalse);
      expect(cubit.state.nameError, isNotNull);
      await cubit.close();
    });
  });

  group('SplashCubit', () {
    test('guides guest after onboarding to login', () async {
      final session = SessionCubit(auth: FakeAuth());
      if (session.state.booting) {
        await session.stream.firstWhere((s) => !s.booting);
      }
      final cubit = SplashCubit(
        session: session,
        onboardingDone: () => true,
        minDisplay: Duration.zero,
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.destination, SplashDestination.login);
      await cubit.close();
      await session.close();
    });

    test('guides named member with fund to home', () async {
      final session = SessionCubit(auth: FakeAuth(user: profile(name: 'مریم', funds: const ['f1'])));
      if (session.state.booting) {
        await session.stream.firstWhere((s) => !s.booting);
      }
      final cubit = SplashCubit(
        session: session,
        onboardingDone: () => true,
        minDisplay: Duration.zero,
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.destination, SplashDestination.home);
      await cubit.close();
      await session.close();
    });
  });

  group('OnboardingCubit', () {
    test('walks three slides', () {
      final cubit = OnboardingCubit();
      expect(cubit.state.pageCount, 3);
      expect(cubit.state.current.title, 'ساده برای همه');
      cubit.next();
      expect(cubit.state.current.title, 'کار مدیر کم');
      cubit.next();
      expect(cubit.state.isLast, isTrue);
      expect(cubit.state.current.title, 'حساب برای همه روشن');
    });
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('fa', 'IR'),
      home: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }

  group('auth screens', () {
    testWidgets('login shows iranian phone field', (tester) async {
      final cubit = LoginCubit(auth: FakeAuth());
      await tester.pumpWidget(wrap(LoginScreen(cubit: cubit)));
      expect(find.text('ورود به پولاد'), findsOneWidget);
      expect(find.text('شماره موبایل'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '0912');
      await tester.tap(find.text('دریافت کد تأیید'));
      await tester.pump();
      expect(cubit.state.phoneError, isNotNull);
      await cubit.close();
    });

    testWidgets('onboarding shows first slide and next', (tester) async {
      final cubit = OnboardingCubit();
      await tester.pumpWidget(wrap(OnboardingScreen(cubit: cubit)));
      expect(find.text('ساده برای همه'), findsOneWidget);
      await tester.tap(find.text('بعدی'));
      await tester.pumpAndSettle();
      expect(cubit.state.index, 1);
      expect(find.text('کار مدیر کم'), findsWidgets);
      await cubit.close();
    });

    testWidgets('otp shows six boxes and countdown', (tester) async {
      final cubit = OtpCubit(phone: '09120000000', auth: FakeAuth(), resendSeconds: 60);
      await tester.pumpWidget(wrap(OtpScreen(phone: '09120000000', cubit: cubit)));
      expect(find.text('کد تأیید'), findsOneWidget);
      expect(find.textContaining('ارسال مجدد'), findsWidgets);
      await cubit.close();
    });

    testWidgets('profile setup shows admin and member roles', (tester) async {
      final cubit = ProfileSetupCubit(auth: FakeAuth(user: profile()));
      await tester.pumpWidget(
        wrap(
          BlocProvider<SessionCubit>(
            create: (_) => SessionCubit(auth: FakeAuth(user: profile())),
            child: ProfileSetupScreen(cubit: cubit),
          ),
        ),
      );
      expect(find.text('ساخت پروفایل'), findsOneWidget);
      expect(find.text('مدیر صندوق'), findsOneWidget);
      expect(find.text('عضو'), findsOneWidget);
      await cubit.close();
    });
  });
}
