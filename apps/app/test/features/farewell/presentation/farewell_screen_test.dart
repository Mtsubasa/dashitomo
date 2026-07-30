import 'package:dashitomo/features/farewell/presentation/farewell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layoutTolerance = 0.001;
  final sizes = <Size>[
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(402, 755),
    const Size(412, 915),
    const Size(430, 932),
  ];

  for (final size in sizes) {
    testWidgets('主要領域が画面内で順序を保つ: ${size.width}x${size.height}', (tester) async {
      await _pumpFarewell(tester, size: size);

      expect(tester.takeException(), isNull);
      expect(find.text('この子をお見送りしますよ'), findsOneWidget);
      expect(find.byKey(const ValueKey('farewell-pet')), findsOneWidget);
      expect(find.text('いただきます'), findsOneWidget);

      final message = tester.getRect(
        find.byKey(const ValueKey('farewell-message-area')),
      );
      final pet = tester.getRect(
        find.byKey(const ValueKey('farewell-pet-stage')),
      );
      final action = tester.getRect(
        find.byKey(const ValueKey('farewell-action-button')),
      );

      expect(message.bottom, lessThanOrEqualTo(pet.top));
      expect(pet.bottom, lessThanOrEqualTo(action.top));
      expect(action.left, greaterThanOrEqualTo(0));
      expect(action.right, lessThanOrEqualTo(size.width));
      expect(action.bottom, lessThanOrEqualTo(size.height));
      expect(action.height, greaterThanOrEqualTo(48 - layoutTolerance));
    });
  }

  testWidgets('操作要素をSafe Area内に配置する', (tester) async {
    const size = Size(390, 844);
    const padding = EdgeInsets.fromLTRB(0, 44, 0, 34);
    await _pumpFarewell(tester, size: size, padding: padding);

    final action = tester.getRect(
      find.byKey(const ValueKey('farewell-action-button')),
    );

    expect(action.top, greaterThanOrEqualTo(padding.top));
    expect(action.bottom, lessThanOrEqualTo(size.height - padding.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('いただきますを押すとコールバックを1回呼び画面に留まる', (tester) async {
    var invocationCount = 0;
    await _pumpFarewell(
      tester,
      size: const Size(402, 755),
      onFarewell: () => invocationCount++,
    );

    await tester.tap(find.byKey(const ValueKey('farewell-action-button')));
    await tester.pump();

    expect(invocationCount, 1);
    expect(find.byKey(const ValueKey('farewell-screen')), findsOneWidget);
  });

  testWidgets('ボタンをクリックカーソルで表示する', (tester) async {
    await _pumpFarewell(tester, size: const Size(402, 755));

    final action = tester.widget<InkWell>(
      find.byKey(const ValueKey('farewell-action-button')),
    );

    expect(action.mouseCursor, SystemMouseCursors.click);
    expect(action.onTap, isNotNull);
  });

  testWidgets('文字倍率を上げても文字を縮小せず主要領域を保つ', (tester) async {
    final messageText = find.text('この子をお見送りしますよ');
    final actionLabel = find.text('いただきます');
    await _pumpFarewell(tester, size: const Size(320, 568));

    final normalMessageHeight = tester.getRect(messageText).height;
    final normalActionLabelHeight = tester.getRect(actionLabel).height;

    await _pumpFarewell(
      tester,
      size: const Size(320, 568),
      textScaler: const TextScaler.linear(3),
    );

    final scaledMessageHeight = tester.getRect(messageText).height;
    final scaledActionLabelHeight = tester.getRect(actionLabel).height;
    final message = tester.getRect(
      find.byKey(const ValueKey('farewell-message-area')),
    );
    final pet = tester.getRect(
      find.byKey(const ValueKey('farewell-pet-stage')),
    );
    final action = tester.getRect(
      find.byKey(const ValueKey('farewell-action-button')),
    );

    expect(scaledMessageHeight, greaterThan(normalMessageHeight * 2));
    expect(scaledActionLabelHeight, greaterThan(normalActionLabelHeight * 2));
    expect(
      tester.renderObject<RenderParagraph>(messageText).didExceedMaxLines,
      isFalse,
    );
    expect(
      tester.renderObject<RenderParagraph>(actionLabel).didExceedMaxLines,
      isFalse,
    );
    expect(message.bottom, lessThanOrEqualTo(pet.top));
    expect(pet.bottom, lessThanOrEqualTo(action.top));
    expect(action.bottom, lessThanOrEqualTo(568));
    expect(tester.takeException(), isNull);
  });

  testWidgets('画像とボタンの読み上げ情報を明示する', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpFarewell(tester, size: const Size(402, 755));

      final background = tester.widget<Image>(
        find.byKey(const ValueKey('farewell-background')),
      );
      final pet = tester.widget<Image>(
        find.byKey(const ValueKey('farewell-pet')),
      );

      expect(background.excludeFromSemantics, isTrue);
      expect(pet.semanticLabel, 'かつお菜のキャラクター');
      expect(
        tester.getSemantics(
          find.byKey(const ValueKey('farewell-action-semantics')),
        ),
        matchesSemantics(label: 'いただきます', isButton: true, hasTapAction: true),
      );
    } finally {
      semantics.dispose();
    }
  });
}

Future<void> _pumpFarewell(
  WidgetTester tester, {
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
  TextScaler textScaler = TextScaler.noScaling,
  VoidCallback? onFarewell,
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
        data: MediaQueryData(
          size: size,
          padding: padding,
          textScaler: textScaler,
        ),
        child: FarewellScreen(onFarewell: onFarewell ?? () {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
