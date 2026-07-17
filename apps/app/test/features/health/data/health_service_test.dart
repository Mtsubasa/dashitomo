import 'dart:typed_data';

import 'package:dashitomo/features/health/data/health_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requests /healthz and parses the response', () async {
    final adapter = _StubHttpClientAdapter(
      response: ResponseBody.fromString(
        '{"status":"ok"}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json; charset=utf-8'],
        },
      ),
    );
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));

    final response = await HealthService(dio).fetchHealth();

    expect(response.status, 'ok');
    expect(adapter.lastRequest?.method, 'GET');
    expect(
      adapter.lastRequest?.uri,
      Uri.parse('http://localhost:8080/healthz'),
    );
  });

  test('rejects an empty response body', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'))
      ..httpClientAdapter = _StubHttpClientAdapter(
        response: ResponseBody.fromString(
          '',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json; charset=utf-8'],
          },
        ),
      );
    addTearDown(() => dio.close(force: true));

    expect(
      HealthService(dio).fetchHealth,
      throwsA(anyOf(isA<FormatException>(), isA<DioException>())),
    );
  });
}

class _StubHttpClientAdapter implements HttpClientAdapter {
  _StubHttpClientAdapter({required this.response});

  final ResponseBody response;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return response;
  }

  @override
  void close({bool force = false}) {}
}
