import 'package:dartz/dartz.dart';

import '../utils/result.dart';
import 'failure.dart';

/// الگوی نتیجهٔ سرویس‌های پولاد: چپ = Failure، راست = موفقیت.
typedef AppResult<T> = Either<Failure, T>;

/// تبدیل Either به Result موجود در لایهٔ نمایش.
extension AppResultX<T> on AppResult<T> {
  /// معادل [Ok] / [Err] برای کدهایی که هنوز Either مصرف نمی‌کنند.
  Result<T> toResult() => fold((f) => Err(f.message), Ok.new);

  bool get isSuccess => isRight();
  bool get isFailure => isLeft();

  T? get valueOrNull => fold((_) => null, (v) => v);
  Failure? get failureOrNull => fold((f) => f, (_) => null);
}

/// تبدیل Result قدیمی به Either.
extension ResultToAppResult<T> on Result<T> {
  AppResult<T> toEither() => when(
        ok: right,
        err: (m) => left(UnexpectedFailure(message: m)),
      );
}
