import 'dart:math' as math;

/// Service for managing TensorFlow Lite models and inference
/// Currently using fallback hash-based embeddings due to TensorFlow Lite compatibility issues
/// TODO: Re-enable TensorFlow Lite when compatibility is fixed
class TfLiteService {
  static const int embeddingDim = 384;

  bool _isInitialized = false;

  /// Gets whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initializes the TensorFlow Lite service
  /// Currently uses fallback implementation
  Future<void> initialize() async {
    try {
      // TODO: Load actual TensorFlow Lite model when compatibility is fixed
      // For now, just mark as initialized for fallback behavior
      _isInitialized = true;
      // TfLiteService initialized with fallback implementation
    } catch (e) {
      // TfLiteService initialization failed: $e
      // Still mark as initialized so we can use fallback
      _isInitialized = true;
    }
  }

  /// Generates embedding for the given text
  /// Currently uses hash-based fallback implementation
  Future<List<double>> generateEmbedding(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Fallback: Generate deterministic embedding based on text hash
    return _generateHashBasedEmbedding(text);
  }

  /// Generates a deterministic hash-based embedding for text
  /// This provides consistent embeddings for the same text
  List<double> _generateHashBasedEmbedding(String text) {
    // Clean and normalize text
    final cleanText = text.toLowerCase().trim();

    // Generate multiple hash seeds from the text
    final seeds = <int>[];
    for (int i = 0; i < 8; i++) {
      seeds.add(_hashString(cleanText + i.toString()));
    }

    // Generate embedding using multiple random generators with different seeds
    final embedding = <double>[];
    for (int i = 0; i < embeddingDim; i++) {
      final seedIndex = i % seeds.length;
      final rng = math.Random(seeds[seedIndex] + i);
      // Generate value between -1 and 1
      embedding.add((rng.nextDouble() - 0.5) * 2.0);
    }

    // Normalize the embedding to unit length
    return _normalizeEmbedding(embedding);
  }

  /// Simple string hash function
  int _hashString(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash + str.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Normalizes an embedding to unit length
  List<double> _normalizeEmbedding(List<double> embedding) {
    double sum = 0.0;
    for (final value in embedding) {
      sum += value * value;
    }
    final magnitude = math.sqrt(sum);

    if (magnitude == 0.0) {
      return List.filled(embeddingDim, 0.0);
    }

    return embedding.map((value) => value / magnitude).toList();
  }

  /// Calculates cosine similarity between two embeddings
  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw ArgumentError('Embeddings must have the same length');
    }

    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      magnitude1 += embedding1[i] * embedding1[i];
      magnitude2 += embedding2[i] * embedding2[i];
    }

    magnitude1 = math.sqrt(magnitude1);
    magnitude2 = math.sqrt(magnitude2);

    if (magnitude1 == 0.0 || magnitude2 == 0.0) {
      return 0.0;
    }

    // Ensure result is between -1 and 1
    final similarity = dotProduct / (magnitude1 * magnitude2);
    return math.max(-1.0, math.min(1.0, similarity));
  }

  /// Preprocesses text for embedding generation
  String preprocessText(String text) {
    // Basic text preprocessing
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Replace punctuation with spaces
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Cleans up resources
  void dispose() {
    // TODO: Clean up TensorFlow Lite resources when implemented
    _isInitialized = false;
    // TfLiteService disposed
  }
}
