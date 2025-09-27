import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

class DeleteDocument implements UseCase<Unit, DeleteDocumentParams> {
  final SearchRepository repository;

  DeleteDocument(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteDocumentParams params) async {
    return await repository.deleteDocument(params.documentId);
  }
}

class DeleteDocumentParams extends Equatable {
  final int documentId;

  const DeleteDocumentParams({required this.documentId});

  @override
  List<Object> get props => [documentId];
}