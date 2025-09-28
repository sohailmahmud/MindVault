import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/delete_multiple_documents.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late DeleteMultipleDocuments deleteMultipleDocuments;
  late MockSearchRepository mockSearchRepository;
  late DeleteMultipleDocumentsParams testParams;

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    deleteMultipleDocuments = DeleteMultipleDocuments(mockSearchRepository);
    testParams = const DeleteMultipleDocumentsParams(documentIds: [1, 2, 3]);
  });

  group('DeleteMultipleDocuments', () {
    test('should delete multiple documents when repository call is successful',
        () async {
      // arrange
      when(() => mockSearchRepository.deleteMultipleDocuments(any()))
          .thenAnswer((_) async => const Right(unit));

      // act
      final result = await deleteMultipleDocuments(testParams);

      // assert
      expect(result, const Right(unit));
      verify(() => mockSearchRepository.deleteMultipleDocuments([1, 2, 3]));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when repository call is unsuccessful',
        () async {
      // arrange
      final failure = DatabaseFailure('Failed to delete documents');
      when(() => mockSearchRepository.deleteMultipleDocuments(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await deleteMultipleDocuments(testParams);

      // assert
      expect(result, Left(failure));
      verify(() => mockSearchRepository.deleteMultipleDocuments([1, 2, 3]));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should pass correct document IDs to repository', () async {
      // arrange
      when(() => mockSearchRepository.deleteMultipleDocuments(any()))
          .thenAnswer((_) async => const Right(unit));

      // act
      await deleteMultipleDocuments(testParams);

      // assert
      verify(() => mockSearchRepository.deleteMultipleDocuments([1, 2, 3]));
      verifyNoMoreInteractions(mockSearchRepository);
    });
  });

  group('DeleteMultipleDocumentsParams', () {
    test('should support equality comparison', () {
      // arrange
      const params1 = DeleteMultipleDocumentsParams(documentIds: [1, 2, 3]);
      const params2 = DeleteMultipleDocumentsParams(documentIds: [1, 2, 3]);

      // assert
      expect(params1, equals(params2));
    });

    test('should have correct props for equality', () {
      // arrange
      const params = DeleteMultipleDocumentsParams(documentIds: [1, 2, 3]);

      // assert
      expect(params.props, [
        [1, 2, 3]
      ]);
    });

    test('should not be equal when document IDs are different', () {
      // arrange
      const params1 = DeleteMultipleDocumentsParams(documentIds: [1, 2, 3]);
      const params2 = DeleteMultipleDocumentsParams(documentIds: [4, 5, 6]);

      // assert
      expect(params1, isNot(equals(params2)));
    });
  });
}
