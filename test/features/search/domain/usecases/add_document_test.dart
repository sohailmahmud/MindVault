import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/add_document.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class FakeDocument extends Fake implements Document {}

void main() {
  late AddDocument addDocument;
  late MockSearchRepository mockSearchRepository;
  late AddDocumentParams testParams;
  late Document testDocument;

  setUpAll(() {
    registerFallbackValue(FakeDocument());
  });

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    addDocument = AddDocument(mockSearchRepository);
    testDocument = Document(
      id: 1,
      title: 'Test Title',
      content: 'Test Content',
      category: 'Test Category',
      tags: const ['tag1', 'tag2'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    testParams = AddDocumentParams(document: testDocument);
  });

  group('AddDocument', () {
    test('should add document successfully when repository call succeeds', () async {
      // arrange
      when(() => mockSearchRepository.addDocument(any()))
          .thenAnswer((_) async => Right(testDocument));

      // act
      final result = await addDocument(testParams);

      // assert
      expect(result, Right(testDocument));
      verify(() => mockSearchRepository.addDocument(testDocument));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when repository call fails', () async {
      // arrange
      final failure = DatabaseFailure('Failed to add document');
      when(() => mockSearchRepository.addDocument(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await addDocument(testParams);

      // assert
      expect(result, Left(failure));
      verify(() => mockSearchRepository.addDocument(any()));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should pass correct parameters to repository', () async {
      // arrange
      when(() => mockSearchRepository.addDocument(any()))
          .thenAnswer((_) async => Right(testDocument));

      // act
      await addDocument(testParams);

      // assert
      final captured = verify(() => mockSearchRepository.addDocument(captureAny()))
          .captured.single as Document;
      expect(captured.title, testDocument.title);
      expect(captured.content, testDocument.content);
      expect(captured.category, testDocument.category);
      expect(captured.tags, testDocument.tags);
    });
  });

  group('AddDocumentParams', () {
    test('should support equality comparison', () {
      // arrange
      final doc1 = Document(
        id: 1,
        title: 'Title',
        content: 'Content',
        category: 'Category',
        tags: const ['tag1'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final doc2 = Document(
        id: 1,
        title: 'Title',
        content: 'Content',
        category: 'Category',
        tags: const ['tag1'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final params1 = AddDocumentParams(document: doc1);
      final params2 = AddDocumentParams(document: doc2);

      // assert
      expect(params1, equals(params2));
    });

    test('should have correct props for equality', () {
      // arrange
      final doc = Document(
        id: 1,
        title: 'Title',
        content: 'Content',
        category: 'Category',
        tags: const ['tag1'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final params = AddDocumentParams(document: doc);

      // assert
      expect(params.props, [doc]);
    });
  });
}