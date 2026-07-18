import 'package:dashitomo/features/health/data/health_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts health JSON to and from a model', () {
    final response = HealthResponse.fromJson(const {'status': 'ok'});

    expect(response.status, 'ok');
    expect(response.toJson(), const {'status': 'ok'});
  });
}
