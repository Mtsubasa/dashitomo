import 'package:dashitomo/features/health/data/health_repository.dart';
import 'package:dashitomo/features/health/data/health_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/health_fakes.dart';

void main() {
  test('returns the response supplied by the health service', () async {
    var calls = 0;
    final service = FakeHealthService(() async {
      calls += 1;
      return const HealthResponse(status: 'ok');
    });

    final response = await HealthRepository(service).getHealth();

    expect(response, const HealthResponse(status: 'ok'));
    expect(calls, 1);
  });
}
