import '../../features/search/domain/entities/document.dart';
import '../../features/search/domain/usecases/add_document.dart';

class SampleDataHelper {
  final AddDocument addDocument;

  SampleDataHelper({required this.addDocument});

  Future<void> addSampleDocuments() async {
    final sampleDocs = [
      Document(
        id: 0,
        title: "Flutter BLoC Pattern Guide",
        content:
            "The BLoC (Business Logic Component) pattern is a design pattern that helps separate business logic from the presentation layer in Flutter applications. It uses streams and reactive programming to manage state effectively.",
        category: "Development",
        tags: const ["flutter", "bloc", "state-management", "architecture"],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Document(
        id: 0,
        title: "Machine Learning Basics",
        content:
            "Machine learning is a subset of artificial intelligence that enables computers to learn and make decisions from data without being explicitly programmed. It includes supervised learning, unsupervised learning, and reinforcement learning.",
        category: "AI/ML",
        tags: const ["machine-learning", "ai", "data-science", "algorithms"],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Document(
        id: 0,
        title: "Clean Architecture Principles",
        content:
            "Clean architecture is a software design philosophy that separates the concerns of a software application into distinct layers. It promotes testability, maintainability, and independence from frameworks and external dependencies.",
        category: "Architecture",
        tags: const [
          "clean-architecture",
          "design-patterns",
          "software-engineering"
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Document(
        id: 0,
        title: "Meeting Notes - Project Alpha",
        content:
            "Discussed the project timeline, resource allocation, and key milestones. The team agreed on the MVP features and decided to use agile methodology for development. Next meeting scheduled for next week.",
        category: "Work",
        tags: const ["meeting", "project-alpha", "timeline", "agile"],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Document(
        id: 0,
        title: "Recipe: Chocolate Chip Cookies",
        content:
            "Ingredients: 2 cups flour, 1 cup butter, 3/4 cup brown sugar, 1/2 cup white sugar, 2 eggs, 1 tsp vanilla, 1 tsp baking soda, 1/2 tsp salt, 2 cups chocolate chips. Mix dry ingredients, cream butter and sugars, add eggs and vanilla, combine all, add chocolate chips, bake at 375°F for 9-11 minutes.",
        category: "Personal",
        tags: const ["recipe", "baking", "cookies", "dessert"],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];

    for (final doc in sampleDocs) {
      await addDocument(AddDocumentParams(document: doc));
    }
  }
}
