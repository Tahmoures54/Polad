import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/repositories.dart';

class LoginState extends Equatable {
  const LoginState({
    this.phone = '',
    this.busy = false,
    this.error,
    this.otpSent = false,
    this.submitted = false,
  });

  final String phone;
  final bool busy;
  final String? error;
  final bool otpSent;
  final bool submitted;

  /// خطای زندهٔ شماره پس از اولین تلاش ارسال.
  String? get phoneError {
    if (!submitted && phone.isEmpty) return null;
    return Validators.phone(phone);
  }

  bool get canSubmit => Validators.phone(phone) == null && !busy;

  LoginState copyWith({
    String? phone,
    bool? busy,
    String? error,
    bool? otpSent,
    bool? submitted,
    bool clearError = false,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      otpSent: otpSent ?? this.otpSent,
      submitted: submitted ?? this.submitted,
    );
  }

  @override
  List<Object?> get props => [phone, busy, error, otpSent, submitted];
}

/// ورود با شماره موبایل ایران و درخواست OTP.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({AuthRepository? auth})
      : _auth = auth ?? sl<AuthRepository>(),
        super(const LoginState());

  final AuthRepository _auth;

  void phoneChanged(String value) {
    emit(state.copyWith(phone: IranianPhone.normalize(value), otpSent: false, clearError: true));
  }

  /// پر کردن سریع شمارهٔ آزمایشی.
  void fillDemo(String phone) => phoneChanged(phone);

  Future<void> submit() async {
    emit(state.copyWith(submitted: true, clearError: true));
    if (Validators.phone(state.phone) != null) return;
    emit(state.copyWith(busy: true));
    final res = await _auth.sendOtp(state.phone);
    res.when(
      ok: (_) => emit(state.copyWith(busy: false, otpSent: true)),
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }
}
