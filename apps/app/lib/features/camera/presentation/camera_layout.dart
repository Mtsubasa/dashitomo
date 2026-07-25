import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 撮影画面モックの基準寸法と重ね要素の配置を定義する。
abstract final class CameraLayout {
  static const referenceWidth = 402.0;
  static const overlayMaxWidth = 480.0;
  static const minimumScale = 0.78;
  static const maximumScale = 1.10;

  static const closeButtonSize = 48.0;
  static const closeIconSize = 30.0;
  static const closeLeftGap = 12.0;
  static const closeTopGap = 12.0;

  static const shutterSize = 88.0;
  static const shutterOuterBorderWidth = 4.0;
  static const shutterInnerGap = 5.0;
  static const shutterInnerBorderWidth = 3.0;
  static const shutterBottomGap = 12.0;

  static const switchButtonSize = 48.0;
  static const switchIconSize = 27.0;
  static const switchRightGap = 18.0;
  static const switchBottomGap = 31.0;

  static const petWidthFactor = 0.36;
  static const petMaxHeightFactor = 0.31;
  static const petLeftFactor = 0.015;
  static const petBottomGap = 42.0;

  static const closeButtonColor = Color(0xFFF8EFD9);
  static const controlColor = Colors.white;
  static const shutterColor = Color(0xFFFFB20C);
  static const iconColor = Color(0xFF4D4D4D);
}

/// 利用可能領域から撮影画面モックの表示寸法を算出する。
class CameraLayoutMetrics {
  const CameraLayoutMetrics._({
    required this.availableSize,
    required this.overlayWidth,
    required this.scale,
  });

  factory CameraLayoutMetrics.fromSize(Size availableSize) {
    final overlayWidth = math.min(
      availableSize.width,
      CameraLayout.overlayMaxWidth,
    );
    final scale = (overlayWidth / CameraLayout.referenceWidth).clamp(
      CameraLayout.minimumScale,
      CameraLayout.maximumScale,
    );
    return CameraLayoutMetrics._(
      availableSize: availableSize,
      overlayWidth: overlayWidth,
      scale: scale,
    );
  }

  final Size availableSize;
  final double overlayWidth;
  final double scale;

  double get closeButtonSize =>
      math.max(CameraLayout.closeButtonSize, scaled(44));

  double get shutterSize => scaled(CameraLayout.shutterSize);

  double get switchButtonSize =>
      math.max(CameraLayout.switchButtonSize, scaled(44));

  double get petWidth => math.min(
    overlayWidth * CameraLayout.petWidthFactor,
    availableSize.height * CameraLayout.petMaxHeightFactor,
  );

  double scaled(double value) => value * scale;
}
