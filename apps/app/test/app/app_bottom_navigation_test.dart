import 'package:dashitomo/app/app_bottom_navigation.dart';
import 'package:dashitomo/app/app_bottom_navigation_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('タブのアイコンが同じサイズと高さに揃う', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBottomNavigation(
            activeTab: AppTab.home,
            width: AppBottomNavigationLayout.referenceWidth,
          ),
        ),
      ),
    );

    final iconRects = AppTab.values
        .map(
          (tab) => tester.getRect(find.byKey(ValueKey('tab-icon-${tab.name}'))),
        )
        .toList();

    for (final rect in iconRects.skip(1)) {
      expect(rect.width, closeTo(iconRects.first.width, 0.001));
      expect(rect.height, closeTo(iconRects.first.height, 0.001));
      expect(rect.top, closeTo(iconRects.first.top, 0.001));
    }
    expect(
      iconRects.first.width,
      closeTo(AppBottomNavigationLayout.iconSize, 0.001),
    );
    expect(
      iconRects.first.height,
      closeTo(AppBottomNavigationLayout.iconSize, 0.001),
    );
  });

  testWidgets('ホームとカメラに対応するアセットを表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBottomNavigation(
            activeTab: AppTab.home,
            width: AppBottomNavigationLayout.referenceWidth,
          ),
        ),
      ),
    );

    final homeImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('tab-icon-home')),
        matching: find.byType(Image),
      ),
    );
    final cameraImage = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('tab-icon-diary')),
        matching: find.byType(Image),
      ),
    );

    expect((homeImage.image as AssetImage).assetName, 'asset/tabs/home.png');
    expect(
      (cameraImage.image as AssetImage).assetName,
      'asset/tabs/camera.png',
    );
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('カメラ'), findsOneWidget);
  });
}
