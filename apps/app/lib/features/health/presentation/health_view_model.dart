import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_repository.dart';
import '../data/health_response.dart';

final healthViewModelProvider =
    AsyncNotifierProvider<HealthViewModel, HealthResponse>(HealthViewModel.new);

class HealthViewModel extends AsyncNotifier<HealthResponse> {
  @override
  Future<HealthResponse> build() {
    return ref.watch(healthRepositoryProvider).getHealth();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(healthRepositoryProvider).getHealth(),
    );
  }
}
