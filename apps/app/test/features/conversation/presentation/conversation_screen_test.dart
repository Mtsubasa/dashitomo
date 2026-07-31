import 'package:dashitomo/features/conversation/presentation/conversation_screen.dart';
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
    testWidgets('主要領域が重ならず表示される: ${size.width}x${size.height}', (tester) async {
      await _pumpConversation(tester, size: size);

      expect(tester.takeException(), isNull);

      final header = tester.getRect(
        find.byKey(const ValueKey('conversation-header')),
      );
      final content = tester.getRect(
        find.byKey(const ValueKey('conversation-content')),
      );
      final composer = tester.getRect(
        find.byKey(const ValueKey('conversation-composer')),
      );
      final bottom = tester.getRect(
        find.byKey(const ValueKey('conversation-bottom-navigation')),
      );
      final sendButton = tester.getRect(
        find.byKey(const ValueKey('conversation-send-button')),
      );

      expect(header.bottom, lessThanOrEqualTo(content.top));
      expect(content.bottom, lessThanOrEqualTo(composer.top));
      expect(composer.bottom, lessThanOrEqualTo(bottom.top));
      expect(bottom.bottom, lessThanOrEqualTo(size.height));
      expect(sendButton.width, greaterThanOrEqualTo(48));
      expect(sendButton.height, greaterThanOrEqualTo(48));
    });
  }

  testWidgets('Safe Area内に入力欄とナビゲーションを配置する', (tester) async {
    const size = Size(390, 844);
    const padding = EdgeInsets.fromLTRB(0, 44, 0, 34);
    await _pumpConversation(tester, size: size, padding: padding);

    final header = tester.getRect(
      find.byKey(const ValueKey('conversation-header')),
    );
    final bottom = tester.getRect(
      find.byKey(const ValueKey('conversation-bottom-navigation')),
    );

    expect(header.top, greaterThanOrEqualTo(padding.top));
    expect(bottom.bottom, lessThanOrEqualTo(size.height - padding.bottom));
  });

  testWidgets('送信した発言とキャラクターの返答を会話履歴へ追加する', (tester) async {
    await _pumpConversation(tester, size: const Size(402, 755));

    final field = find.byKey(const ValueKey('conversation-message-field'));
    expect(
      find.byKey(const ValueKey('conversation-character-message')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('conversation-user-message')),
      findsNothing,
    );

    await tester.enterText(field, 'きょうはうどんを食べたよ');
    await tester.tap(find.byTooltip('送信'));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('conversation-character-message')),
      findsNWidgets(2),
    );
    expect(
      find.byKey(const ValueKey('conversation-user-message')),
      findsOneWidget,
    );
    expect(find.text('きょうはうどんを食べたよ'), findsOneWidget);
    expect(find.text('「きょうはうどんを食べたよ」って聞けて、うれしか〜！'), findsOneWidget);
    expect(tester.widget<TextField>(field).controller?.text, isEmpty);
  });

  testWidgets('空のメッセージは送信しない', (tester) async {
    await _pumpConversation(tester, size: const Size(402, 755));

    await tester.enterText(
      find.byKey(const ValueKey('conversation-message-field')),
      '   ',
    );
    await tester.tap(find.byTooltip('送信'));
    await tester.pump();

    expect(find.text('今日は何を食べたと？'), findsOneWidget);
  });
}

Future<void> _pumpConversation(
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
          child: const ConversationScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
