import 'package:integration_test/integration_test.dart';

// Import all integration test files
import 'app_test.dart' as app_tests;
import 'document_management_test.dart' as document_tests;
import 'search_features_test.dart' as search_tests;
import 'user_experience_test.dart' as ux_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Run all integration test suites
  app_tests.main();
  document_tests.main();
  search_tests.main();
  ux_tests.main();
}
