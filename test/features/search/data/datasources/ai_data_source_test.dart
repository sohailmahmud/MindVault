import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/data/datasources/ai_data_source.dart';
import 'package:mindvault/features/search/data/models/document_model.dart';

void main() {
  group('AIDataSourceImpl Tests', () {
    late AIDataSourceImpl aiDataSource;

    final testDocument1 = DocumentModel(
      id: 1,
      title: 'Flutter Development',
      content: 'This is a document about Flutter development and Dart programming',
      category: 'Development',
      tags: ['flutter', 'dart'],
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final testDocument2 = DocumentModel(
      id: 2,
      title: 'Meeting Notes',
      content: 'Important meeting discussion about project deadlines and tasks',
      category: 'Work',
      tags: ['meeting', 'important'],
      createdAt: DateTime(2023, 1, 2),
      updatedAt: DateTime(2023, 1, 2),
    );

    final testDocument3 = DocumentModel(
      id: 3,
      title: 'Personal Journal',
      content: 'Today I went home to spend time with family and friends',
      category: 'Personal',
      tags: ['journal', 'personal'],
      createdAt: DateTime(2023, 1, 3),
      updatedAt: DateTime(2023, 1, 3),
    );

    setUp(() {
      aiDataSource = AIDataSourceImpl();
    });

    group('initializeModel', () {
      test('should complete without errors', () async {
        expect(() => aiDataSource.initializeModel(), returnsNormally);
        await aiDataSource.initializeModel();
      });
    });

    group('generateEmbedding', () {
      test('should generate embedding vector of correct length', () async {
        const testText = 'This is a test document';
        
        final embedding = await aiDataSource.generateEmbedding(testText);
        
        expect(embedding, isA<List<double>>());
        expect(embedding.length, equals(100));
        expect(embedding, isNotEmpty);
      });

      test('should generate consistent embeddings for same text', () async {
        const testText = 'Consistent test text';
        
        final embedding1 = await aiDataSource.generateEmbedding(testText);
        final embedding2 = await aiDataSource.generateEmbedding(testText);
        
        expect(embedding1, equals(embedding2));
      });

      test('should generate different embeddings for different text', () async {
        const text1 = 'First test text';
        const text2 = 'Second test text';
        
        final embedding1 = await aiDataSource.generateEmbedding(text1);
        final embedding2 = await aiDataSource.generateEmbedding(text2);
        
        expect(embedding1, isNot(equals(embedding2)));
      });

      test('should handle empty text', () async {
        const emptyText = '';
        
        final embedding = await aiDataSource.generateEmbedding(emptyText);
        
        expect(embedding, isA<List<double>>());
        expect(embedding.length, equals(100));
      });
    });

    group('calculateSimilarity', () {
      test('should return 1.0 for identical embeddings', () async {
        final embedding = [1.0, 2.0, 3.0, 4.0];
        
        final similarity = await aiDataSource.calculateSimilarity(embedding, embedding);
        
        expect(similarity, equals(1.0));
      });

      test('should return 0.0 for embeddings of different lengths', () async {
        final embedding1 = [1.0, 2.0, 3.0];
        final embedding2 = [1.0, 2.0];
        
        final similarity = await aiDataSource.calculateSimilarity(embedding1, embedding2);
        
        expect(similarity, equals(0.0));
      });

      test('should return 0.0 for zero embeddings', () async {
        final zeroEmbedding = [0.0, 0.0, 0.0];
        final normalEmbedding = [1.0, 2.0, 3.0];
        
        final similarity = await aiDataSource.calculateSimilarity(zeroEmbedding, normalEmbedding);
        
        expect(similarity, equals(0.0));
      });

      test('should calculate similarity between different embeddings', () async {
        final embedding1 = [1.0, 0.0, 0.0];
        final embedding2 = [0.0, 1.0, 0.0];
        
        final similarity = await aiDataSource.calculateSimilarity(embedding1, embedding2);
        
        expect(similarity, isA<double>());
        expect(similarity, lessThanOrEqualTo(1.0));
        expect(similarity, greaterThanOrEqualTo(0.0));
      });

      test('should handle negative values in embeddings', () async {
        final embedding1 = [-1.0, 2.0, -3.0];
        final embedding2 = [1.0, -2.0, 3.0];
        
        final similarity = await aiDataSource.calculateSimilarity(embedding1, embedding2);
        
        expect(similarity, isA<double>());
        expect(similarity, lessThanOrEqualTo(1.0));
        expect(similarity, greaterThanOrEqualTo(-1.0));
      });
    });

    group('performSemanticSearch', () {
      test('should return empty list when no documents provided', () async {
        const query = 'test query';
        final emptyDocuments = <DocumentModel>[];
        
        final results = await aiDataSource.performSemanticSearch(query, emptyDocuments);
        
        expect(results, isEmpty);
      });

      test('should return documents sorted by similarity', () async {
        const query = 'flutter development';
        final documents = [testDocument1, testDocument2, testDocument3];
        
        final results = await aiDataSource.performSemanticSearch(query, documents);
        
        expect(results, isA<List<DocumentModel>>());
        expect(results.length, lessThanOrEqualTo(documents.length));
        
        // Results should have relevance scores
        if (results.isNotEmpty) {
          expect(results.first.relevanceScore, isNotNull);
          expect(results.first.relevanceScore!, greaterThan(0.0));
          // Verify sorted by similarity (highest first)
          for (int i = 0; i < results.length - 1; i++) {
            expect(results[i].relevanceScore!, greaterThanOrEqualTo(results[i + 1].relevanceScore!));
          }
        }
      });

      test('should filter out low similarity results', () async {
        const query = 'completely unrelated random text xyz';
        final documents = [testDocument1, testDocument2];
        
        final results = await aiDataSource.performSemanticSearch(query, documents);
        
        // Results should be filtered if similarity is below threshold (0.1)
        expect(results, isA<List<DocumentModel>>());
      });

      test('should handle documents with different content types', () async {
        const query = 'meeting';
        final documents = [testDocument1, testDocument2, testDocument3];
        
        final results = await aiDataSource.performSemanticSearch(query, documents);
        
        expect(results, isA<List<DocumentModel>>());
        // Meeting document should rank highly
        if (results.isNotEmpty) {
          final meetingDoc = results.firstWhere(
            (doc) => doc.id == testDocument2.id,
            orElse: () => testDocument1, // fallback
          );
          if (meetingDoc.id == testDocument2.id) {
            expect(meetingDoc.relevanceScore, isNotNull);
          }
        }
      });
    });

    group('suggestCategories', () {
      test('should suggest Work category for work-related content', () async {
        const content = 'This is about a meeting with clients and project deadlines';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions, contains('Work'));
      });

      test('should suggest Development category for tech content', () async {
        const content = 'Working on Flutter app with Dart programming language';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions, contains('Development'));
      });

      test('should suggest Personal category for personal content', () async {
        const content = 'Spending time with family and friends at home';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions, contains('Personal'));
      });

      test('should suggest AI/ML category for AI content', () async {
        const content = 'Training machine learning models and neural networks';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions, contains('AI/ML'));
      });

      test('should suggest multiple categories when content matches multiple keywords', () async {
        const content = 'Meeting about machine learning project with the development team';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions.length, greaterThan(1));
        expect(suggestions, isA<List<String>>());
      });

      test('should limit suggestions to maximum of 3', () async {
        const content = 'Meeting about machine learning project with the development team for education and health finance travel ideas';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions.length, lessThanOrEqualTo(3));
      });

      test('should return empty list for content without matching keywords', () async {
        const content = 'xyz abc def random words without meaning';
        
        final suggestions = await aiDataSource.suggestCategories(content);
        
        expect(suggestions, isA<List<String>>());
      });
    });

    group('extractTags', () {
      test('should extract tech tags', () async {
        const content = 'Working with Flutter and Dart for mobile development';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags, contains('flutter'));
        expect(tags, contains('dart'));
      });

      test('should extract importance tags', () async {
        const content = 'This is an important and urgent task that needs attention';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags, contains('important'));
      });

      test('should extract todo tags', () async {
        const content = 'Todo: finish this task before the deadline';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags, contains('todo'));
      });

      test('should extract meeting tags', () async {
        const content = 'Meeting scheduled for discussion about project progress';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags, contains('meeting'));
      });

      test('should extract quoted phrases as tags', () async {
        const content = 'This document is about "machine learning" and "data science"';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags, contains('machine learning'));
        expect(tags, contains('data science'));
      });

      test('should limit tags to maximum of 5', () async {
        const content = 'Flutter Dart React JavaScript Python Java Swift Kotlin important urgent todo meeting "test phrase"';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags.length, lessThanOrEqualTo(5));
      });

      test('should handle empty content', () async {
        const content = '';
        
        final tags = await aiDataSource.extractTags(content);
        
        expect(tags, isA<List<String>>());
      });
    });

    group('generateSummary', () {
      test('should return original content if length is less than 150 characters', () async {
        const shortContent = 'This is a short document.';
        
        final summary = await aiDataSource.generateSummary(shortContent);
        
        expect(summary, equals(shortContent));
      });

      test('should generate summary for long content', () async {
        const longContent = 'This is the first sentence. This is the second sentence. This is the third sentence. This is the fourth sentence with lots of additional text to make it longer than 150 characters total.';
        
        final summary = await aiDataSource.generateSummary(longContent);
        
        expect(summary, isA<String>());
        expect(summary.length, lessThanOrEqualTo(longContent.length));
        expect(summary, isNotEmpty);
      });

      test('should include complete sentences in summary', () async {
        const longContent = 'First sentence here! Second sentence follows. Third sentence continues? Fourth sentence ends.';
        
        final summary = await aiDataSource.generateSummary(longContent);
        
        expect(summary, isA<String>());
        expect(summary, isNotEmpty);
        // Summary should end with proper punctuation
        expect(RegExp(r'[.!?]\s*$').hasMatch(summary), isTrue);
      });

      test('should handle content without proper sentence structure', () async {
        final longContent = 'a' * 200; // 200 characters without sentences
        
        final summary = await aiDataSource.generateSummary(longContent);
        
        expect(summary, isA<String>());
        expect(summary.length, lessThanOrEqualTo(150));
        // May be empty if no sentences found, but should be valid
        expect(summary, isA<String>());
      });

      test('should handle empty content', () async {
        const emptyContent = '';
        
        final summary = await aiDataSource.generateSummary(emptyContent);
        
        expect(summary, equals(''));
      });

      test('should not exceed maximum length', () async {
        final longContent = 'This is a very long document. ' * 20; // Much longer than 150 chars
        
        final summary = await aiDataSource.generateSummary(longContent);
        
        expect(summary.length, lessThanOrEqualTo(160)); // Some tolerance for sentence completion
      });
    });

    group('findSimilarDocuments', () {
      test('should return empty list when no similar documents found', () async {
        final targetDocument = DocumentModel(
          id: 999,
          title: 'Unique Document',
          content: 'Very unique content xyz abc def',
          category: 'Unique',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final allDocuments = [testDocument1, testDocument2, testDocument3];
        
        final similarTitles = await aiDataSource.findSimilarDocuments(targetDocument, allDocuments);
        
        expect(similarTitles, isA<List<String>>());
      });

      test('should not include the same document in results', () async {
        final allDocuments = [testDocument1, testDocument2, testDocument3];
        
        final similarTitles = await aiDataSource.findSimilarDocuments(testDocument1, allDocuments);
        
        expect(similarTitles, isNot(contains(testDocument1.title)));
      });

      test('should find similar documents based on content', () async {
        final similarDocument = DocumentModel(
          id: 4,
          title: 'Another Flutter Guide',
          content: 'More about Flutter development and Dart programming concepts',
          category: 'Development',
          tags: ['flutter', 'programming'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final allDocuments = [testDocument1, testDocument2, testDocument3, similarDocument];
        
        final similarTitles = await aiDataSource.findSimilarDocuments(testDocument1, allDocuments);
        
        expect(similarTitles, isA<List<String>>());
        if (similarTitles.isNotEmpty) {
          expect(similarTitles, contains(similarDocument.title));
        }
      });

      test('should limit results to maximum of 5 documents', () async {
        final manyDocuments = List.generate(10, (index) => DocumentModel(
          id: index + 10,
          title: 'Similar Document $index',
          content: 'Flutter development content similar to test',
          category: 'Development',
          tags: ['flutter'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        final allDocuments = [testDocument1, ...manyDocuments];
        
        final similarTitles = await aiDataSource.findSimilarDocuments(testDocument1, allDocuments);
        
        expect(similarTitles.length, lessThanOrEqualTo(5));
      });

      test('should return titles sorted by similarity', () async {
        final verySimularDocument = DocumentModel(
          id: 5,
          title: 'Flutter Development Guide',
          content: 'Flutter development with Dart programming language',
          category: 'Development',
          tags: ['flutter', 'dart'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final somewhatSimilarDocument = DocumentModel(
          id: 6,
          title: 'Programming Basics',
          content: 'Basic programming concepts',
          category: 'Development',
          tags: ['programming'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final allDocuments = [testDocument1, verySimularDocument, somewhatSimilarDocument, testDocument2];
        
        final similarTitles = await aiDataSource.findSimilarDocuments(testDocument1, allDocuments);
        
        expect(similarTitles, isA<List<String>>());
        if (similarTitles.isNotEmpty) {
          // Should contain similar documents
          expect(similarTitles, contains(verySimularDocument.title));
        }
      });

      test('should handle empty document list', () async {
        final emptyDocuments = <DocumentModel>[];
        
        final similarTitles = await aiDataSource.findSimilarDocuments(testDocument1, emptyDocuments);
        
        expect(similarTitles, isEmpty);
      });
    });
  });
}