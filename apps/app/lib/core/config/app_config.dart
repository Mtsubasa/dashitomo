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

    return AppConfig(appEnv: appEnv, apiBaseUrl: parseApiBaseUrl(apiBaseUrl));
  }

  final String appEnv;
  final Uri apiBaseUrl;

  static Uri parseApiBaseUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw FormatException('API_BASE_URL must be an absolute HTTP(S) URL.');
    }
    return uri;
  }
}
