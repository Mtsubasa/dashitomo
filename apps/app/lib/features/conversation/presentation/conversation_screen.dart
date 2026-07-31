import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_bottom_navigation.dart';
import '../../../app/app_bottom_navigation_layout.dart';
import 'conversation_layout.dart';
import 'conversation_view_model.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (ref
        .read(conversationViewModelProvider.notifier)
        .send(_controller.text)) {
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationViewModelProvider);

    return Scaffold(
      key: const ValueKey('conversation-screen'),
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'asset/background/home.png',
            key: const ValueKey('conversation-background'),
            excludeFromSemantics: true,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = ConversationLayoutMetrics.fromConstraints(
                  constraints,
                );
                return Center(
                  child: SizedBox(
                    width: metrics.contentWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.scaled(
                          ConversationLayout.horizontalPadding,
                        ),
                      ),
                      child: Column(
                        children: [
                          _Header(metrics: metrics),
                          Expanded(
                            child: _ConversationContent(
                              metrics: metrics,
                              state: state,
                            ),
                          ),
                          _MessageComposer(
                            controller: _controller,
                            metrics: metrics,
                            onSend: _sendMessage,
                          ),
                          SizedBox(
                            height: metrics.scaled(
                              ConversationLayout.composerBottomGap,
                            ),
                          ),
                          AppBottomNavigation(
                            key: const ValueKey(
                              'conversation-bottom-navigation',
                            ),
                            activeTab: AppTab.conversation,
                            width: metrics.innerWidth,
                          ),
                          SizedBox(
                            height: metrics.scaled(
                              AppBottomNavigationLayout.bottomGap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.metrics});

  final ConversationLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('conversation-header'),
      height: metrics.headerHeight,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.scaled(ConversationLayout.headerPadding),
            vertical: metrics.scaled(ConversationLayout.headerVerticalPadding),
          ),
          decoration: BoxDecoration(
            color: ConversationLayout.headerFill,
            borderRadius: BorderRadius.circular(
              metrics.scaled(ConversationLayout.headerRadius),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: const [
              BoxShadow(
                color: ConversationLayout.shadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'かつ男とおはなし',
            maxLines: 1,
            style: TextStyle(
              color: ConversationLayout.green,
              fontSize: metrics.scaled(ConversationLayout.headerFontSize),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationContent extends StatelessWidget {
  const _ConversationContent({required this.metrics, required this.state});

  final ConversationLayoutMetrics metrics;
  final ConversationState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('conversation-content'),
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: metrics.scaled(ConversationLayout.messageGap),
      ),
      padding: EdgeInsets.all(
        metrics.scaled(ConversationLayout.historyPadding),
      ),
      decoration: BoxDecoration(
        color: ConversationLayout.historyFill,
        borderRadius: BorderRadius.circular(
          metrics.scaled(ConversationLayout.historyRadius),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: const [
          BoxShadow(
            color: ConversationLayout.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        key: const ValueKey('conversation-history'),
        reverse: true,
        padding: EdgeInsets.zero,
        itemCount: state.messages.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: metrics.scaled(ConversationLayout.messageGap)),
        itemBuilder: (context, index) {
          final message = state.messages[state.messages.length - index - 1];
          return _MessageBubble(metrics: metrics, message: message);
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.metrics, required this.message});

  final ConversationLayoutMetrics metrics;
  final ConversationMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.author == ConversationAuthor.user;
    final bubble = Container(
      key: ValueKey(
        isUser ? 'conversation-user-message' : 'conversation-character-message',
      ),
      constraints: BoxConstraints(maxWidth: metrics.bubbleWidth),
      padding: EdgeInsets.symmetric(
        horizontal: metrics.scaled(ConversationLayout.bubbleHorizontalPadding),
        vertical: metrics.scaled(ConversationLayout.bubbleVerticalPadding),
      ),
      decoration: BoxDecoration(
        color: isUser
            ? ConversationLayout.userBubbleFill
            : ConversationLayout.bubbleFill,
        borderRadius: BorderRadius.circular(
          metrics.scaled(ConversationLayout.bubbleRadius),
        ),
        border: Border.all(color: ConversationLayout.line),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: ConversationLayout.text,
          fontSize: metrics.scaled(ConversationLayout.bubbleFontSize),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );

    return Semantics(
      label: isUser ? 'あなた: ${message.text}' : 'かつ男: ${message.text}',
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: isUser
            ? bubble
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox.square(
                    dimension: metrics.scaled(ConversationLayout.avatarSize),
                    child: Image.asset(
                      'asset/pets/katsuonapet.png',
                      key: const ValueKey('conversation-pet'),
                      semanticLabel: 'かつお菜のキャラクター、かつ男',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: metrics.scaled(ConversationLayout.avatarGap)),
                  Flexible(child: bubble),
                ],
              ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.metrics,
    required this.onSend,
  });

  final TextEditingController controller;
  final ConversationLayoutMetrics metrics;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('conversation-composer'),
      constraints: BoxConstraints(minHeight: metrics.composerHeight),
      padding: EdgeInsets.all(
        metrics.scaled(ConversationLayout.composerPadding),
      ),
      decoration: BoxDecoration(
        color: ConversationLayout.composerFill,
        borderRadius: BorderRadius.circular(
          metrics.scaled(ConversationLayout.composerRadius),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: const [
          BoxShadow(
            color: ConversationLayout.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('conversation-message-field'),
              controller: controller,
              minLines: 1,
              maxLines: 2,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'かつ男に話しかける',
                hintStyle: const TextStyle(color: ConversationLayout.hintText),
                filled: true,
                fillColor: ConversationLayout.inputFill,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: metrics.scaled(
                    ConversationLayout.inputHorizontalPadding,
                  ),
                  vertical: metrics.scaled(
                    ConversationLayout.inputVerticalPadding,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    metrics.scaled(ConversationLayout.inputRadius),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: metrics.scaled(ConversationLayout.composerGap)),
          SizedBox.square(
            key: const ValueKey('conversation-send-button'),
            dimension: metrics.interactive(ConversationLayout.sendButtonSize),
            child: Material(
              color: ConversationLayout.sendFill,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                onPressed: onSend,
                mouseCursor: SystemMouseCursors.click,
                tooltip: '送信',
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: metrics.scaled(ConversationLayout.sendIconSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
