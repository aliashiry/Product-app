import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An unexpected error occurred'});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'A server error occurred'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'A cache error occurred'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'A network error occurred. Please check your connection'});
}