import 'dart:math' as math;

import 'package:flutter/material.dart';

/// お別れ画面の基準寸法と表示寸法を定義する。
abstract final class FarewellLayout {
  static const referenceWidth = 402.0;
  static const contentMaxWidth = 480.0;
  static const minimumScale = 0.78;
  static const maximumScale = 1.10;

  static const topAreaHeight = 188.0;
  static const bottomAreaHeight = 128.0;

  static const message = 'この子をお見送りしますよ';
  static const messageFontSize = 18.0;
  static const messageHorizontalGap = 28.0;
  static const messageVerticalGap = 18.0;
  static const messageColor = Color(0xFF4F2F17);

  static const petWidthFactor = 0.86;
  static const petMaxWidth = 350.0;
  static const petMaxHeightFactor = 0.94;

  static const actionLabel = 'いただきます';
  static const actionWidth = 264.0;
  static const actionHeight = 58.0;
  static const actionTopGap = 12.0;
  static const actionBottomGap = 12.0;
  static const actionHorizontalPadding = 24.0;
  static const actionVerticalPadding = 10.0;
  static const actionRadius = 32.0;
  static const actionBorderWidth = 2.0;
  static const actionFontSize = 23.0;
  static const actionShadowBlur = 5.0;
  static const actionShadowOffset = Offset(0, 3);
  static const actionBorderColor = Colors.white;
  static const actionTextColor = Colors.white;
  static const actionTopColor = Color(0xFFFFC928);
  static const actionBottomColor = Color(0xFFF4A600);
  static const actionShadowColor = Color(0x66000000);
}

/// 利用可能領域からお別れ画面の各表示寸法を算出する。
class FarewellLayoutMetrics {
  const FarewellLayoutMetrics._({
    required this.availableSize,
    required this.contentWidth,
    required this.scale,
  });

  factory FarewellLayoutMetrics.fromSize(Size availableSize) {
    final contentWidth = math.min(
      availableSize.width,
      FarewellLayout.contentMaxWidth,
    );
    final scale = (contentWidth / FarewellLayout.referenceWidth).clamp(
      FarewellLayout.minimumScale,
      FarewellLayout.maximumScale,
    );
    return FarewellLayoutMetrics._(
      availableSize: availableSize,
      contentWidth: contentWidth,
      scale: scale,
    );
  }

  final Size availableSize;
  final double contentWidth;
  final double scale;

  double get topAreaHeight => math.min(
    scaled(FarewellLayout.topAreaHeight),
    availableSize.height * 0.29,
  );

  double get bottomAreaHeight => scaled(FarewellLayout.bottomAreaHeight);

  double get petWidth => math.min(
    contentWidth * FarewellLayout.petWidthFactor,
    scaled(FarewellLayout.petMaxWidth),
  );

  double petHeight(double contentHeight) =>
      math.min(petWidth, contentHeight * FarewellLayout.petMaxHeightFactor);

  double get actionWidth => math.min(
    scaled(FarewellLayout.actionWidth),
    contentWidth - scaled(FarewellLayout.messageHorizontalGap * 2),
  );

  double get actionHeight => math.max(
    48 + FarewellLayout.actionBorderWidth * 2,
    scaled(FarewellLayout.actionHeight),
  );

  double scaled(double value) => value * scale;
}
