sealed class Result<T> {
  const Result();
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  });

  static Result<T> success<T>(T data) => _Success(data);
  static Result<T> failure<T>(String message) => _Failure(message);
}

final class _Success<T> extends Result<T> {
  final T data;
  const _Success(this.data);
  @override
  R when<R>({
    required R Function(T) success,
    required R Function(String) failure,
  }) => success(data);
}

final class _Failure<T> extends Result<T> {
  final String message;
  const _Failure(this.message);
  @override
  R when<R>({
    required R Function(T) success,
    required R Function(String) failure,
  }) => failure(message);
}
