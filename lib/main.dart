import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'features/search/presentation/pages/search_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const MindVaultApp());
}

class MindVaultApp extends StatelessWidget {
  const MindVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindVault - AI Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
