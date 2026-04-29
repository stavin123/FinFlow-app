/// App-level exceptions thrown in the Data layer.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred.']);
}

class NetworkException implements Exception {
  const NetworkException();
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred.']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication error.']);
}
