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
  });
}
