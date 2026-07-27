import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_bottom_navigation_layout.dart';

/// ホーム画面の基準寸法と、アセット内の割合座標を定義する。
///
/// 実際の表示寸法は[HomeLayoutMetrics]が親の制約から算出する。
abstract final class HomeLayout {
  // ---- 色 --------------------------------------------------------------
  static const menuFill = Color(0xFFF6E3C3);
  static const line = Color(0xFF553A04);
  static const nameColor = Color(0xFF4E7A2F);
  static const expFill = Color(0xFF8BC34A);

  // ---- 全体 ------------------------------------------------------------
  /// 画像比較と比例計算に使うデザイン基準幅。
  static const referenceWidth = 402.0;

  /// 横画面でも縦長のバランスを保つための前景コンテンツ最大幅。
  static const contentMaxWidth = 480.0;

  static const minimumScale = 0.78;
  static const maximumScale = 1.10;
  static const minimumInteractiveExtent = 48.0;

  // ---- 左上メニューボタン ---------------------------------------------
  static const menuButtonSize = 58.0;
  static const menuRadius = 15.0;
  static const menuIconSize = 34.0;

  /// メニューボタンの位置（コンテンツ左上からのオフセット）。
  static const menuLeft = 20.0;
  static const menuTop = 30.0;

  // ---- ネームプレート（画像 763 x 327 基準）--------------------------
  static const namePlateAspectRatio = 763 / 327;

  /// ネームプレートの最大幅。
  static const namePlateMaxWidth = 310.0;

  /// ネームプレートを上端から下げる余白。
  static const namePlateTopGap = 108.0;

  // ---- ペット ----------------------------------------------------------
  /// 前景コンテンツ幅に対するペット画像の幅。
  static const petWidthFactor = 0.86;

  /// プレートとタブの間での縦位置。負なら上、正なら下へ寄る。
  static const petAlignmentY = 0.14;

  /// ネームプレート内テキストの重ね位置。
  static const namePlate = NamePlateTextLayout(
    // 名前: 中心座標（プレート幅・高に対する割合）。
    nameCenter: Offset(0.50, 0.36),
    nameHeightFactor: 0.24,
    nameMaxWidthFactor: 0.78,
    // レベル値: "Lv." の右に続けて表示する中心座標。
    levelCenter: Offset(0.19, 0.80),
    levelHeightFactor: 0.13,
    // EXP バー: 100% 時の矩形（プレート幅・高に対する割合）。
    expBar: Rect.fromLTWH(0.421, 0.645, 0.512, 0.17),
  );

  /// 画面下端とタブバーの間隔。
  static const tabBarBottomGap = 58.0;
}

/// 親から与えられた領域を、デザイン基準幅に対するscaleへ変換する。
class HomeLayoutMetrics {
  const HomeLayoutMetrics._({required this.availableSize, required this.scale});

  factory HomeLayoutMetrics.fromSize(Size availableSize) {
    final usableWidth = math.min(
      availableSize.width,
      HomeLayout.contentMaxWidth,
    );
    final scale = (usableWidth / HomeLayout.referenceWidth).clamp(
      HomeLayout.minimumScale,
      HomeLayout.maximumScale,
    );
    return HomeLayoutMetrics._(availableSize: availableSize, scale: scale);
  }

  final Size availableSize;
  final double scale;

  double get designWidth => HomeLayout.referenceWidth * scale;

  double get namePlateWidth => HomeLayout.namePlateMaxWidth * scale;

  double get namePlateHeight =>
      namePlateWidth / HomeLayout.namePlateAspectRatio;

  double get topHudHeight =>
      HomeLayout.namePlateTopGap * scale + namePlateHeight;

  double get bottomNavigationHeight =>
      (AppBottomNavigationLayout.barHeight +
          AppBottomNavigationLayout.cameraBumpProtrusion) *
      scale;

  double get bottomGap {
    final scaled = HomeLayout.tabBarBottomGap * scale;
    return math.min(scaled, availableSize.height * 0.08);
  }

  double get menuScale => math.max(
    scale,
    HomeLayout.minimumInteractiveExtent / HomeLayout.menuButtonSize,
  );

  double scaled(double value) => value * scale;
}

/// ネームプレート内テキストの重ね位置定義。
///
/// 中心座標・矩形はすべてプレート幅・高に対する割合（0.0〜1.0）。
class NamePlateTextLayout {
  const NamePlateTextLayout({
    required this.nameCenter,
    required this.nameHeightFactor,
    required this.nameMaxWidthFactor,
    required this.levelCenter,
    required this.levelHeightFactor,
    required this.expBar,
  });

  /// 名前の中心位置。
  final Offset nameCenter;

  /// 名前フォントサイズ（プレート高に対する割合）。
  final double nameHeightFactor;

  /// 名前の最大幅（プレート幅に対する割合）。これを超える入力は自動縮小する。
  final double nameMaxWidthFactor;

  /// レベル値の中心位置。
  final Offset levelCenter;

  /// レベル値フォントサイズ（プレート高に対する割合）。
  final double levelHeightFactor;

  /// EXP バー（100% 時）の矩形。left/top/width/height すべて割合。
  final Rect expBar;

  /// 割合の中心座標を [Alignment]（-1.0〜1.0）へ変換する。
  Alignment alignmentOf(Offset fraction) {
    return Alignment(fraction.dx * 2 - 1, fraction.dy * 2 - 1);
  }
}
