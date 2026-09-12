/// خطاهای لایه‌بندی‌شدهٔ پولاد برای الگوی Either / Result.
///
/// سمت چپِ [Either] همیشه یکی از این کلاس‌هاست تا UI بتواند پیام فارسی
/// مناسب نشان بدهد و منطق retry فقط روی خطاهای گذرا اجرا شود.
sealed class Failure {
  const Failure({required this.message, this.code, this.cause});

  /// متن قابل‌نمایش برای کاربر.
  final String message;

  /// کد پایدار (مثلاً `permission-denied`) برای لاگ و شاخه‌بندی.
  final String? code;

  /// خطای اصلی SDK در صورت وجود.
  final Object? cause;

  /// تبدیل استثناء SDK به Failure دامنه.
  factory Failure.from(Object error, [StackTrace? stackTrace]) {
    final text = error.toString();
    if (error is Failure) return error;

    final code = _readCode(error);
    if (_authCodes.contains(code) || text.contains('FirebaseAuth')) {
      return AuthFailure(message: _fa(code, text), code: code, cause: error);
    }
    if (_permissionCodes.contains(code)) {
      return PermissionFailure(message: _fa(code, text), code: code, cause: error);
    }
    if (code == 'not-found' || text.contains('not-found')) {
      return NotFoundFailure(message: 'مورد درخواستی پیدا نشد', code: code, cause: error);
    }
    if (_retryableCodes.contains(code) || _isNetwork(error)) {
      return NetworkFailure(message: 'ارتباط با سرور برقرار نشد. دوباره تلاش کنید.', code: code, cause: error);
    }
    if (text.contains('DioException') || text.contains('بانکیما')) {
      return ServerFailure(message: 'خطای بانکیما. دوباره تلاش کنید.', code: code ?? 'bankima', cause: error);
    }
    return ServerFailure(message: _fa(code, text), code: code, cause: error);
  }

  /// آیا ارزش تلاش مجدد دارد؟
  bool get isRetryable => switch (this) {
    NetworkFailure() => true,
    ServerFailure(:final code) => _retryableCodes.contains(code),
    _ => false,
  };

  static const _authCodes = {
    'unauthenticated',
    'user-disabled',
    'invalid-verification-code',
    'invalid-verification-id',
    'session-expired',
    'too-many-requests',
  };

  static const _permissionCodes = {'permission-denied', 'unauthorized'};

  static const _retryableCodes = {
    'unavailable',
    'deadline-exceeded',
    'resource-exhausted',
    'aborted',
    'internal',
  };

  static String? _readCode(Object error) {
    try {
      final dynamic e = error;
      final code = e.code;
      return code is String ? code : null;
    } catch (_) {
      return null;
    }
  }

  static bool _isNetwork(Object error) {
    final t = error.toString().toLowerCase();
    return t.contains('socket') ||
        t.contains('network') ||
        t.contains('timeout') ||
        t.contains('connection') ||
        t.contains('failed host lookup');
  }

  static String _fa(String? code, String fallback) {
    return switch (code) {
      'unauthenticated' => 'وارد نشده‌اید',
      'permission-denied' => 'اجازهٔ این کار را ندارید',
      'not-found' => 'مورد درخواستی پیدا نشد',
      'invalid-verification-code' => 'کد تأیید نادرست است',
      'too-many-requests' => 'تعداد درخواست‌ها زیاد است. کمی بعد تلاش کنید',
      'unavailable' => 'سرویس موقتاً در دسترس نیست',
      _ => 'خطایی رخ داد. دوباره تلاش کنید',
    };
  }
}

/// خطای ورود / OTP / نشست.
final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.cause});
}

/// قطع یا ناپایداری شبکه.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.cause});
}

/// پاسخ نامعتبر یا خطای سرور Firebase.
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.cause});
}

/// سند یا فایل پیدا نشد.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code, super.cause});
}

/// نقض قوانین امنیتی.
final class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code, super.cause});
}

/// وضعیت غیرمنتظره در کلاینت.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code, super.cause});
}
