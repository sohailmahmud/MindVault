import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/data/datasources/ai_data_source.dart';

void main() {
  group('AIDataSource Tests', () {
    late AIDataSourceImpl dataSource;

    setUp(() {
      dataSource = AIDataSourceImpl();
    });

    test('suggestCategories returns relevant categories for work content', () async {
      final result = await dataSource.suggestCategories(
        'This is a business report about quarterly earnings and project management'
      );
      
      expect(result, isNotEmpty);
      expect(result.length, lessThanOrEqualTo(3));
      expect(result, contains('Work'));
    });

    test('suggestCategories returns relevant categories for personal content', () async {
      final result = await dataSource.suggestCategories(
        'My personal thoughts about family vacation and cooking recipes'
      );
      
      expect(result, isNotEmpty);
      expect(result, contains('Personal'));
    });

    test('suggestCategories handles empty content gracefully', () async {
      final result = await dataSource.suggestCategories('');
      
      expect(result, isEmpty);
    });

    test('initializeModel completes successfully', () async {
      await expectLater(
        () => dataSource.initializeModel(),
        returnsNormally,
      );
    });

    test('generateEmbedding returns embedding for text', () async {
      final result = await dataSource.generateEmbedding('test text');
      
      expect(result, isA<List<double>>());
      expect(result, isNotEmpty);
    });

    test('calculateSimilarity returns similarity score', () async {
      final embedding1 = [1.0, 2.0, 3.0];
      final embedding2 = [1.5, 2.5, 3.5];
      
      final similarity = await dataSource.calculateSimilarity(embedding1, embedding2);
      
      expect(similarity, isA<double>());
      expect(similarity, greaterThanOrEqualTo(0.0));
      expect(similarity, lessThanOrEqualTo(1.0));
    });

    test('extractTags returns relevant tags', () async {
      final result = await dataSource.extractTags(
        'Flutter development project with Dart programming language'
      );
      
      expect(result, isA<List<String>>());
    });

    test('generateSummary returns summary of content', () async {
      final result = await dataSource.generateSummary(
        'This is a document about Flutter development with detailed explanations.'
      );
      
      expect(result, isA<String>());
    });
  });
}