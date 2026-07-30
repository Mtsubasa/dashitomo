import 'package:flutter/material.dart';

import 'farewell_layout.dart';

class FarewellScreen extends StatelessWidget {
  const FarewellScreen({super.key, required this.onFarewell});

  final VoidCallback onFarewell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('farewell-screen'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'asset/background/home.png',
            key: const ValueKey('farewell-background'),
            excludeFromSemantics: true,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = FarewellLayoutMetrics.fromSize(
                  constraints.biggest,
                );
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: metrics.contentWidth,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        _FarewellMessage(metrics: metrics),
                        Expanded(child: _PetStage(metrics: metrics)),
                        _FarewellAction(metrics: metrics, onTap: onFarewell),
                      ],
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

class _FarewellMessage extends StatelessWidget {
  const _FarewellMessage({required this.metrics});

  final FarewellLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('farewell-message-area'),
      constraints: BoxConstraints(minHeight: metrics.topAreaHeight),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.scaled(FarewellLayout.messageHorizontalGap),
            vertical: metrics.scaled(FarewellLayout.messageVerticalGap),
          ),
          child: Center(
            child: Text(
              FarewellLayout.message,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: FarewellLayout.messageColor,
                fontSize: metrics.scaled(FarewellLayout.messageFontSize),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PetStage extends StatelessWidget {
  const _PetStage({required this.metrics});

  final FarewellLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final petSize = metrics.petHeight(constraints.maxHeight);
        return SizedBox.expand(
          key: const ValueKey('farewell-pet-stage'),
          child: Center(
            child: SizedBox.square(
              dimension: petSize,
              child: Image.asset(
                'asset/pets/katsuonapet.png',
                key: const ValueKey('farewell-pet'),
                semanticLabel: 'かつお菜のキャラクター',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FarewellAction extends StatelessWidget {
  const _FarewellAction({required this.metrics, required this.onTap});

  final FarewellLayoutMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: const ValueKey('farewell-action-area'),
      constraints: BoxConstraints(minHeight: metrics.bottomAreaHeight),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(
            top: metrics.scaled(FarewellLayout.actionTopGap),
            bottom: metrics.scaled(FarewellLayout.actionBottomGap),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Semantics(
              key: const ValueKey('farewell-action-semantics'),
              button: true,
              label: FarewellLayout.actionLabel,
              onTap: onTap,
              excludeSemantics: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: metrics.actionWidth,
                  maxWidth: metrics.actionWidth,
                  minHeight: metrics.actionHeight,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    metrics.scaled(FarewellLayout.actionRadius),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        metrics.scaled(FarewellLayout.actionRadius),
                      ),
                      border: Border.all(
                        color: FarewellLayout.actionBorderColor,
                        width: FarewellLayout.actionBorderWidth,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          FarewellLayout.actionTopColor,
                          FarewellLayout.actionBottomColor,
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: FarewellLayout.actionShadowColor,
                          blurRadius: FarewellLayout.actionShadowBlur,
                          offset: FarewellLayout.actionShadowOffset,
                        ),
                      ],
                    ),
                    child: InkWell(
                      key: const ValueKey('farewell-action-button'),
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        metrics.scaled(FarewellLayout.actionRadius),
                      ),
                      onTap: onTap,
                      excludeFromSemantics: true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: metrics.scaled(
                            FarewellLayout.actionHorizontalPadding,
                          ),
                          vertical: metrics.scaled(
                            FarewellLayout.actionVerticalPadding,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            FarewellLayout.actionLabel,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FarewellLayout.actionTextColor,
                              fontSize: metrics.scaled(
                                FarewellLayout.actionFontSize,
                              ),
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(
                                  color: FarewellLayout.actionShadowColor,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
