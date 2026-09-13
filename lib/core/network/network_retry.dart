import 'dart:async';
import 'dart:math';

import '../error/failure.dart';

/// تلاش مجدد نمایی برای عملیات شبکه.
///
/// خطاهای احراز هویت و مجوز هرگز تکرار نمی‌شوند تا قفل حساب یا اسپم OTP پیش نیاید.
class NetworkRetry {
  const NetworkRetry({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 350),
  });

  /// پیکربندی پیش‌فرض سرویس‌های Firebase (۳ تلاش با تأخیر نمایی).
  static const standard = NetworkRetry();

  final int maxAttempts;
  final Duration baseDelay;

  /// اجرای [action] تا موفقیت یا اتمام سقف تلاش.
  Future<T> run<T>(Future<T> Function() action) async {
    Object? lastError;
    StackTrace? lastStack;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await action();
      } catch (error, stack) {
        lastError = error;
        lastStack = stack;
        final failure = Failure.from(error, stack);
        final retryable = failure.isRetryable && attempt < maxAttempts;
        if (!retryable) {
          Error.throwWithStackTrace(error, stack);
        }
        final jitter = Random().nextInt(120);
        await Future<void>.delayed(baseDelay * (1 << (attempt - 1)) + Duration(milliseconds: jitter));
      }
    }
    Error.throwWithStackTrace(lastError!, lastStack ?? StackTrace.current);
  }
}
