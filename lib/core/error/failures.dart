import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class DatabaseFailure extends Failure {
  final String message;
  
  const DatabaseFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class SearchFailure extends Failure {
  final String message;
  
  const SearchFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class AIModelFailure extends Failure {
  final String message;
  
  const AIModelFailure(this.message);
  
  @override
  List<Object> get props => [message];
}