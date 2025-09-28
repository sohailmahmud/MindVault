import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/core/di/injection_container.dart';

void main() {
  group('Dependency Injection Container Tests', () {
    
    test('serviceLocator is accessible', () {
      // Test that the service locator getter works
      expect(serviceLocator, isNotNull);
      expect(serviceLocator.runtimeType.toString(), contains('GetIt'));
    });

    test('can register and retrieve dependencies', () {
      // Reset and register a simple dependency manually
      serviceLocator.reset();
      serviceLocator.registerFactory<String>(() => 'test');
      
      expect(serviceLocator.isRegistered<String>(), isTrue);
      expect(serviceLocator<String>(), equals('test'));
    });

    test('service locator starts clean after reset', () {
      serviceLocator.reset();
      // Simply verify reset doesn't throw an error
      expect(() => serviceLocator.reset(), returnsNormally);
    });
  });
}