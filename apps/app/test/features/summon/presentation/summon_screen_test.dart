import 'package:dashitomo/features/summon/presentation/summon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  final sizes = <Size>[
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(402, 755),
    const Size(412, 915),
    const Size(430, 932),
  ];

  for (final size in sizes) {
    testWidgets('主要領域が収まる: ${size.width}x${size.height}', (tester) async {
      await _pumpSummon(tester, size: size);

      expect(tester.takeException(), isNull);

      final heading = tester.getRect(
        find.byKey(const ValueKey('summon-heading-area')),
      );
      final stage = tester.getRect(find.byKey(const ValueKey('summon-stage')));
      final panel = tester.getRect(
        find.byKey(const ValueKey('summon-naming-panel')),
      );
      final field = tester.getRect(
        find.byKey(const ValueKey('summon-name-field')),
      );
      final button = tester.getRect(
        find.byKey(const ValueKey('summon-welcome-button')),
      );

      expect(heading.bottom, lessThanOrEqualTo(stage.top + 0.01));
      expect(stage.bottom, lessThanOrEqualTo(panel.top + 0.01));
      expect(panel.bottom, lessThanOrEqualTo(size.height));
      expect(field.height, greaterThanOrEqualTo(47.99));
      expect(button.height, greaterThanOrEqualTo(47.99));
    });
  }

  testWidgets('名前を入力してホームへ進める', (tester) async {
    await _pumpSummon(tester, size: const Size(402, 755));

    expect(find.text('ようこそ かつお菜太郎'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('summon-name-field')),
      'だしトモ',
    );
    await tester.pump();

    expect(find.text('ようこそ だしトモ'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('summon-welcome-button')));
    await tester.pumpAndSettle();

    expect(find.text('ホーム'), findsOneWidget);
  });

  testWidgets('名前が空なら確定できない', (tester) async {
    await _pumpSummon(tester, size: const Size(402, 755));

    await tester.enterText(
      find.byKey(const ValueKey('summon-name-field')),
      '   ',
    );
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('summon-welcome-button')),
    );
    expect(button.onPressed, isNull);
  });
}

Future<void> _pumpSummon(WidgetTester tester, {required Size size}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  final router = GoRouter(
    initialLocation: '/summon',
    routes: [
      GoRoute(path: '/summon', builder: (_, _) => const SummonScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('ホーム')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(child: MaterialApp.router(routerConfig: router)),
  );
  await tester.pumpAndSettle();
}
