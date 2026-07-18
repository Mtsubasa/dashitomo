import 'package:dashitomo/features/health/data/health_repository.dart';
import 'package:dashitomo/features/health/data/health_response.dart';
import 'package:dashitomo/features/health/data/health_service.dart';
import 'package:dio/dio.dart';

class FakeHealthService extends HealthService {
  FakeHealthService(this.onFetch) : super(Dio());

  final Future<HealthResponse> Function() onFetch;

  @override
  Future<HealthResponse> fetchHealth() => onFetch();
}

class FakeHealthRepository extends HealthRepository {
  FakeHealthRepository(this.onGet)
    : super(
        FakeHealthService(
          () => throw StateError('The repository fake does not use a service.'),
        ),
      );

  final Future<HealthResponse> Function() onGet;

  @override
  Future<HealthResponse> getHealth() => onGet();
}
