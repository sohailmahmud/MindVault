import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/search_repository.dart';

class AddDocument implements UseCase<Document, AddDocumentParams> {
  final SearchRepository repository;

  AddDocument(this.repository);

  @override
  Future<Either<Failure, Document>> call(AddDocumentParams params) async {
    return await repository.addDocument(params.document);
  }
}

class AddDocumentParams extends Equatable {
  final Document document;

  const AddDocumentParams({required this.document});

  @override
  List<Object> get props => [document];
}