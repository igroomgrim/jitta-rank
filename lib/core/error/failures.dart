import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server Failure']) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache Failure']) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network Failure']) : super(message: message);
}

class SerializationFailure extends Failure {
  const SerializationFailure([String message = 'Serialization Failure']) : super(message: message);
}