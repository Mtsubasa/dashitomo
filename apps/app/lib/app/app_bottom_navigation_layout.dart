import 'package:flutter/material.dart';

/// アプリ共通の下部ナビゲーションに使う基準寸法と色。
abstract final class AppBottomNavigationLayout {
  static const referenceWidth = 402.0;
  static const barHeight = 108.0;
  static const barRadius = 30.0;
  static const bottomGap = 16.0;
  static const iconSize = 54.0;
  static const labelSize = 13.0;
  static const labelWidth = 64.0;
  static const labelHeight = 18.0;
  static const itemOffset = 4.0;
  static const cameraBumpProtrusion = 30.0;
  static const cameraBumpRadius = 52.0;
  static const cameraOrangeSize = 96.0;
  static const cameraIconSize = 62.0;
  static const cameraLensSize = 28.0;
  static const cameraLensYellowWidth = 2.0;
  static const cameraLensWhiteWidth = 3.0;
  static const barColor = Color(0xFFF6E3C3);
  static const labelColor = Color(0xFF553A04);
  static const activeColor = Color(0xFF4E7A2F);
  static const cameraLensYellowColor = Color(0xFFFFC64B);
  static const cameraLensColor = Color(0xFF8BC34A);
}
