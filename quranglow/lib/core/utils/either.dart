sealed class Either<L, R> {
  const Either();
  T match<T>(T Function(L l) left, T Function(R r) right);
  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
  @override
  T match<T>(T Function(L l) left, T Function(R r) right) => left(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
  @override
  T match<T>(T Function(L l) left, T Function(R r) right) => right(value);
}
