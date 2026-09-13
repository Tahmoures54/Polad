import 'dart:async';

import 'package:dartz/dartz.dart';

import '../error/app_result.dart';
import '../error/failure.dart';
import '../network/network_retry.dart';

/// پوشش مشترک: retry + تبدیل استثناء به [AppResult].
Future<AppResult<T>> guardNetwork<T>(
  Future<T> Function() action, {
  NetworkRetry retry = const NetworkRetry(),
}) async {
  try {
    final value = await retry.run(action);
    return right(value);
  } catch (error, stack) {
    return left(Failure.from(error, stack));
  }
}

/// استریم فایراستور را به Either تبدیل می‌کند تا خطا، استریم را نکشد.
///
/// اگر [map] داده شود، تبدیل سند داخل try/catch انجام می‌شود تا قالب نامعتبر
/// هم به‌جای قطع استریم، [Failure] برگرداند.
Stream<AppResult<T>> guardSnapshots<S, T>(
  Stream<S> source, [
  T Function(S data)? map,
]) {
  return source.transform(
    StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        try {
          final value = map == null ? data as T : map(data);
          sink.add(right(value));
        } catch (error, stack) {
          sink.add(left(Failure.from(error, stack)));
        }
      },
      handleError: (error, stack, sink) => sink.add(left(Failure.from(error, stack))),
    ),
  );
}
