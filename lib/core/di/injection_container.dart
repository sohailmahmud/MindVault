import 'package:get_it/get_it.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/search/data/datasources/ai_data_source.dart';
import '../../features/search/data/datasources/search_local_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/add_document.dart';
import '../../features/search/domain/usecases/delete_document.dart';
import '../../features/search/domain/usecases/delete_multiple_documents.dart';
import '../../features/search/domain/usecases/get_all_documents.dart';
import '../../features/search/domain/usecases/get_document_by_id.dart';
import '../../features/search/domain/usecases/search_documents.dart';
import '../../features/search/domain/usecases/semantic_search.dart';
import '../../features/search/domain/usecases/update_document.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../objectbox.g.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final docsDir = await getApplicationDocumentsDirectory();
  final store = await openStore(directory: p.join(docsDir.path, 'mindvault-db'));
  serviceLocator.registerLazySingleton<Store>(() => store);

  // Data sources
  serviceLocator.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(store: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<AIDataSource>(
    () => AIDataSourceImpl(),
  );

  // Repository
  serviceLocator.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      localDataSource: serviceLocator(),
      aiDataSource: serviceLocator(),
    ),
  );

  // Use cases
  serviceLocator.registerLazySingleton(() => SearchDocuments(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SemanticSearch(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetAllDocuments(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AddDocument(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateDocument(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteDocument(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeleteMultipleDocuments(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetDocumentById(serviceLocator()));

  // BLoC
  serviceLocator.registerFactory(
    () => SearchBloc(
      searchDocuments: serviceLocator(),
      semanticSearch: serviceLocator(),
      getAllDocuments: serviceLocator(),
      addDocument: serviceLocator(),
      updateDocument: serviceLocator(),
      deleteDocument: serviceLocator(),
      deleteMultipleDocuments: serviceLocator(),
      getDocumentById: serviceLocator(),
    ),
  );

  // Initialize AI model
  await serviceLocator<AIDataSource>().initializeModel();
}