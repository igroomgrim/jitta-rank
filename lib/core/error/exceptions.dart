abstract class BaseException implements Exception {
  final String message;
  const BaseException({required this.message});
}

class ServerException extends BaseException {
  const ServerException([String message = 'Server Error'])
      : super(message: message);
}

class CacheException extends BaseException {
  const CacheException([String message = 'Cache Error'])
      : super(message: message);
}

class NetworkException extends BaseException {
  const NetworkException([String message = 'Network Error'])
      : super(message: message);
}

class SerializationException extends BaseException {
  const SerializationException([String message = 'Serialization Error'])
      : super(message: message);
}
