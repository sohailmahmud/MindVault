import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/delete_document.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late DeleteDocument deleteDocument;
  late MockSearchRepository mockSearchRepository;
  const testId = 1;

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    deleteDocument = DeleteDocument(mockSearchRepository);
  });

  group('DeleteDocument', () {
    test('should delete document when repository call is successful', () async {
      // arrange
      when(() => mockSearchRepository.deleteDocument(any()))
          .thenAnswer((_) async => const Right(unit));

      // act
      final result =
          await deleteDocument(DeleteDocumentParams(documentId: testId));

      // assert
      expect(result, const Right(unit));
      verify(() => mockSearchRepository.deleteDocument(testId));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when repository call is unsuccessful',
        () async {
      // arrange
      const failure = DatabaseFailure('Delete failed');
      when(() => mockSearchRepository.deleteDocument(any()))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result =
          await deleteDocument(DeleteDocumentParams(documentId: testId));

      // assert
      expect(result, const Left(failure));
      verify(() => mockSearchRepository.deleteDocument(testId));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('DeleteDocumentParams should have correct props', () {
      const params = DeleteDocumentParams(documentId: testId);
      expect(params.props, [testId]);
    });

    test('DeleteDocumentParams equality should work correctly', () {
      const params1 = DeleteDocumentParams(documentId: testId);
      const params2 = DeleteDocumentParams(documentId: testId);
      const params3 = DeleteDocumentParams(documentId: 2);

      expect(params1, params2);
      expect(params1, isNot(params3));
    });
  });
}
