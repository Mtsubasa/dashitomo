import 'package:dashitomo/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    testWidgets('主要領域が重ならない: ${size.width}x${size.height}', (tester) async {
      await _pumpHome(tester, size: size);

      expect(tester.takeException(), isNull);

      final top = tester.getRect(find.byKey(const ValueKey('home-top-hud')));
      final pet = tester.getRect(find.byKey(const ValueKey('home-pet-stage')));
      final bottom = tester.getRect(
        find.byKey(const ValueKey('home-bottom-navigation')),
      );

      expect(top.bottom, lessThanOrEqualTo(pet.top));
      expect(pet.bottom, lessThanOrEqualTo(bottom.top));
      expect(bottom.bottom, lessThanOrEqualTo(size.height));
    });
  }

  testWidgets('Safe Area内に操作要素を配置する', (tester) async {
    const size = Size(390, 844);
    const padding = EdgeInsets.fromLTRB(0, 44, 0, 34);
    await _pumpHome(tester, size: size, padding: padding);

    expect(tester.takeException(), isNull);

    final menu = tester.getRect(find.byKey(const ValueKey('home-menu-button')));
    final bottom = tester.getRect(
      find.byKey(const ValueKey('home-bottom-navigation')),
    );

    expect(menu.top, greaterThanOrEqualTo(padding.top));
    expect(bottom.bottom, lessThanOrEqualTo(size.height - padding.bottom));
    expect(menu.width, greaterThanOrEqualTo(48));
    expect(menu.height, greaterThanOrEqualTo(48));
  });

  testWidgets('カメラボタンを操作可能なカーソルとツールチップで表示する', (tester) async {
    await _pumpHome(tester, size: const Size(402, 755));

    final cameraButton = tester.widget<InkWell>(
      find.byKey(const ValueKey('home-camera-button')),
    );

    expect(cameraButton.mouseCursor, SystemMouseCursors.click);
    expect(cameraButton.onTap, isNotNull);
    expect(find.byTooltip('カメラ'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size, padding: padding),
          child: const HomeScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
