import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../core/ai/tflite_service.dart';

class AIFeaturesPage extends StatefulWidget {
  const AIFeaturesPage({super.key});

  @override
  State<AIFeaturesPage> createState() => _AIFeaturesPageState();
}

class _AIFeaturesPageState extends State<AIFeaturesPage> {
  final TextEditingController _textController = TextEditingController();
  final TfLiteService _tfLiteService = serviceLocator<TfLiteService>();
  List<double>? _embedding;
  bool _isProcessing = false;
  String _aiStatus = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _checkAIStatus();
  }

  Future<void> _checkAIStatus() async {
    setState(() {
      _aiStatus = _tfLiteService.isInitialized ? 'Ready' : 'Initializing...';
    });

    if (!_tfLiteService.isInitialized) {
      await _tfLiteService.initialize();
      setState(() {
        _aiStatus =
            _tfLiteService.isInitialized ? 'Ready' : 'Failed to initialize';
      });
    }
  }

  Future<void> _generateEmbedding() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final embedding =
          await _tfLiteService.generateEmbedding(_textController.text);
      setState(() {
        _embedding = embedding;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating embedding: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Features'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: _aiStatus == 'Ready'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TensorFlow Lite Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_aiStatus'),
                    const SizedBox(height: 4),
                    const Text(
                        'Embedding Dimension: ${TfLiteService.embeddingDim}'),
                    const SizedBox(height: 4),
                    const Text('Max Sequence Length: 128'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Text Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Embedding Generator',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Enter text to generate embedding',
                        hintText: 'Type any text to see its AI embedding...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _generateEmbedding,
                      child: _isProcessing
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Processing...'),
                              ],
                            )
                          : const Text('Generate Embedding'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Embedding Display
            if (_embedding != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Generated Embedding',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Dimensions: ${_embedding!.length}'),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Embedding Visualization
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomPaint(
                                    painter: EmbeddingVisualizationPainter(
                                        _embedding!),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Embedding Values (first 20 for brevity)
                                Text(
                                  'First 20 values:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _embedding!
                                      .take(20)
                                      .map((value) => Chip(
                                            label: Text(
                                              value.toStringAsFixed(3),
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ))
                                      .toList(),
                                ),

                                const SizedBox(height: 16),

                                // Statistics
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Statistics:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Min: ${_embedding!.reduce((a, b) => a < b ? a : b).toStringAsFixed(4)}'),
                                      Text(
                                          'Max: ${_embedding!.reduce((a, b) => a > b ? a : b).toStringAsFixed(4)}'),
                                      Text(
                                          'Mean: ${(_embedding!.reduce((a, b) => a + b) / _embedding!.length).toStringAsFixed(4)}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Semantic Search Demo Button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate back to search with AI-powered search
                },
                icon: const Icon(Icons.search),
                label: const Text('Try AI-Powered Search'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

/// Custom painter for visualizing embeddings as a simple waveform
class EmbeddingVisualizationPainter extends CustomPainter {
  final List<double> embedding;

  EmbeddingVisualizationPainter(this.embedding);

  @override
  void paint(Canvas canvas, Size size) {
    if (embedding.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (embedding.length - 1);

    // Normalize values to fit in the canvas
    final minVal = embedding.reduce((a, b) => a < b ? a : b);
    final maxVal = embedding.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    if (range == 0) return;

    // Start path
    final firstY =
        size.height - ((embedding[0] - minVal) / range) * size.height;
    path.moveTo(0, firstY);

    // Draw the waveform
    for (int i = 1; i < embedding.length; i++) {
      final x = i * stepX;
      final y = size.height - ((embedding[i] - minVal) / range) * size.height;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw zero line if it's in range
    if (minVal <= 0 && maxVal >= 0) {
      final zeroY = size.height - ((-minVal) / range) * size.height;
      final zeroPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), zeroPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
