# MindVault 

[![Flutter](https://img.shields.io/badge/Flutter-3.35.1-02569B.svg?style=flat&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0-0175C2.svg?style=flat&logo=dart)](https://dart.dev)
[![Build Status](https://img.shields.io/github/actions/workflow/status/sohailmahmud/MindVault/ci.yml?branch=main&style=flat&logo=github)](https://github.com/sohailmahmud/MindVault/actions)
[![Coverage Status](https://coveralls.io/repos/github/sohailmahmud/MindVault/badge.svg?branch=main)](https://coveralls.io/github/sohailmahmud/MindVault?branch=main)

**MindVault** is a powerful on-device AI search application built with Flutter that helps you organize, search, and manage your documents using semantic search capabilities. All processing happens locally on your device, ensuring privacy and speed.

## Features

### Core Functionality
- **📄 Document Management**: Create, read, update, and delete documents with rich text content
- **🔍 AI-Powered Search**: Semantic search using advanced text similarity algorithms
- **📱 Modern UI**: Clean Material Design 3 interface with dark/light theme support
- **🏠 On-Device Processing**: All AI operations run locally for privacy and offline functionality
- **💾 Local Database**: Fast ObjectBox NoSQL database for document storage

### Advanced Features
- **🎯 Smart Search**: Fuzzy matching and Levenshtein distance algorithms for intelligent text matching
- **📋 Bulk Operations**: Select and delete multiple documents at once
- **🏷️ Categories & Tags**: Organize documents with categories and auto-generated tags
- **📊 Document Analytics**: Track creation dates and manage document metadata
- **🔄 Real-time Updates**: Reactive UI updates using BLoC state management

## Architecture

MindVault follows **Clean Architecture** principles with three distinct layers:

```
lib/
├── core/                          # Shared components
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── usecases/                  # Base use case classes
│   └── utils/                     # Utilities and helpers
├── features/
│   └── search/                    # Main feature module
│       ├── domain/                # Business logic layer
│       │   ├── entities/          # Core business objects
│       │   ├── repositories/      # Repository contracts
│       │   └── usecases/          # Business use cases
│       ├── data/                  # Data access layer
│       │   ├── datasources/       # Data source implementations
│       │   ├── models/            # Data models
│       │   └── repositories/      # Repository implementations
│       └── presentation/          # UI layer
│           ├── bloc/              # State management
│           ├── pages/             # App screens
│           └── widgets/           # Reusable UI components
└── main.dart                      # App entry point
```

## Getting Started

### Prerequisites
- Flutter 3.35.1 or higher
- Dart 3.9.0 or higher
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mindvault
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate ObjectBox models**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Dependencies

### Core Dependencies
- **flutter_bloc** (8.1.6): State management using the BLoC pattern
- **objectbox** (2.5.1): High-performance NoSQL database
- **get_it** (7.7.0): Dependency injection service locator
- **dartz** (0.10.1): Functional programming utilities
- **equatable** (2.0.5): Value equality for objects

### UI & Utilities
- **cupertino_icons** (1.0.2): iOS-style icons
- **path_provider** (2.1.5): File system path access
- **injectable** (2.5.1): Code generation for dependency injection

### Development Dependencies
- **flutter_lints** (2.0.3): Dart/Flutter linting rules
- **build_runner** (2.4.13): Code generation runner
- **objectbox_generator** (2.5.1): ObjectBox model generation

## Usage Guide

### Adding Documents
1. Tap the **"+"** floating action button
2. Enter a **title** for your document
3. Add **content** in the text area
4. Optionally select a **category**
5. Tap **"Save Document"**

### Searching Documents
1. Use the **search bar** at the top of the main screen
2. Type your search query - the app will find documents using:
   - **Exact matches** in titles and content
   - **Partial matches** for similar words
   - **Fuzzy matching** for misspellings
   - **Semantic similarity** for related concepts

### Editing Documents
1. Tap on any document card
2. Modify the **title**, **content**, or **category**
3. Tap **"Update Document"** to save changes

### Bulk Operations
1. Long-press on any document to enter **selection mode**
2. Tap additional documents to select them
3. Use the **delete button** in the app bar to remove selected documents
4. Tap the **"X"** to exit selection mode

### Categories
Documents can be organized into categories:
- **Work**: Professional documents and notes
- **Personal**: Personal thoughts and ideas
- **Study**: Educational content and research
- **Project**: Project-related documentation

## AI Features

### Semantic Search Algorithm
MindVault uses a sophisticated multi-layered search approach:

1. **Text Preprocessing**: Normalizes input and splits into words
2. **Word Matching**: Direct and partial word comparisons
3. **Fuzzy Matching**: Levenshtein distance for typo tolerance
4. **Similarity Scoring**: Weighted relevance scoring
5. **Result Ranking**: Orders results by relevance score

### Smart Features (Planned)
- **Auto-categorization**: Automatic category suggestions based on content
- **Tag extraction**: Auto-generate relevant tags from document content
- **Content summarization**: Generate brief summaries of long documents
- **Similar document discovery**: Find related documents automatically

## UI/UX Features

### Material Design 3
- **Dynamic theming** with system color extraction
- **Adaptive layouts** for different screen sizes
- **Smooth animations** and transitions
- **Accessibility support** with semantic labels

### Dark Mode Support
- Automatic theme switching based on system preference
- Optimized colors for both light and dark themes
- Consistent branding across themes

## Privacy & Security

- **100% On-Device Processing**: No data leaves your device
- **Local Database**: All documents stored locally using ObjectBox
- **No Network Requests**: App works completely offline
- **No Analytics**: No tracking or data collection
- **Open Source**: Transparent and auditable codebase

## Testing

Run the test suite:
```bash
flutter test
```

Run integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)
- 🚧 **Web** (Coming soon)
- 🚧 **Desktop** (Windows, macOS, Linux - Coming soon)

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Flutter Team** for the amazing cross-platform framework
- **ObjectBox** for the high-performance local database
- **BLoC Library** for elegant state management
- **Material Design** for the beautiful design system

## Roadmap

### Version 2.0
- [ ] Real TensorFlow Lite model integration
- [ ] Voice-to-text document creation
- [ ] Document sharing and export
- [ ] Cloud sync (optional)
- [ ] Advanced text formatting

### Version 3.0
- [ ] Multi-language support
- [ ] Plugin system for extensibility
- [ ] Advanced AI features (summarization, Q&A)
- [ ] Collaborative editing
- [ ] Desktop applications

## Support

If you encounter any issues or have questions:
- Open an [issue](../../issues) on GitHub
- Check the [FAQ](../../wiki/FAQ) in our wiki
- Join our [Discord community](https://discord.gg/mindvault)

---

**Built with ❤️ using Flutter & Clean Architecture**

*MindVault - Your Personal Knowledge Vault*
