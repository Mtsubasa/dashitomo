import 'package:dashitomo/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('uses local defaults when dart defines are omitted', () {
      final config = AppConfig.fromEnvironment();

      expect(config.appEnv, 'local');
      expect(config.apiBaseUrl, Uri.parse('http://localhost:8080'));
    });

    test('accepts absolute HTTP and HTTPS API URLs', () {
      expect(
        AppConfig.parseApiBaseUrl('https://api.example.test/v1'),
        Uri.parse('https://api.example.test/v1'),
      );
      expect(
        AppConfig.parseApiBaseUrl('http://localhost:8080'),
        Uri.parse('http://localhost:8080'),
      );
    });

    test('allows localhost in local environments', () {
      final config = AppConfig.fromValues(
        appEnv: 'local',
        apiBaseUrl: 'http://localhost:8080',
      );

      expect(config.apiBaseUrl, Uri.parse('http://localhost:8080'));
    });

    test('rejects localhost in production', () {
      expect(
        () => AppConfig.fromValues(
          appEnv: 'production',
          apiBaseUrl: 'http://localhost:8080',
        ),
        throwsStateError,
      );
      expect(
        () => AppConfig.fromValues(
          appEnv: 'production',
          apiBaseUrl: 'http://127.0.0.1:8080',
        ),
        throwsStateError,
      );
    });

    test('accepts a non-local API URL in production', () {
      final config = AppConfig.fromValues(
        appEnv: 'production',
        apiBaseUrl: 'https://api.example.test/v1',
      );

      expect(config.apiBaseUrl, Uri.parse('https://api.example.test/v1'));
    });

    test('rejects relative and non-HTTP API URLs', () {
      expect(
        () => AppConfig.parseApiBaseUrl('/healthz'),
        throwsFormatException,
      );
      expect(
        () => AppConfig.parseApiBaseUrl('ftp://example.test'),
        throwsFormatException,
      );
    });

    test('rejects API URLs containing query, fragment, or userinfo', () {
      for (final value in [
        'https://api.example.test?x=1',
        'https://api.example.test#health',
        'https://user:password@api.example.test',
      ]) {
        expect(
          () => AppConfig.parseApiBaseUrl(value),
          throwsFormatException,
          reason: value,
        );
      }
    });
  });
}
