import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../data/local/cache_store.dart';
import '../app_blocs.dart';

/// مقصد بعدی پس از نمایش لوگو.
enum SplashDestination {
  /// هنوز وضعیت نشست مشخص نیست.
  loading,

  /// کاربر اسلایدهای معرفی را ندیده است.
  onboarding,

  /// مهمان است.
  login,

  /// وارد شده ولی نام ندارد.
  profileSetup,

  /// وارد شده ولی صندوق فعال ندارد.
  setup,

  /// آمادهٔ داشبورد.
  home,
}

class SplashState extends Equatable {
  const SplashState({this.destination = SplashDestination.loading});
  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}

/// بررسی احراز هویت و هدایت از صفحهٔ آغازین.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this.session,
    bool Function()? onboardingDone,
    this.minDisplay = const Duration(milliseconds: 1400),
  })  : _onboardingDone = onboardingDone ?? (() => sl<CacheStore>().onboardingDone),
        super(const SplashState()) {
    _start();
  }

  final SessionCubit session;
  final bool Function() _onboardingDone;
  final Duration minDisplay;
  StreamSubscription<SessionState>? _sub;

  Future<void> _start() async {
    await Future<void>.delayed(minDisplay);
    if (isClosed) return;
    _emitFor(session.state);
    _sub = session.stream.listen(_emitFor);
  }

  void _emitFor(SessionState session) {
    if (isClosed) return;
    if (session.booting) {
      emit(const SplashState(destination: SplashDestination.loading));
      return;
    }
    if (!_onboardingDone()) {
      emit(const SplashState(destination: SplashDestination.onboarding));
      return;
    }
    if (!session.authenticated) {
      emit(const SplashState(destination: SplashDestination.login));
      return;
    }
    if (session.needsProfile) {
      emit(const SplashState(destination: SplashDestination.profileSetup));
      return;
    }
    if (!session.hasFund) {
      emit(const SplashState(destination: SplashDestination.setup));
      return;
    }
    emit(const SplashState(destination: SplashDestination.home));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
