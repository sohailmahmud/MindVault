import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/core/usecases/usecase.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/get_all_documents.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late GetAllDocuments getAllDocuments;
  late MockSearchRepository mockSearchRepository;
  late List<Document> testDocuments;

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    getAllDocuments = GetAllDocuments(mockSearchRepository);
    testDocuments = [
      Document(
        id: 1,
        title: 'Document 1',
        content: 'Content 1',
        category: 'Category 1',
        tags: const ['tag1'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
      Document(
        id: 2,
        title: 'Document 2',
        content: 'Content 2',
        category: 'Category 2',
        tags: const ['tag2'],
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 4),
      ),
    ];
  });

  group('GetAllDocuments', () {
    test('should return all documents when repository call is successful', () async {
      // arrange
      when(() => mockSearchRepository.getAllDocuments())
          .thenAnswer((_) async => Right(testDocuments));

      // act
      final result = await getAllDocuments(NoParams());

      // assert
      expect(result, Right(testDocuments));
      verify(() => mockSearchRepository.getAllDocuments());
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when repository call is unsuccessful', () async {
      // arrange
      final failure = DatabaseFailure('Failed to get documents');
      when(() => mockSearchRepository.getAllDocuments())
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await getAllDocuments(NoParams());

      // assert
      expect(result, Left(failure));
      verify(() => mockSearchRepository.getAllDocuments());
      verifyNoMoreInteractions(mockSearchRepository);
    });
  });
}