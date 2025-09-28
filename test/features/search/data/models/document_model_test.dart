import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/data/models/document_model.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';

void main() {
  group('DocumentModel', () {
    final testDateTime = DateTime(2023, 1, 1);
    final testDocumentModel = DocumentModel(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      category: 'Test Category',
      tags: ['tag1', 'tag2'],
      createdAt: testDateTime,
      updatedAt: testDateTime,
      relevanceScore: 0.8,
    );

    final testDocument = Document(
      id: 1,
      title: 'Test Document',
      content: 'Test content',
      category: 'Test Category', 
      tags: const ['tag1', 'tag2'],
      createdAt: testDateTime,
      updatedAt: testDateTime,
      relevanceScore: 0.8,
    );

    group('Constructor', () {
      test('should create DocumentModel with all parameters', () {
        expect(testDocumentModel.id, 1);
        expect(testDocumentModel.title, 'Test Document');
        expect(testDocumentModel.content, 'Test content');
        expect(testDocumentModel.category, 'Test Category');
        expect(testDocumentModel.tags, ['tag1', 'tag2']);
        expect(testDocumentModel.createdAt, testDateTime);
        expect(testDocumentModel.updatedAt, testDateTime);
        expect(testDocumentModel.relevanceScore, 0.8);
      });

      test('should create DocumentModel with default id as 0', () {
        final model = DocumentModel(
          title: 'Test',
          content: 'Content',
          tags: [],
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        expect(model.id, 0);
      });

      test('should create DocumentModel with optional fields null', () {
        final model = DocumentModel(
          title: 'Test',
          content: 'Content',
          tags: [],
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        expect(model.category, isNull);
        expect(model.relevanceScore, isNull);
      });
    });

    group('toEntity', () {
      test('should convert DocumentModel to Document entity', () {
        final entity = testDocumentModel.toEntity();
        
        expect(entity, isA<Document>());
        expect(entity.id, testDocumentModel.id);
        expect(entity.title, testDocumentModel.title);
        expect(entity.content, testDocumentModel.content);
        expect(entity.category, testDocumentModel.category);
        expect(entity.tags, testDocumentModel.tags);
        expect(entity.createdAt, testDocumentModel.createdAt);
        expect(entity.updatedAt, testDocumentModel.updatedAt);
        expect(entity.relevanceScore, testDocumentModel.relevanceScore);
      });

      test('should convert DocumentModel with null fields to Document entity', () {
        final model = DocumentModel(
          title: 'Test',
          content: 'Content',
          tags: [],
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        final entity = model.toEntity();
        
        expect(entity.category, isNull);
        expect(entity.relevanceScore, isNull);
      });
    });

    group('fromEntity', () {
      test('should create DocumentModel from Document entity', () {
        final model = DocumentModel.fromEntity(testDocument);
        
        expect(model, isA<DocumentModel>());
        expect(model.id, testDocument.id);
        expect(model.title, testDocument.title);
        expect(model.content, testDocument.content);
        expect(model.category, testDocument.category);
        expect(model.tags, testDocument.tags);
        expect(model.createdAt, testDocument.createdAt);
        expect(model.updatedAt, testDocument.updatedAt);
        expect(model.relevanceScore, testDocument.relevanceScore);
      });

      test('should create DocumentModel from Document entity with null fields', () {
        final document = Document(
          id: 1,
          title: 'Test',
          content: 'Content',
          tags: const [],
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        final model = DocumentModel.fromEntity(document);
        
        expect(model.category, isNull);
        expect(model.relevanceScore, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final copy = testDocumentModel.copyWith(
          title: 'Updated Title',
          content: 'Updated Content',
        );
        
        expect(copy.id, testDocumentModel.id);
        expect(copy.title, 'Updated Title');
        expect(copy.content, 'Updated Content');
        expect(copy.category, testDocumentModel.category);
        expect(copy.tags, testDocumentModel.tags);
        expect(copy.createdAt, testDocumentModel.createdAt);
        expect(copy.updatedAt, testDocumentModel.updatedAt);
        expect(copy.relevanceScore, testDocumentModel.relevanceScore);
      });

      test('should create copy with all fields updated', () {
        final newDateTime = DateTime(2023, 12, 31);
        final copy = testDocumentModel.copyWith(
          id: 2,
          title: 'New Title',
          content: 'New Content',
          category: 'New Category',
          tags: ['new-tag'],
          createdAt: newDateTime,
          updatedAt: newDateTime,
          relevanceScore: 0.9,
        );
        
        expect(copy.id, 2);
        expect(copy.title, 'New Title');
        expect(copy.content, 'New Content');
        expect(copy.category, 'New Category');
        expect(copy.tags, ['new-tag']);
        expect(copy.createdAt, newDateTime);
        expect(copy.updatedAt, newDateTime);
        expect(copy.relevanceScore, 0.9);
      });

      test('should create copy with no changes when no parameters provided', () {
        final copy = testDocumentModel.copyWith();
        
        expect(copy.id, testDocumentModel.id);
        expect(copy.title, testDocumentModel.title);
        expect(copy.content, testDocumentModel.content);
        expect(copy.category, testDocumentModel.category);
        expect(copy.tags, testDocumentModel.tags);
        expect(copy.createdAt, testDocumentModel.createdAt);
        expect(copy.updatedAt, testDocumentModel.updatedAt);
        expect(copy.relevanceScore, testDocumentModel.relevanceScore);
      });

      test('should create copy without affecting original values when parameters not provided', () {
        final originalModel = DocumentModel(
          id: 1,
          title: 'Test',
          content: 'Content',
          category: 'Original Category',
          tags: ['tag'],
          createdAt: testDateTime,
          updatedAt: testDateTime,
          relevanceScore: 0.5,
        );
        
        final copy = originalModel.copyWith();
        
        expect(copy.category, equals('Original Category'));
        expect(copy.relevanceScore, equals(0.5));
        expect(copy.id, originalModel.id);
        expect(copy.title, originalModel.title);
        expect(copy.content, originalModel.content);
      });
    });

    group('Conversion round-trip', () {
      test('should maintain data integrity during entity-model conversions', () {
        final originalEntity = testDocument;
        final model = DocumentModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();
        
        expect(convertedEntity.id, originalEntity.id);
        expect(convertedEntity.title, originalEntity.title);
        expect(convertedEntity.content, originalEntity.content);
        expect(convertedEntity.category, originalEntity.category);
        expect(convertedEntity.tags, originalEntity.tags);
        expect(convertedEntity.createdAt, originalEntity.createdAt);
        expect(convertedEntity.updatedAt, originalEntity.updatedAt);
        expect(convertedEntity.relevanceScore, originalEntity.relevanceScore);
      });

      test('should maintain data integrity during model-entity conversions', () {
        final originalModel = testDocumentModel;
        final entity = originalModel.toEntity();
        final convertedModel = DocumentModel.fromEntity(entity);
        
        expect(convertedModel.id, originalModel.id);
        expect(convertedModel.title, originalModel.title);
        expect(convertedModel.content, originalModel.content);
        expect(convertedModel.category, originalModel.category);
        expect(convertedModel.tags, originalModel.tags);
        expect(convertedModel.createdAt, originalModel.createdAt);
        expect(convertedModel.updatedAt, originalModel.updatedAt);
        expect(convertedModel.relevanceScore, originalModel.relevanceScore);
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings and empty lists', () {
        final model = DocumentModel(
          title: '',
          content: '',
          category: '',
          tags: [],
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        expect(model.title, isEmpty);
        expect(model.content, isEmpty);
        expect(model.category, isEmpty);
        expect(model.tags, isEmpty);
        
        final entity = model.toEntity();
        expect(entity.title, isEmpty);
        expect(entity.content, isEmpty);
        expect(entity.category, isEmpty);
        expect(entity.tags, isEmpty);
      });

      test('should handle very long strings and large lists', () {
        final longString = 'a' * 10000;
        final largeTags = List.generate(100, (index) => 'tag$index');
        
        final model = DocumentModel(
          title: longString,
          content: longString,
          tags: largeTags,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        expect(model.title.length, 10000);
        expect(model.content.length, 10000);
        expect(model.tags.length, 100);
        
        final entity = model.toEntity();
        expect(entity.title.length, 10000);
        expect(entity.content.length, 10000);
        expect(entity.tags.length, 100);
      });

      test('should handle special characters and unicode', () {
        const specialTitle = 'Title with émojis 😀 and spëcial chars ñ';
        const specialContent = 'Content with 中文, العربية, and русский';
        const specialTags = ['tag-with-émoji-😀', 'tag_with_中文', 'тег'];
        
        final model = DocumentModel(
          title: specialTitle,
          content: specialContent,
          tags: specialTags,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );
        
        expect(model.title, specialTitle);
        expect(model.content, specialContent);
        expect(model.tags, specialTags);
        
        final entity = model.toEntity();
        expect(entity.title, specialTitle);
        expect(entity.content, specialContent);
        expect(entity.tags, specialTags);
      });
    });
  });
}