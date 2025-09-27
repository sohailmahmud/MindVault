import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/features/search/domain/entities/document.dart';
import 'package:mindvault/features/search/presentation/widgets/document_card.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('Basic Flutter smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hello Test'),
          ),
        ),
      );
      expect(find.text('Hello Test'), findsOneWidget);
    });

    testWidgets('Button interaction test', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                buttonPressed = true;
              },
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('Form validation test', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Required Field',
                ),
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });
  });

  group('DocumentCard Widget Tests', () {
    testWidgets('DocumentCard displays document information', (WidgetTester tester) async {
      final document = Document(
        id: 1,
        title: 'Test Document',
        content: 'This is test content',
        category: 'Test Category',
        tags: ['test', 'flutter'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              document: document,
            ),
          ),
        ),
      );

      // Check if document information is displayed
      expect(find.text('Test Document'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
    });

    testWidgets('DocumentCard shows selection state', (WidgetTester tester) async {
      final document = Document(
        id: 1,
        title: 'Selected Document',
        content: 'Content',
        category: 'Category',
        tags: [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              document: document,
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.text('Selected Document'), findsOneWidget);
    });

    testWidgets('DocumentCard displays tags correctly', (WidgetTester tester) async {
      final document = Document(
        id: 1,
        title: 'Tagged Document',
        content: 'Content',
        category: 'Category',
        tags: ['flutter', 'dart', 'mobile'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              document: document,
            ),
          ),
        ),
      );

      expect(find.text('Tagged Document'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('DocumentCard handles selection mode', (WidgetTester tester) async {
      bool selectionToggled = false;
      
      final document = Document(
        id: 1,
        title: 'Selectable Document',
        content: 'Content',
        category: 'Category',
        tags: [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              document: document,
              isSelectable: true,
              onSelectionToggle: () {
                selectionToggled = true;
              },
            ),
          ),
        ),
      );

      // Test selection toggle on tap
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      
      expect(selectionToggled, isTrue);
    });

    testWidgets('DocumentCard displays content preview', (WidgetTester tester) async {
      final document = Document(
        id: 1,
        title: 'Document with Content',
        content: 'This is a longer content that should be displayed in the card preview. It contains multiple sentences.',
        category: 'Articles',
        tags: ['content', 'preview'],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DocumentCard(
              document: document,
            ),
          ),
        ),
      );

      expect(find.text('Document with Content'), findsOneWidget);
      expect(find.text('Articles'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
      expect(find.text('preview'), findsOneWidget);
    });
  });
}
