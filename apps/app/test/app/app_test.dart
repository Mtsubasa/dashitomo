import 'package:dashitomo/app/app.dart';
import 'package:dashitomo/core/config/app_config.dart';
import 'package:dashitomo/features/health/data/health_repository.dart';
import 'package:dashitomo/features/health/data/health_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets('下部ナビゲーションから各画面へ遷移する', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 755);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

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

    await tester.tap(find.text('図鑑'));
    await tester.pumpAndSettle();
    expect(find.text('🌱  かつお菜図鑑  🌱'), findsOneWidget);

    await tester.tap(find.text('日記'));
    await tester.pumpAndSettle();
    expect(find.text('現在開発中です'), findsOneWidget);

    await tester.tap(find.text('会話'));
    await tester.pumpAndSettle();
    expect(find.text('現在開発中です'), findsOneWidget);

    await tester.tap(find.text('ガチャ'));
    await tester.pumpAndSettle();
    expect(find.text('現在開発中です'), findsOneWidget);
  });

  testWidgets('ホームと撮影画面を往復できる', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 755);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

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

  testWidgets('お別れ画面をルートから表示して操作できる', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 755);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

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

    final context = tester.element(find.text('かつ男'));
    context.go('/farewell');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('farewell-screen')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('farewell-action-button')));
    await tester.pump();

    expect(find.byKey(const ValueKey('farewell-screen')), findsOneWidget);
  });
}
