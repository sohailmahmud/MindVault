import 'package:objectbox/objectbox.dart';
import '../../domain/entities/document.dart';

@Entity()
class DocumentModel {
  @Id()
  int id;

  String title;
  String content;
  String? category;
  List<String> tags;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  double? relevanceScore;

  DocumentModel({
    this.id = 0,
    required this.title,
    required this.content,
    this.category,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.relevanceScore,
  });

  // Convert to domain entity
  Document toEntity() {
    return Document(
      id: id,
      title: title,
      content: content,
      category: category,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      relevanceScore: relevanceScore,
    );
  }

  // Create from domain entity
  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      title: document.title,
      content: document.content,
      category: document.category,
      tags: document.tags,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
      relevanceScore: document.relevanceScore,
    );
  }

  DocumentModel copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
  }) {
    return DocumentModel(
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
