import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';

void main() {
  group('Document Entity Tests', () {
    late Document testDocument;

    setUp(() {
      testDocument = Document(
        id: 1,
        title: 'Test Document',
        content: 'This is test content',
        category: 'Test Category',
        tags: const ['test', 'flutter'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
        relevanceScore: 0.85,
      );
    });

    test('should create Document with all properties', () {
      expect(testDocument.id, equals(1));
      expect(testDocument.title, equals('Test Document'));
      expect(testDocument.content, equals('This is test content'));
      expect(testDocument.category, equals('Test Category'));
      expect(testDocument.tags, equals(['test', 'flutter']));
      expect(testDocument.createdAt, equals(DateTime(2023, 1, 1)));
      expect(testDocument.updatedAt, equals(DateTime(2023, 1, 2)));
      expect(testDocument.relevanceScore, equals(0.85));
    });

    test('should create Document with optional properties as null', () {
      final document = Document(
        id: 2,
        title: 'Minimal Document',
        content: 'Minimal content',
        tags: const [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      expect(document.category, isNull);
      expect(document.relevanceScore, isNull);
      expect(document.tags, isEmpty);
    });

    test('should support equality comparison', () {
      final document1 = Document(
        id: 1,
        title: 'Test Document',
        content: 'This is test content',
        category: 'Test Category',
        tags: const ['test', 'flutter'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
        relevanceScore: 0.85,
      );

      final document2 = Document(
        id: 1,
        title: 'Test Document',
        content: 'This is test content',
        category: 'Test Category',
        tags: const ['test', 'flutter'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
        relevanceScore: 0.85,
      );

      final document3 = Document(
        id: 2,
        title: 'Different Document',
        content: 'Different content',
        tags: const [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      expect(document1, equals(document2));
      expect(document1, isNot(equals(document3)));
    });

    test('should support copyWith functionality', () {
      final updatedDocument = testDocument.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
        updatedAt: DateTime(2023, 1, 3),
      );

      expect(updatedDocument.id, equals(testDocument.id));
      expect(updatedDocument.title, equals('Updated Title'));
      expect(updatedDocument.content, equals('Updated content'));
      expect(updatedDocument.category, equals(testDocument.category));
      expect(updatedDocument.tags, equals(testDocument.tags));
      expect(updatedDocument.createdAt, equals(testDocument.createdAt));
      expect(updatedDocument.updatedAt, equals(DateTime(2023, 1, 3)));
      expect(
          updatedDocument.relevanceScore, equals(testDocument.relevanceScore));
    });

    test('should maintain original values when copyWith called with nulls', () {
      final copiedDocument = testDocument.copyWith();

      expect(copiedDocument, equals(testDocument));
    });

    test('should handle empty tags list', () {
      final document = Document(
        id: 3,
        title: 'No Tags Document',
        content: 'Content without tags',
        tags: const [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      expect(document.tags, isEmpty);
      expect(document.tags, isA<List<String>>());
    });

    test('should handle multiple tags', () {
      final document = Document(
        id: 4,
        title: 'Multi Tag Document',
        content: 'Content with many tags',
        tags: const ['flutter', 'dart', 'mobile', 'development', 'test'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      expect(document.tags.length, equals(5));
      expect(document.tags, contains('flutter'));
      expect(document.tags, contains('dart'));
      expect(document.tags, contains('mobile'));
      expect(document.tags, contains('development'));
      expect(document.tags, contains('test'));
    });

    test('should handle relevance score edge cases', () {
      final document1 = Document(
        id: 5,
        title: 'Zero Score',
        content: 'Content',
        tags: const [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        relevanceScore: 0.0,
      );

      final document2 = Document(
        id: 6,
        title: 'Perfect Score',
        content: 'Content',
        tags: const [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
        relevanceScore: 1.0,
      );

      expect(document1.relevanceScore, equals(0.0));
      expect(document2.relevanceScore, equals(1.0));
    });

    test('should convert to string representation correctly', () {
      final stringRepresentation = testDocument.toString();

      expect(stringRepresentation, contains('Document'));
      expect(stringRepresentation, contains('1'));
      expect(stringRepresentation, contains('Test Document'));
    });
  });
}
