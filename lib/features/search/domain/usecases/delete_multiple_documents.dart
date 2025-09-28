import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

class DeleteMultipleDocuments
    implements UseCase<Unit, DeleteMultipleDocumentsParams> {
  final SearchRepository repository;

  DeleteMultipleDocuments(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
      DeleteMultipleDocumentsParams params) async {
    return await repository.deleteMultipleDocuments(params.documentIds);
  }
}

class DeleteMultipleDocumentsParams extends Equatable {
  final List<int> documentIds;

  const DeleteMultipleDocumentsParams({required this.documentIds});

  @override
  List<Object> get props => [documentIds];
}
