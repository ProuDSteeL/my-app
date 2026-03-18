sealed class Failure {
  const Failure([this.message]);
  final String? message;

  const factory Failure.server([String? message]) = ServerFailure;
  const factory Failure.network([String? message]) = NetworkFailure;
  const factory Failure.offline([String? message]) = OfflineFailure;
  const factory Failure.auth([String? message]) = AuthFailure;
  const factory Failure.cache([String? message]) = CacheFailure;
  const factory Failure.unknown([String? message]) = UnknownFailure;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class OfflineFailure extends Failure {
  const OfflineFailure([super.message]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}
