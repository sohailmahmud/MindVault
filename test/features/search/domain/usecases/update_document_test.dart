import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mindvault/core/error/failures.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/domain/repositories/search_repository.dart';
import 'package:mindvault/features/search/domain/usecases/update_document.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class FakeDocument extends Fake implements Document {}

void main() {
  late UpdateDocument updateDocument;
  late MockSearchRepository mockSearchRepository;
  late Document testDocument;

  setUpAll(() {
    registerFallbackValue(FakeDocument());
  });

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    updateDocument = UpdateDocument(mockSearchRepository);
    testDocument = Document(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      category: 'Test',
      tags: const ['test'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );
  });

  group('UpdateDocument', () {
    test('should return updated document when repository call is successful',
        () async {
      // arrange
      when(() => mockSearchRepository.updateDocument(any()))
          .thenAnswer((_) async => Right(testDocument));

      // act
      final result =
          await updateDocument(UpdateDocumentParams(document: testDocument));

      // assert
      expect(result, Right(testDocument));
      verify(() => mockSearchRepository.updateDocument(any()));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('should return failure when repository call is unsuccessful',
        () async {
      // arrange
      const failure = DatabaseFailure('Update failed');
      when(() => mockSearchRepository.updateDocument(any()))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result =
          await updateDocument(UpdateDocumentParams(document: testDocument));

      // assert
      expect(result, const Left(failure));
      verify(() => mockSearchRepository.updateDocument(any()));
      verifyNoMoreInteractions(mockSearchRepository);
    });

    test('UpdateDocumentParams should have correct props', () {
      final params = UpdateDocumentParams(document: testDocument);
      expect(params.props, [testDocument]);
    });

    test('UpdateDocumentParams equality should work correctly', () {
      final params1 = UpdateDocumentParams(document: testDocument);
      final params2 = UpdateDocumentParams(document: testDocument);
      final params3 = UpdateDocumentParams(
          document: testDocument.copyWith(title: 'Different'));

      expect(params1, params2);
      expect(params1, isNot(params3));
    });
  });
}
