import 'package:dashitomo/features/camera/presentation/camera_screen.dart';
import 'package:flutter/material.dart';
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
    testWidgets('主要要素が画面内に収まる: ${size.width}x${size.height}', (tester) async {
      await _pumpCamera(tester, size: size);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('camera-preview-mock')), findsOneWidget);
      expect(find.byKey(const ValueKey('camera-pet')), findsOneWidget);

      final close = tester.getRect(
        find.byKey(const ValueKey('camera-close-button')),
      );
      final shutter = tester.getRect(
        find.byKey(const ValueKey('camera-shutter-control')),
      );
      final switchControl = tester.getRect(
        find.byKey(const ValueKey('camera-switch-control')),
      );

      for (final control in [close, shutter, switchControl]) {
        expect(control.left, greaterThanOrEqualTo(0));
        expect(control.top, greaterThanOrEqualTo(0));
        expect(control.right, lessThanOrEqualTo(size.width));
        expect(control.bottom, lessThanOrEqualTo(size.height));
      }
      expect(close.width, greaterThanOrEqualTo(48));
      expect(close.height, greaterThanOrEqualTo(48));
    });
  }

  testWidgets('操作要素をSafe Area内に配置する', (tester) async {
    const size = Size(390, 844);
    const padding = EdgeInsets.fromLTRB(0, 44, 0, 34);
    await _pumpCamera(tester, size: size, padding: padding);

    final close = tester.getRect(
      find.byKey(const ValueKey('camera-close-button')),
    );
    final shutter = tester.getRect(
      find.byKey(const ValueKey('camera-shutter-control')),
    );
    final switchControl = tester.getRect(
      find.byKey(const ValueKey('camera-switch-control')),
    );

    expect(close.top, greaterThanOrEqualTo(padding.top));
    expect(shutter.bottom, lessThanOrEqualTo(size.height - padding.bottom));
    expect(
      switchControl.bottom,
      lessThanOrEqualTo(size.height - padding.bottom),
    );
  });

  testWidgets('シャッターと切替は画面遷移を行わない', (tester) async {
    await _pumpCamera(tester, size: const Size(402, 755));

    await tester.tap(
      find.byKey(const ValueKey('camera-shutter-control')),
      warnIfMissed: false,
    );
    await tester.tap(
      find.byKey(const ValueKey('camera-switch-control')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('camera-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('閉じるボタンをクリックカーソルで表示する', (tester) async {
    await _pumpCamera(tester, size: const Size(402, 755));

    final closeButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const ValueKey('camera-close-button')),
        matching: find.byType(IconButton),
      ),
    );

    expect(closeButton.mouseCursor, SystemMouseCursors.click);
  });
}

Future<void> _pumpCamera(
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
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size, padding: padding),
        child: const CameraScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
