sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  String? get errorOrNull => switch (this) {
    Ok() => null,
    Err(:final message) => message,
  };

  R when<R>({required R Function(T value) ok, required R Function(String message) err}) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final message) => err(message),
    };
  }
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.message);
  final String message;
}

class AppFailure implements Exception {
  const AppFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}
