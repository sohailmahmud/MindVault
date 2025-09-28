import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mindvault/core/di/injection_container.dart';

void main() {
  group('Dependency Injection Container Tests', () {
    tearDown(() {
      // Clean up after each test
      GetIt.instance.reset();
    });

    test('serviceLocator should be GetIt instance', () {
      expect(serviceLocator, isA<GetIt>());
      expect(serviceLocator, same(GetIt.instance));
    });

    test('serviceLocator provides expected methods', () {
      expect(serviceLocator.isRegistered, isA<Function>());
      expect(serviceLocator.registerLazySingleton, isA<Function>());
      expect(serviceLocator.registerFactory, isA<Function>());
      expect(serviceLocator.get, isA<Function>());
      expect(serviceLocator.reset, isA<Function>());
    });

    test('serviceLocator maintains singleton behavior', () {
      final locator1 = serviceLocator;
      final locator2 = serviceLocator;
      expect(locator1, same(locator2));
    });

    test('can register and retrieve basic dependencies', () {
      serviceLocator.registerLazySingleton<String>(() => 'test_value');
      serviceLocator.registerFactory<int>(() => DateTime.now().millisecondsSinceEpoch);
      
      expect(serviceLocator.isRegistered<String>(), isTrue);
      expect(serviceLocator.isRegistered<int>(), isTrue);
      expect(serviceLocator.get<String>(), equals('test_value'));
      expect(serviceLocator.get<int>(), isA<int>());
      
      // Test lazy singleton behavior
      expect(serviceLocator.get<String>(), same(serviceLocator.get<String>()));
      
      // Verify factory is registered and returns values
      expect(serviceLocator.isRegistered<int>(), isTrue);
    });

    test('can handle dependency chains', () {
      serviceLocator.registerLazySingleton<String>(() => 'base');
      serviceLocator.registerLazySingleton<int>(() => serviceLocator.get<String>().length);
      serviceLocator.registerFactory<bool>(() => serviceLocator.get<int>() > 0);
      
      expect(serviceLocator.get<String>(), equals('base'));
      expect(serviceLocator.get<int>(), equals(4));
      expect(serviceLocator.get<bool>(), isTrue);
    });
    
    test('initializeDependencies completes without error', () async {
      // This test ensures the dependency injection setup doesn't crash
      await expectLater(
        () => initializeDependencies(),
        returnsNormally,
      );
    }, skip: 'Requires platform-specific setup for ObjectBox and path_provider');

    test('serviceLocator is accessible', () {
      expect(serviceLocator, isNotNull);
      expect(serviceLocator, isA<GetIt>());
    });

    test('GetIt reset functionality can be called', () {
      // Just test that reset method exists and can be called
      expect(serviceLocator.reset, isA<Function>());
      
      // Test that we can call reset without exceptions
      expect(() => serviceLocator.reset(), returnsNormally);
    });

    test('supports named instances', () {
      serviceLocator.registerLazySingleton<String>(() => 'instance1', instanceName: 'first');
      serviceLocator.registerLazySingleton<String>(() => 'instance2', instanceName: 'second');
      
      expect(serviceLocator.get<String>(instanceName: 'first'), equals('instance1'));
      expect(serviceLocator.get<String>(instanceName: 'second'), equals('instance2'));
      expect(serviceLocator.get<String>(instanceName: 'first'), 
             isNot(same(serviceLocator.get<String>(instanceName: 'second'))));
    });
  });
}