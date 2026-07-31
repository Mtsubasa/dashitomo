import 'package:dashitomo/app/app_bottom_navigation.dart';
import 'package:dashitomo/app/under_development_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final tab in [AppTab.diary, AppTab.gacha]) {
    testWidgets('${tab.label}画面に開発中表示と下部ナビゲーションがある', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        MaterialApp(home: UnderDevelopmentScaffold(activeTab: tab)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('under-development-message')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('app-bottom-navigation')),
        findsOneWidget,
      );
    });
  }
}
