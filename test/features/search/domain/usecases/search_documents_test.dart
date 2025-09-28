import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/search_documents.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late SearchDocuments searchDocuments;
  late MockSearchRepository mockSearchRepository;
  late List<Document> testDocuments;
  const testQuery = 'flutter';

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    searchDocuments = SearchDocuments(mockSearchRepository);
    testDocuments = [
      Document(
        id: 1,
        title: 'Flutter Guide',
        content: 'A comprehensive Flutter guide',
        category: 'Development',
        tags: const ['flutter', 'guide'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];
  });

  group('SearchDocuments', () {
    test('should return documents when search is successful', () async {
      // arrange
      when(() => mockSearchRepository.searchDocuments(any()))
          .thenAnswer((_) async => Right(testDocuments));

      // act
      final result =
          await searchDocuments(const SearchParams(query: testQuery));

      // assert
      expect(result, Right(testDocuments));
      verify(() => mockSearchRepository.searchDocuments(testQuery));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when search is unsuccessful', () async {
      // arrange
      const failure = DatabaseFailure('Search failed');
      when(() => mockSearchRepository.searchDocuments(any()))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result =
          await searchDocuments(const SearchParams(query: testQuery));

      // assert
      expect(result, const Left(failure));
      verify(() => mockSearchRepository.searchDocuments(testQuery));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('SearchParams should have correct props', () {
      const params = SearchParams(query: testQuery);
      expect(params.props, [testQuery]);
    });

    test('SearchParams equality should work correctly', () {
      const params1 = SearchParams(query: testQuery);
      const params2 = SearchParams(query: testQuery);
      const params3 = SearchParams(query: 'different query');

      expect(params1, params2);
      expect(params1, isNot(params3));
    });
  });
}
