import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/search_repository.dart';

class GetAllDocuments implements UseCase<List<Document>, NoParams> {
  final SearchRepository repository;

  GetAllDocuments(this.repository);

  @override
  Future<Either<Failure, List<Document>>> call(NoParams params) async {
    return await repository.getAllDocuments();
  }
}
