import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import 'health_view_model.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final health = ref.watch(healthViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('だしトモ')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('APP_ENV: ${config.appEnv}'),
                const SizedBox(height: 8),
                Text('API Base URL: ${config.apiBaseUrl}'),
                const SizedBox(height: 24),
                health.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      key: Key('health-loading'),
                    ),
                  ),
                  data: (response) => Text(
                    'Go API 接続成功: ${response.status}',
                    key: const Key('health-success'),
                    textAlign: TextAlign.center,
                  ),
                  error: (error, stackTrace) => const Text(
                    'Go API に接続できませんでした',
                    key: Key('health-error'),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('health-retry'),
                  onPressed: health.isLoading
                      ? null
                      : () {
                          ref.read(healthViewModelProvider.notifier).retry();
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
