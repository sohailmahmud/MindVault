import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/search_repository.dart';

class GetDocumentById implements UseCase<Document?, GetDocumentByIdParams> {
  final SearchRepository repository;

  GetDocumentById(this.repository);

  @override
  Future<Either<Failure, Document?>> call(GetDocumentByIdParams params) async {
    return await repository.getDocumentById(params.documentId);
  }
}

class GetDocumentByIdParams extends Equatable {
  final int documentId;

  const GetDocumentByIdParams({required this.documentId});

  @override
  List<Object> get props => [documentId];
}