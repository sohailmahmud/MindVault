import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/semantic_search.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late SemanticSearch semanticSearch;
  late MockSearchRepository mockSearchRepository;
  late List<Document> testDocuments;
  const testQuery = 'flutter bloc pattern';

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    semanticSearch = SemanticSearch(mockSearchRepository);
    testDocuments = [
      Document(
        id: 1,
        title: 'Flutter BLoC Pattern',
        content: 'BLoC is a design pattern',
        category: 'Development',
        tags: const ['flutter', 'bloc'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
      Document(
        id: 2,
        title: 'Another Document',
        content: 'Some other content',
        category: 'Other',
        tags: const ['other'],
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 4),
      ),
    ];
  });

  group('SemanticSearch', () {
    test('should return documents when semantic search is successful',
        () async {
      // arrange
      when(() => mockSearchRepository.semanticSearch(any()))
          .thenAnswer((_) async => Right(testDocuments));

      // act
      final result =
          await semanticSearch(SemanticSearchParams(query: testQuery));

      // assert
      expect(result, Right(testDocuments));
      verify(() => mockSearchRepository.semanticSearch(testQuery));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when semantic search is unsuccessful',
        () async {
      // arrange
      final failure = ServerFailure();
      when(() => mockSearchRepository.semanticSearch(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result =
          await semanticSearch(SemanticSearchParams(query: testQuery));

      // assert
      expect(result, Left(failure));
      verify(() => mockSearchRepository.semanticSearch(testQuery));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('SemanticSearchParams should have correct props', () {
      const params = SemanticSearchParams(query: testQuery);
      expect(params.props, [testQuery]);
    });

    test('SemanticSearchParams equality should work correctly', () {
      const params1 = SemanticSearchParams(query: testQuery);
      const params2 = SemanticSearchParams(query: testQuery);
      const params3 = SemanticSearchParams(query: 'different query');

      expect(params1, params2);
      expect(params1, isNot(params3));
    });
  });
}
