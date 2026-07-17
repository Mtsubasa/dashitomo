import 'package:flutter_riverpod/flutter_riverpod.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

class AppConfig {
  const AppConfig({required this.appEnv, required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'local');
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );

    return AppConfig.fromValues(appEnv: appEnv, apiBaseUrl: apiBaseUrl);
  }

  factory AppConfig.fromValues({
    required String appEnv,
    required String apiBaseUrl,
  }) {
    final parsedApiBaseUrl = parseApiBaseUrl(apiBaseUrl);
    if (appEnv == 'production' && isLocalApiBaseUrl(parsedApiBaseUrl)) {
      throw StateError(
        'API_BASE_URL must not point to localhost in production.',
      );
    }

    return AppConfig(appEnv: appEnv, apiBaseUrl: parsedApiBaseUrl);
  }

  final String appEnv;
  final Uri apiBaseUrl;

  static Uri parseApiBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty) {
      throw FormatException('API_BASE_URL must be an absolute HTTP(S) URL.');
    }
    return uri;
  }

  static bool isLocalApiBaseUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1';
  }
}
