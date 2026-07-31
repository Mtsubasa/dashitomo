import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 会話画面の基準寸法と色を定義する。
abstract final class ConversationLayout {
  static const referenceWidth = 402.0;
  static const contentMaxWidth = 480.0;
  static const minimumScale = 0.78;
  static const maximumScale = 1.10;
  static const minimumInteractiveExtent = 48.0;

  static const horizontalPadding = 12.0;
  static const headerHeight = 74.0;
  static const headerPadding = 22.0;
  static const headerVerticalPadding = 8.0;
  static const headerRadius = 24.0;
  static const headerFontSize = 22.0;

  static const historyPadding = 10.0;
  static const historyRadius = 24.0;
  static const messageGap = 8.0;
  static const avatarSize = 48.0;
  static const avatarGap = 7.0;
  static const bubbleWidthFactor = 0.74;
  static const bubbleHorizontalPadding = 16.0;
  static const bubbleVerticalPadding = 10.0;
  static const bubbleRadius = 18.0;
  static const bubbleFontSize = 15.0;

  static const composerHeight = 68.0;
  static const composerPadding = 8.0;
  static const composerRadius = 22.0;
  static const composerGap = 8.0;
  static const composerBottomGap = 8.0;
  static const inputHorizontalPadding = 14.0;
  static const inputVerticalPadding = 10.0;
  static const inputRadius = 17.0;
  static const sendButtonSize = 48.0;
  static const sendIconSize = 24.0;

  static const green = Color(0xFF4E7A2F);
  static const text = Color(0xFF553A04);
  static const hintText = Color(0xFF9A8761);
  static const line = Color(0xFFD7B878);
  static const headerFill = Color(0xF7FFF8E8);
  static const historyFill = Color(0xCFFFF9E9);
  static const bubbleFill = Color(0xF7FFFDF5);
  static const userBubbleFill = Color(0xFFF6D88A);
  static const composerFill = Color(0xEFFFF4D9);
  static const inputFill = Color(0xFFFFFDF8);
  static const sendFill = Color(0xFFF4A600);
  static const shadow = Color(0x2A6A5127);
}

class ConversationLayoutMetrics {
  const ConversationLayoutMetrics._({
    required this.contentWidth,
    required this.scale,
  });

  factory ConversationLayoutMetrics.fromConstraints(
    BoxConstraints constraints,
  ) {
    final contentWidth = math.min(
      constraints.maxWidth,
      ConversationLayout.contentMaxWidth,
    );
    final scale = (contentWidth / ConversationLayout.referenceWidth).clamp(
      ConversationLayout.minimumScale,
      ConversationLayout.maximumScale,
    );
    return ConversationLayoutMetrics._(
      contentWidth: contentWidth,
      scale: scale,
    );
  }

  final double contentWidth;
  final double scale;

  double scaled(double value) => value * scale;

  double interactive(double value) =>
      math.max(scaled(value), ConversationLayout.minimumInteractiveExtent);

  double get innerWidth =>
      contentWidth - scaled(ConversationLayout.horizontalPadding * 2);

  double get headerHeight => scaled(ConversationLayout.headerHeight);

  double get bubbleWidth => innerWidth * ConversationLayout.bubbleWidthFactor;

  double get composerHeight =>
      math.max(scaled(ConversationLayout.composerHeight), 64);
}
