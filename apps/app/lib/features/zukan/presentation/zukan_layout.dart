import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 図鑑画面の基準寸法、色、アセット内の重ね位置。
abstract final class ZukanLayout {
  static const referenceWidth = 402.0;
  static const contentMaxWidth = 480.0;
  static const minimumScale = 0.78;
  static const maximumScale = 1.10;
  static const horizontalPadding = 12.0;
  static const headerHeight = 92.0;
  static const menuSize = 48.0;
  static const panelRadius = 22.0;
  static const tabHeight = 42.0;
  static const minimumInteractiveExtent = 48.0;
  static const minimumTabOuterExtent = 50.0;
  static const tabRadius = 20.0;
  static const gridGap = 6.0;
  static const cardAspectRatio = 0.62;
  static const cardRadius = 15.0;
  static const ribbonAspectRatio = 866 / 288;
  static const generationRibbonTextCenterY = 0.30;

  static const titleRibbonEightCharacterCenterY = 0.30;
  static const titleRibbonSevenCharacterCenterY = 0.31;
  static const titleRibbonSixCharacterCenterY = 0.295;
  static const titleRibbonUpwardStepBelowSixGlyphs = 0.005;
  static const titleRibbonMinimumCenterY = 0.24;
  static const titleRibbonReferenceGlyphCount = 8;
  static const titleRibbonCurveExponent = 6.0;
  static const titleRibbonMinimumCurveScale = 0.04;
  static const titleRibbonMaximumCurveScale = 1.25;
  static const lockedTitleRibbonTextCenterY = 0.24;
  static const titleRibbonTextWidthFactor = 0.82;
  static const ribbonTextFontHeightFactor = 0.27;
  static const titleRibbonCurveDepthFactor = 0.09;
  static const titleRingSizeFactor = 1.12;
  static const titlePetSizeFactor = 0.42;

  static const line = Color(0xFFD7B878);
  static const text = Color(0xFF6A5127);
  static const green = Color(0xFF4E7A2F);
  static const tabGreen = Color(0xFF5C913E);
  static const panel = Color(0xEFFFF9E9);
  static const card = Color(0xDFFFFBF0);
  static const locked = Color(0xFFD2C7B0);
  static const star = Color(0xFFFFB51B);

  static double titleRibbonCenterYFor(int glyphCount) {
    if (glyphCount >= titleRibbonReferenceGlyphCount) {
      return titleRibbonEightCharacterCenterY;
    }
    if (glyphCount == titleRibbonReferenceGlyphCount - 1) {
      return titleRibbonSevenCharacterCenterY;
    }
    return (titleRibbonSixCharacterCenterY -
            math.max(6 - glyphCount, 0) * titleRibbonUpwardStepBelowSixGlyphs)
        .clamp(titleRibbonMinimumCenterY, titleRibbonSixCharacterCenterY);
  }
}

class ZukanLayoutMetrics {
  const ZukanLayoutMetrics._({required this.width, required this.scale});

  factory ZukanLayoutMetrics.fromConstraints(BoxConstraints constraints) {
    final width = math.min(constraints.maxWidth, ZukanLayout.contentMaxWidth);
    final scale = (width / ZukanLayout.referenceWidth).clamp(
      ZukanLayout.minimumScale,
      ZukanLayout.maximumScale,
    );
    return ZukanLayoutMetrics._(width: width, scale: scale);
  }

  final double width;
  final double scale;

  double scaled(double value) => value * scale;

  double interactive(double value) =>
      math.max(scaled(value), ZukanLayout.minimumInteractiveExtent);

  double get tabOuterHeight => math.max(
    scaled(ZukanLayout.tabHeight),
    ZukanLayout.minimumTabOuterExtent,
  );
}
