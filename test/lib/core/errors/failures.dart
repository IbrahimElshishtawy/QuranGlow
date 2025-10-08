abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure([super.message = 'Network error occurred']);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache error occurred']);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure([super.message = 'Unexpected error']);
}
