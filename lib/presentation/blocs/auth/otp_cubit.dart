import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/locator.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/people.dart';
import '../../../domain/repositories/repositories.dart';

class OtpState extends Equatable {
  const OtpState({
    required this.phone,
    this.code = '',
    this.secondsLeft = AppConstants.otpResendSeconds,
    this.busy = false,
    this.error,
    this.verifiedUser,
  });

  final String phone;
  final String code;
  final int secondsLeft;
  final bool busy;
  final String? error;
  final UserProfile? verifiedUser;

  bool get canResend => secondsLeft <= 0 && !busy;
  bool get canVerify => Validators.otp(code) == null && !busy;
  bool get isVerified => verifiedUser != null;
  String? get codeError => code.isEmpty ? null : Validators.otp(code);

  OtpState copyWith({
    String? code,
    int? secondsLeft,
    bool? busy,
    String? error,
    UserProfile? verifiedUser,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return OtpState(
      phone: phone,
      code: code ?? this.code,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      verifiedUser: clearUser ? null : (verifiedUser ?? this.verifiedUser),
    );
  }

  @override
  List<Object?> get props => [phone, code, secondsLeft, busy, error, verifiedUser];
}

/// وارد کردن کد ۶ رقمی، شمارش معکوس و ارسال مجدد.
class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required String phone,
    AuthRepository? auth,
    this.resendSeconds = AppConstants.otpResendSeconds,
  })  : _auth = auth ?? sl<AuthRepository>(),
        super(OtpState(phone: phone, secondsLeft: resendSeconds)) {
    _startTimer();
  }

  final AuthRepository _auth;
  final int resendSeconds;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isClosed) {
        t.cancel();
        return;
      }
      if (state.secondsLeft <= 0) {
        t.cancel();
        return;
      }
      emit(state.copyWith(secondsLeft: state.secondsLeft - 1));
    });
  }

  void codeChanged(String raw) {
    final digits = Validators.toEnglishDigits(raw).replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > AppConstants.otpLength
        ? digits.substring(0, AppConstants.otpLength)
        : digits;
    emit(state.copyWith(code: clipped, clearError: true, clearUser: true));
    if (clipped.length == AppConstants.otpLength) {
      unawaited(verify());
    }
  }

  Future<void> verify() async {
    if (!state.canVerify) {
      emit(state.copyWith(error: Validators.otp(state.code)));
      return;
    }
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _auth.verifyOtp(phone: state.phone, smsCode: state.code);
    res.when(
      ok: (user) => emit(state.copyWith(busy: false, verifiedUser: user)),
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _auth.sendOtp(state.phone);
    res.when(
      ok: (_) {
        emit(state.copyWith(busy: false, secondsLeft: resendSeconds, code: ''));
        _startTimer();
      },
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
