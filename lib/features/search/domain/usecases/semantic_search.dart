import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/search_repository.dart';

class SemanticSearch implements UseCase<List<Document>, SemanticSearchParams> {
  final SearchRepository repository;

  SemanticSearch(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(
      SemanticSearchParams params) async {
    return await repository.semanticSearch(params.query);
  }
}

class SemanticSearchParams extends Equatable {
  final String query;

  const SemanticSearchParams({required this.query});

  @override
  List<Object> get props => [query];
}
