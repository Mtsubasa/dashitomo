import 'package:dashitomo/app/app.dart';
import 'package:dashitomo/core/config/app_config.dart';
import 'package:dashitomo/features/health/data/health_repository.dart';
import 'package:dashitomo/features/health/data/health_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/health_fakes.dart';

void main() {
  testWidgets('builds MaterialApp.router', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              appEnv: 'test',
              apiBaseUrl: Uri.parse('http://api.example.test'),
            ),
          ),
          healthRepositoryProvider.overrideWithValue(
            FakeHealthRepository(
              () async => const HealthResponse(status: 'ok'),
            ),
          ),
        ],
        child: const DashitomoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('かつ男'), findsOneWidget);
  });

  testWidgets('ホームと撮影画面を往復できる', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              appEnv: 'test',
              apiBaseUrl: Uri.parse('http://api.example.test'),
            ),
          ),
          healthRepositoryProvider.overrideWithValue(
            FakeHealthRepository(
              () async => const HealthResponse(status: 'ok'),
            ),
          ),
        ],
        child: const DashitomoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-camera-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('camera-screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('camera-close-button')));
    await tester.pumpAndSettle();

    expect(find.text('かつ男'), findsOneWidget);
    expect(find.byKey(const ValueKey('camera-screen')), findsNothing);
  });
}
