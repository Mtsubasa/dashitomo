import 'package:dashitomo/features/zukan/presentation/zukan_screen.dart';
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
    testWidgets('主要領域が重ならない: ${size.width}x${size.height}', (tester) async {
      await _pumpZukan(tester, size: size);

      expect(tester.takeException(), isNull);

      final header = tester.getRect(find.byKey(const ValueKey('zukan-header')));
      final panel = tester.getRect(find.byKey(const ValueKey('zukan-panel')));
      final bottom = tester.getRect(
        find.byKey(const ValueKey('app-bottom-navigation')),
      );
      final menu = tester.getRect(
        find.byKey(const ValueKey('zukan-menu-button')),
      );
      final generationTab = tester.getRect(
        find.byKey(const ValueKey('zukan-tab-generation')),
      );

      expect(header.bottom, lessThanOrEqualTo(panel.top));
      expect(panel.bottom, lessThanOrEqualTo(bottom.top));
      expect(bottom.bottom, lessThanOrEqualTo(size.height));
      expect(menu.width, greaterThanOrEqualTo(47.99));
      expect(menu.height, greaterThanOrEqualTo(47.99));
      expect(generationTab.height, greaterThanOrEqualTo(47.99));
    });
  }

  testWidgets('大きい文字倍率でもoverflowしない', (tester) async {
    await _pumpZukan(
      tester,
      size: const Size(320, 568),
      textScaler: const TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('世代・称号・衣装をタブで切り替える', (tester) async {
    await _pumpZukan(tester, size: const Size(402, 755));

    expect(find.text('🌿  見つけた世代：1/9  🌿'), findsOneWidget);
    expect(find.byKey(const ValueKey('zukan-pet-silhouette')), findsWidgets);
    expect(find.byIcon(Icons.star_rounded), findsNothing);

    await tester.tap(find.byKey(const ValueKey('zukan-tab-title')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('🌿  集めた称号：4/8  🌿'), findsOneWidget);
    expect(find.byKey(const ValueKey('zukan-title-silhouette')), findsWidgets);
    expect(
      find.byKey(const ValueKey('zukan-locked-ribbon-text')),
      findsWidgets,
    );
    for (final asset in [
      'bronze-ring.png',
      'silver-ring.png',
      'gold-ring.png',
      'rainbow-ring.png',
    ]) {
      expect(
        find.byKey(ValueKey('zukan-title-ring-asset/others/$asset')),
        findsNWidgets(2),
      );
    }

    final ringSizes =
        [
              'bronze-ring.png',
              'silver-ring.png',
              'gold-ring.png',
              'rainbow-ring.png',
            ]
            .map(
              (asset) => tester
                  .getRect(
                    find
                        .byKey(ValueKey('zukan-title-ring-asset/others/$asset'))
                        .first,
                  )
                  .size,
            )
            .toList();
    for (final size in ringSizes.skip(1)) {
      expect(size.width, closeTo(ringSizes.first.width, 0.01));
      expect(size.height, closeTo(ringSizes.first.height, 0.01));
    }

    final edgeGlyph = tester.getCenter(
      find.byKey(const ValueKey('zukan-curved-ribbon-glyph-はじめての芽吹き-0')),
    );
    final centerGlyph = tester.getCenter(
      find.byKey(const ValueKey('zukan-curved-ribbon-glyph-はじめての芽吹き-4')),
    );
    expect(centerGlyph.dy, lessThan(edgeGlyph.dy));
    final sevenGlyphTitleCenter = tester.getCenter(
      find.byKey(const ValueKey('zukan-curved-ribbon-glyph-おしゃべり上手-3')),
    );
    final eightGlyphTitleCenter = tester.getCenter(
      find.byKey(const ValueKey('zukan-curved-ribbon-glyph-はじめての芽吹き-3')),
    );
    expect(eightGlyphTitleCenter.dy, lessThan(sevenGlyphTitleCenter.dy));

    await tester.tap(find.byKey(const ValueKey('zukan-tab-costume')));
    await tester.pump();

    expect(find.text('🌿  集めた衣装：0/9  🌿'), findsOneWidget);
    expect(find.byKey(const ValueKey('zukan-pet-silhouette')), findsWidgets);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });
}

Future<void> _pumpZukan(
  WidgetTester tester, {
  required Size size,
  EdgeInsets padding = EdgeInsets.zero,
  TextScaler textScaler = TextScaler.noScaling,
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
        child: const ZukanScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
