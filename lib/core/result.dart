/// 操作结果包装类
/// 用于统一处理成功和失败的情况
sealed class Result<T> {
  const Result();

  /// 成功结果
  factory Result.success(T data) = Success<T>;

  /// 失败结果
  factory Result.failure(Exception exception) = Failure<T>;

  /// 映射结果
  Result<U> map<U>(U Function(T) transform) {
    return switch (this) {
      Success(data: final data) => Result.success(transform(data)),
      Failure(exception: final exception) => Result.failure(exception),
    };
  }

  /// 获取数据或异常
  T? getOrNull() {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => null,
    };
  }

  /// 获取异常或 null
  Exception? getExceptionOrNull() {
    return switch (this) {
      Success() => null,
      Failure(exception: final exception) => exception,
    };
  }

  /// 是否成功
  bool get isSuccess => this is Success<T>;

  /// 是否失败
  bool get isFailure => this is Failure<T>;
}

/// 成功结果
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

/// 失败结果
final class Failure<T> extends Result<T> {
  final Exception exception;

  const Failure(this.exception);
}
