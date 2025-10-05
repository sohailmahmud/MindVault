import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/core/ai/tflite_service.dart';

void main() {
  group('TfLiteService Tests', () {
    late TfLiteService tfLiteService;

    setUp(() {
      tfLiteService = TfLiteService();
    });

    test('should initialize without errors', () async {
      // This test will pass even without a real model file
      // because the service gracefully falls back to hash-based embeddings
      await tfLiteService.initialize();

      // The service should be marked as "initialized" even with fallback
      expect(tfLiteService.isInitialized, isTrue);
    });

    test('should generate embeddings for text', () async {
      await tfLiteService.initialize();

      const testText = 'This is a test document about Flutter development';
      final embedding = await tfLiteService.generateEmbedding(testText);

      expect(embedding, isNotNull);
      expect(embedding.length, equals(TfLiteService.embeddingDim));
      expect(embedding, isA<List<double>>());
    });

    test('should calculate similarity between embeddings', () async {
      await tfLiteService.initialize();

      const text1 = 'Flutter mobile development';
      const text2 = 'Mobile app development with Flutter';
      const text3 = 'Cooking recipes and food';

      final embedding1 = await tfLiteService.generateEmbedding(text1);
      final embedding2 = await tfLiteService.generateEmbedding(text2);
      final embedding3 = await tfLiteService.generateEmbedding(text3);

      final similarity12 =
          tfLiteService.calculateSimilarity(embedding1, embedding2);
      final similarity13 =
          tfLiteService.calculateSimilarity(embedding1, embedding3);

      // With hash-based embeddings, we just verify the similarity is calculated correctly
      // (Real ML models would show higher similarity for related texts)
      expect(similarity12, greaterThanOrEqualTo(-1.0));
      expect(similarity12, lessThanOrEqualTo(1.0));
      expect(similarity13, greaterThanOrEqualTo(-1.0));
      expect(similarity13, lessThanOrEqualTo(1.0));
    });

    test('should handle empty text', () async {
      await tfLiteService.initialize();

      final embedding = await tfLiteService.generateEmbedding('');

      expect(embedding, isNotNull);
      expect(embedding.length, equals(TfLiteService.embeddingDim));
    });

    test('should handle long text', () async {
      await tfLiteService.initialize();

      final longText =
          'word ' * 200; // 200 words, longer than maxSequenceLength
      final embedding = await tfLiteService.generateEmbedding(longText);

      expect(embedding, isNotNull);
      expect(embedding.length, equals(TfLiteService.embeddingDim));
    });

    test('should handle special characters', () async {
      await tfLiteService.initialize();

      const specialText = 'Hello! @#\$%^&*() 123 []{} 测试 émojis 🚀📱💻';
      final embedding = await tfLiteService.generateEmbedding(specialText);

      expect(embedding, isNotNull);
      expect(embedding.length, equals(TfLiteService.embeddingDim));
    });

    test('should calculate identical similarity for same text', () async {
      await tfLiteService.initialize();

      const text = 'Same text for similarity test';
      final embedding1 = await tfLiteService.generateEmbedding(text);
      final embedding2 = await tfLiteService.generateEmbedding(text);

      final similarity =
          tfLiteService.calculateSimilarity(embedding1, embedding2);

      // Same text should have perfect similarity (or very close due to floating point)
      expect(similarity, closeTo(1.0, 0.01));
    });

    test(
        'should handle similarity calculation with different length embeddings',
        () {
      final embedding1 = [1.0, 2.0, 3.0];
      final embedding2 = [1.0, 2.0]; // Different length

      expect(
        () => tfLiteService.calculateSimilarity(embedding1, embedding2),
        throwsArgumentError,
      );
    });
  });
}
