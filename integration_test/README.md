# MindVault Integration Tests

This directory contains comprehensive integration tests for the MindVault application, testing complete user workflows and app functionality.

## Test Structure

### 1. App Tests (`app_test.dart`)
- **App startup and basic navigation**: Verifies app initialization and main UI elements
- **Document creation workflow**: End-to-end document creation process
- **Document search workflow**: Complete search functionality testing
- **AI search mode toggle**: Search mode switching functionality
- **Document details navigation**: Navigation to and from document details
- **Selection mode and bulk operations**: Multi-document selection and operations
- **Error handling and recovery**: Form validation and error scenarios
- **App theme and visual consistency**: UI theme and design consistency

### 2. Document Management Tests (`document_management_test.dart`)
- **Complete document CRUD workflow**: Create, Read, Update, Delete operations
- **Document categories and filtering**: Category-based organization and filtering
- **Document validation and error handling**: Input validation and error scenarios
- **Large document handling**: Performance with large content documents

### 3. Search Features Tests (`search_features_test.dart`)
- **Text search functionality**: Exact, partial, and case-insensitive search
- **AI semantic search functionality**: Semantic search capabilities
- **Search performance and responsiveness**: Performance with multiple documents
- **Search edge cases and error handling**: Special characters, empty results, long queries
- **Search mode switching during active search**: Dynamic search mode changes

### 4. User Experience Tests (`user_experience_test.dart`)
- **App startup performance and initialization**: Startup time and initialization checks
- **Navigation responsiveness and UI feedback**: UI responsiveness and feedback
- **Memory usage with many documents**: Performance with large document sets
- **UI theme consistency and accessibility**: Theme consistency and accessibility features
- **Error recovery and app stability**: App stability under stress
- **Database persistence and data integrity**: Data persistence across sessions
- **Offline functionality and local storage**: Offline capabilities and local storage

## Running Integration Tests

### Prerequisites
- Flutter SDK 3.35.1 or higher
- Device or emulator connected
- App dependencies installed (`flutter pub get`)

### Run All Tests
```bash
# Run all integration tests
flutter test integration_test/

# Run specific test file
flutter test integration_test/app_test.dart

# Run with verbose output
flutter test integration_test/ --verbose
```

### Run on Specific Platform
```bash
# Run on connected device
flutter test integration_test/ -d <device-id>

# Run on Android emulator
flutter test integration_test/ -d android

# Run on iOS simulator
flutter test integration_test/ -d ios
```

### Generate Test Reports
```bash
# Run tests with coverage
flutter test integration_test/ --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Test Categories

### 🚀 **Startup & Navigation**
- App initialization time (< 5 seconds)
- Navigation responsiveness (< 1 second)
- Memory usage optimization
- UI theme consistency

### 📄 **Document Operations**
- Document creation and validation
- Document reading and display
- Document search and filtering
- Document deletion and bulk operations

### 🔍 **Search Functionality**
- Text-based search (exact, partial, fuzzy)
- AI semantic search capabilities
- Search performance (< 3 seconds with 50+ documents)
- Search mode switching and edge cases

### 🎯 **User Experience**
- Form validation and error handling
- Offline functionality verification
- Data persistence testing
- Accessibility and theme consistency

## Test Data

Integration tests create temporary test documents during execution. Test data includes:
- Various document titles and content lengths
- Different categories (Work, Personal, Study, Project)
- Special characters and edge case content
- Large documents for performance testing

## Performance Benchmarks

- **App Startup**: < 5 seconds
- **Navigation**: < 1 second
- **Search Operations**: < 3 seconds (with 50+ documents)
- **Document Creation**: < 2 seconds
- **Scrolling Performance**: Smooth with 50+ documents

## Troubleshooting

### Common Issues
1. **Timeout Errors**: Increase `pumpAndSettle` timeouts for slower devices
2. **Widget Not Found**: Ensure proper `pumpAndSettle()` after navigation
3. **State Issues**: Add appropriate delays between state-changing operations

### Debugging Tips
```dart
// Add debug prints
print('Current widgets: ${find.byType(Widget).evaluate().length}');

// Take screenshots during tests
await binding.convertFlutterSurfaceToImage();

// Add longer delays for debugging
await tester.pumpAndSettle(const Duration(seconds: 2));
```

## Continuous Integration

These integration tests are designed to run in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Integration Tests
  run: |
    flutter test integration_test/ --machine > test_results.json
    
- name: Upload Test Results
  uses: actions/upload-artifact@v2
  with:
    name: integration-test-results
    path: test_results.json
```

## Contributing

When adding new integration tests:

1. **Follow naming conventions**: `*_test.dart` for test files
2. **Group related tests**: Use `group()` for logical test grouping
3. **Add documentation**: Include test descriptions and expected outcomes
4. **Performance considerations**: Include timing expectations where relevant
5. **Cleanup**: Ensure tests don't affect each other's state

## Test Coverage

Integration tests cover:
- ✅ App initialization and navigation
- ✅ Document CRUD operations
- ✅ Search functionality (text and AI)
- ✅ User interface interactions
- ✅ Error handling and validation
- ✅ Performance and responsiveness
- ✅ Data persistence and offline functionality

Total Integration Test Coverage: **8 test suites, 25+ individual test scenarios**