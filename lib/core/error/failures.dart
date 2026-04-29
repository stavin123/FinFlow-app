/// Base Failure sealed class for Clean Architecture error handling.
abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'An unexpected server error occurred.'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local cache error occurred.'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'The requested resource was not found.'});
}
