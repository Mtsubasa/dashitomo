import 'dart:math' as math;

import 'package:flutter/material.dart';

/// アプリ共通の下部ナビゲーションに使う基準寸法と色。
abstract final class AppBottomNavigationLayout {
  static const referenceWidth = 402.0;
  static const barHeight = 108.0;
  static const barRadius = 30.0;
  static const bottomGap = 58.0;
  static const iconSize = 54.0;
  static const paddedIconScale = 1.5;
  static const labelSize = 13.0;
  static const labelWidth = 64.0;
  static const labelHeight = 18.0;
  static const itemOffset = 4.0;
  static const topInset = 30.0;
  static const minimumScale = 0.78;
  static const maximumScale = 1.10;
  static const barColor = Color(0xFFF6E3C3);
  static const labelColor = Color(0xFF553A04);
  static const activeColor = Color(0xFF4E7A2F);

  /// バーと画面下端の間隔。低い画面では利用可能な高さの8%を上限にする。
  static double bottomGapFor({
    required double scale,
    required double availableHeight,
  }) {
    return math.min(bottomGap * scale, availableHeight * 0.08);
  }
}
