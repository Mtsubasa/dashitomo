import 'dart:async';

import 'package:dashitomo/core/config/app_config.dart';
import 'package:dashitomo/features/health/data/health_repository.dart';
import 'package:dashitomo/features/health/data/health_response.dart';
import 'package:dashitomo/features/health/presentation/health_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/health_fakes.dart';

void main() {
  final config = AppConfig(
    appEnv: 'test',
    apiBaseUrl: Uri.parse('http://api.example.test'),
  );

  testWidgets('shows loading and then success', (tester) async {
    final completer = Completer<HealthResponse>();
    await tester.pumpWidget(
      _testApp(
        config: config,
        repository: FakeHealthRepository(() => completer.future),
      ),
    );

    expect(find.byKey(const Key('health-loading')), findsOneWidget);

    completer.complete(const HealthResponse(status: 'ok'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('health-success')), findsOneWidget);
    expect(find.text('Go API 接続成功: ok'), findsOneWidget);
  });

  testWidgets('shows a generic error without leaking details', (tester) async {
    await tester.pumpWidget(
      _testApp(
        config: config,
        repository: FakeHealthRepository(
          () => Future.error(StateError('internal detail')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('health-error')), findsOneWidget);
    expect(find.textContaining('internal detail'), findsNothing);
  });

  testWidgets('retries a failed request', (tester) async {
    var calls = 0;
    final repository = FakeHealthRepository(() async {
      calls += 1;
      if (calls == 1) {
        throw StateError('first request failed');
      }
      return const HealthResponse(status: 'ok');
    });
    await tester.pumpWidget(_testApp(config: config, repository: repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('health-error')), findsOneWidget);

    await tester.tap(find.byKey(const Key('health-retry')));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.byKey(const Key('health-success')), findsOneWidget);
  });
}

Widget _testApp({
  required AppConfig config,
  required FakeHealthRepository repository,
}) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(config),
      healthRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: HealthScreen()),
  );
}
