import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/get_document_by_id.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late GetDocumentById getDocumentById;
  late MockSearchRepository mockSearchRepository;
  late GetDocumentByIdParams testParams;
  late Document testDocument;

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    getDocumentById = GetDocumentById(mockSearchRepository);
    testParams = const GetDocumentByIdParams(documentId: 1);
    testDocument = Document(
      id: 1,
      title: 'Test Title',
      content: 'Test Content',
      category: 'Test Category',
      tags: const ['tag1', 'tag2'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
  });

  group('GetDocumentById', () {
    test('should return document when repository call is successful', () async {
      // arrange
      when(() => mockSearchRepository.getDocumentById(any()))
          .thenAnswer((_) async => Right(testDocument));

      // act
      final result = await getDocumentById(testParams);

      // assert
      expect(result, Right(testDocument));
      verify(() => mockSearchRepository.getDocumentById(1));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when repository call is unsuccessful', () async {
      // arrange
      final failure = DatabaseFailure('Document not found');
      when(() => mockSearchRepository.getDocumentById(any()))
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await getDocumentById(testParams);

      // assert
      expect(result, Left(failure));
      verify(() => mockSearchRepository.getDocumentById(1));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should pass correct id to repository', () async {
      // arrange
      when(() => mockSearchRepository.getDocumentById(any()))
          .thenAnswer((_) async => Right(testDocument));

      // act
      await getDocumentById(testParams);

      // assert
      verify(() => mockSearchRepository.getDocumentById(1));
      verifyNoMoreInteractions(mockSearchRepository);
    });
  });

  group('GetDocumentByIdParams', () {
    test('should support equality comparison', () {
      // arrange
      const params1 = GetDocumentByIdParams(documentId: 1);
      const params2 = GetDocumentByIdParams(documentId: 1);

      // assert
      expect(params1, equals(params2));
    });

    test('should have correct props for equality', () {
      // arrange
      const params = GetDocumentByIdParams(documentId: 1);

      // assert
      expect(params.props, [1]);
    });

    test('should not be equal when ids are different', () {
      // arrange
      const params1 = GetDocumentByIdParams(documentId: 1);
      const params2 = GetDocumentByIdParams(documentId: 2);

      // assert
      expect(params1, isNot(equals(params2)));
    });
  });
}