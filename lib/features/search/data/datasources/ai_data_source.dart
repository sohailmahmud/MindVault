import 'dart:math' as math;
import '../models/document_model.dart';
import '../../../../core/ai/tflite_service.dart';

abstract class AIDataSource {
  Future<List<DocumentModel>> performSemanticSearch(
      String query, List<DocumentModel> documents);
  Future<List<double>> generateEmbedding(String text);
  Future<void> initializeModel();
  Future<double> calculateSimilarity(
      List<double> embedding1, List<double> embedding2);

  // Advanced AI features
  Future<List<String>> suggestCategories(String content);
  Future<List<String>> extractTags(String content);
  Future<String> generateSummary(String content);
  Future<List<String>> findSimilarDocuments(
      DocumentModel document, List<DocumentModel> allDocuments);
}

class AIDataSourceImpl implements AIDataSource {
  final TfLiteService _tfLiteService = TfLiteService();
  bool _isModelLoaded = false;

  @override
  Future<void> initializeModel() async {
    try {
      await _tfLiteService.initialize();
      _isModelLoaded = _tfLiteService.isInitialized;
    } catch (e) {
      // Log error without using print
      _isModelLoaded = false;
    }
  }

  @override
  Future<List<double>> generateEmbedding(String text) async {
    if (!_isModelLoaded) {
      await initializeModel();
    }

    // Use TensorFlow Lite service for embedding generation
    return await _tfLiteService.generateEmbedding(text);
  }

  @override
  Future<double> calculateSimilarity(
      List<double> embedding1, List<double> embedding2) async {
    // Use TensorFlow Lite service for similarity calculation
    return _tfLiteService.calculateSimilarity(embedding1, embedding2);
  }

  @override
  Future<List<DocumentModel>> performSemanticSearch(
      String query, List<DocumentModel> documents) async {
    if (documents.isEmpty) {
      return [];
    }

    final queryEmbedding = await generateEmbedding(query);
    final List<({DocumentModel document, double similarity})> scoredDocuments =
        [];

    for (final document in documents) {
      final documentText = '${document.title} ${document.content}';
      final documentEmbedding = await generateEmbedding(documentText);
      final similarity =
          await calculateSimilarity(queryEmbedding, documentEmbedding);

      scoredDocuments.add((document: document, similarity: similarity));
    }

    // Sort by similarity (highest first) and return documents
    scoredDocuments.sort((a, b) => b.similarity.compareTo(a.similarity));

    return scoredDocuments
        .where(
            (item) => item.similarity > 0.1) // Filter out very low similarity
        .map((item) => item.document.copyWith(relevanceScore: item.similarity))
        .toList();
  }

  @override
  Future<List<String>> suggestCategories(String content) async {
    // Simple category suggestion based on content analysis
    final suggestions = <String>[];
    final lowerContent = content.toLowerCase();

    // Define category keywords
    final categoryKeywords = {
      'Work': [
        'meeting',
        'project',
        'deadline',
        'task',
        'client',
        'business',
        'office'
      ],
      'Personal': ['family', 'friends', 'home', 'personal', 'diary', 'journal'],
      'Development': [
        'code',
        'programming',
        'flutter',
        'dart',
        'app',
        'software',
        'bug',
        'feature'
      ],
      'AI/ML': [
        'machine learning',
        'ai',
        'artificial intelligence',
        'neural network',
        'model',
        'training'
      ],
      'Education': [
        'learn',
        'study',
        'course',
        'tutorial',
        'lesson',
        'knowledge'
      ],
      'Health': [
        'health',
        'fitness',
        'exercise',
        'medical',
        'doctor',
        'wellness'
      ],
      'Finance': [
        'money',
        'budget',
        'investment',
        'bank',
        'finance',
        'expense'
      ],
      'Travel': [
        'travel',
        'trip',
        'vacation',
        'flight',
        'hotel',
        'destination'
      ],
      'Ideas': [
        'idea',
        'brainstorm',
        'concept',
        'innovation',
        'creative',
        'inspiration'
      ],
    };

    for (final entry in categoryKeywords.entries) {
      final matches =
          entry.value.where((keyword) => lowerContent.contains(keyword)).length;
      if (matches > 0) {
        suggestions.add(entry.key);
      }
    }

    // Sort by relevance (could be improved with better scoring)
    return suggestions.take(3).toList();
  }

  @override
  Future<List<String>> extractTags(String content) async {
    // Simple tag extraction based on common words and patterns
    final tags = <String>[];
    final words = content
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((word) => word.length > 3)
        .toList();

    // Common tech tags
    final techTags = [
      'flutter',
      'dart',
      'react',
      'javascript',
      'python',
      'java',
      'swift',
      'kotlin'
    ];
    final foundTechTags = words.where((word) => techTags.contains(word));
    tags.addAll(foundTechTags);

    // Important indicators
    if (content.toLowerCase().contains('important') ||
        content.toLowerCase().contains('urgent')) {
      tags.add('important');
    }
    if (content.toLowerCase().contains('todo') ||
        content.toLowerCase().contains('task')) {
      tags.add('todo');
    }
    if (content.toLowerCase().contains('meeting') ||
        content.toLowerCase().contains('discussion')) {
      tags.add('meeting');
    }

    // Extract quoted phrases as potential tags
    final quotedPattern = RegExp(r'"([^"]+)"');
    final matches = quotedPattern.allMatches(content);
    for (final match in matches) {
      final phrase = match.group(1);
      if (phrase != null && phrase.split(' ').length <= 3) {
        tags.add(phrase.toLowerCase());
      }
    }

    return tags.take(5).toList();
  }

  @override
  Future<String> generateSummary(String content) async {
    // Simple extractive summary - take first few sentences
    if (content.length <= 150) {
      return content;
    }

    final sentences = content
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (sentences.isEmpty) {
      return content.substring(0, math.min(150, content.length));
    }

    String summary = '';
    int totalLength = 0;
    const maxLength = 150;

    for (final sentence in sentences) {
      if (totalLength + sentence.length > maxLength) {
        break;
      }
      summary += '$sentence. ';
      totalLength += sentence.length + 2;
    }

    return summary.trim();
  }

  @override
  Future<List<String>> findSimilarDocuments(
      DocumentModel document, List<DocumentModel> allDocuments) async {
    final documentText = '${document.title} ${document.content}';
    final documentEmbedding = await generateEmbedding(documentText);

    final similarities = <({String title, double similarity})>[];

    for (final otherDoc in allDocuments) {
      if (otherDoc.id == document.id) {
        continue;
      }

      final otherText = '${otherDoc.title} ${otherDoc.content}';
      final otherEmbedding = await generateEmbedding(otherText);
      final similarity =
          await calculateSimilarity(documentEmbedding, otherEmbedding);

      if (similarity > 0.3) {
        similarities.add((title: otherDoc.title, similarity: similarity));
      }
    }

    // Sort by similarity and return top 5 titles
    similarities.sort((a, b) => b.similarity.compareTo(a.similarity));
    return similarities.take(5).map((item) => item.title).toList();
  }
}
