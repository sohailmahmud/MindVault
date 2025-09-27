import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/search_repository.dart';

class SearchDocuments implements UseCase<List<Document>, SearchParams> {
  final SearchRepository repository;

  SearchDocuments(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(SearchParams params) async {
    return await repository.searchDocuments(params.query);
  }
}

class SearchParams extends Equatable {
  final String query;

  const SearchParams({required this.query});

  @override
  List<Object> get props => [query];
}