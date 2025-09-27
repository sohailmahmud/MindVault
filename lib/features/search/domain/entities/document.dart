import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final int id;
  final String title;
  final String content;
  final String? category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? relevanceScore;

  const Document({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.relevanceScore,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        category,
        tags,
        createdAt,
        updatedAt,
        relevanceScore,
      ];

  Document copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }
}