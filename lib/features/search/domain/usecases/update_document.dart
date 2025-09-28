import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/search_repository.dart';

class UpdateDocument implements UseCase<Document, UpdateDocumentParams> {
  final SearchRepository repository;

  UpdateDocument(this.repository);

  @override
  Future<Either<Failure, Document>> call(UpdateDocumentParams params) async {
    // Update the timestamp
    final updatedDocument = params.document.copyWith(
      updatedAt: DateTime.now(),
    );
    return await repository.updateDocument(updatedDocument);
  }
}

class UpdateDocumentParams extends Equatable {
  final Document document;

  const UpdateDocumentParams({required this.document});

  @override
  List<Object> get props => [document];
}
