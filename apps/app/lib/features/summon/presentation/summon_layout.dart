import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 召喚画面の基準寸法と色。
abstract final class SummonLayout {
  static const referenceWidth = 402.0;
  static const referenceHeight = 755.0;
  static const contentMaxWidth = 480.0;
  static const minimumWidthScale = 0.78;
  static const maximumScale = 1.10;
  static const minimumInteractiveExtent = 48.0;

  static const headingAreaHeight = 160.0;
  static const stageMaxWidth = 370.0;
  static const petWidthFactor = 0.88;
  static const petHeightFactor = 1.08;
  static const circleWidthFactor = 0.92;
  static const circleToPetFactor = 1.18;
  static const circleBottomCropFactor = 0.23;

  static const panelWidth = 330.0;
  static const panelHeight = 220.0;
  static const minimumPanelHeight = 190.0;
  static const fieldHeight = 48.0;
  static const bottomGap = 28.0;
  static const nameMaxLength = 12;

  static const text = Color(0xFF76502D);
  static const panel = Color(0xFFFFE8C2);
  static const field = Color(0xFFFFF8E9);
  static const editIcon = Color(0xFFD8DEE8);
  static const button = Color(0xFF60913B);
  static const disabledButton = Color(0xFFAEBB9E);
}

class SummonLayoutMetrics {
  const SummonLayoutMetrics._({
    required this.contentWidth,
    required this.scale,
    required this.heightScale,
  });

  factory SummonLayoutMetrics.fromConstraints(BoxConstraints constraints) {
    final usableWidth = math.min(
      constraints.maxWidth,
      SummonLayout.contentMaxWidth,
    );
    final widthScale = (usableWidth / SummonLayout.referenceWidth).clamp(
      SummonLayout.minimumWidthScale,
      SummonLayout.maximumScale,
    );
    final heightScale = (constraints.maxHeight / SummonLayout.referenceHeight)
        .clamp(0.72, SummonLayout.maximumScale);
    return SummonLayoutMetrics._(
      contentWidth: SummonLayout.referenceWidth * widthScale,
      scale: math.min(widthScale, heightScale),
      heightScale: heightScale,
    );
  }

  final double contentWidth;
  final double scale;
  final double heightScale;

  double get headingAreaHeight => SummonLayout.headingAreaHeight * heightScale;

  double get panelWidth =>
      math.min(SummonLayout.panelWidth * scale, contentWidth - scaled(24));

  double get panelHeight => math.max(
    SummonLayout.panelHeight * heightScale,
    SummonLayout.minimumPanelHeight,
  );

  double get bottomGap =>
      math.min(SummonLayout.bottomGap * heightScale, SummonLayout.bottomGap);

  double scaled(double value) => value * scale;

  double interactive(double value) =>
      math.max(scaled(value), SummonLayout.minimumInteractiveExtent);
}
