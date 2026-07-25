import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'home_layout.dart';
import 'home_view_model.dart';

/// 上下の固定UIと、その間で伸縮するペット表示領域を持つホーム画面。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('asset/background/home.png', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = HomeLayoutMetrics.fromSize(constraints.biggest);
                return Center(
                  child: SizedBox(
                    width: metrics.designWidth,
                    child: Column(
                      children: [
                        _TopHud(
                          metrics: metrics,
                          name: state.petName,
                          level: state.level,
                          expRatio: state.expRatio,
                        ),
                        Expanded(child: _PetStage(metrics: metrics)),
                        _ResponsiveBottomNavigation(metrics: metrics),
                        SizedBox(height: metrics.bottomGap),
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

/// 上端へ固定するHUD。メニューとネームプレートを同じ基準幅で拡縮する。
class _TopHud extends StatelessWidget {
  const _TopHud({
    required this.metrics,
    required this.name,
    required this.level,
    required this.expRatio,
  });

  final HomeLayoutMetrics metrics;
  final String name;
  final int level;
  final double expRatio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('home-top-hud'),
      height: metrics.topHudHeight,
      child: Stack(
        children: [
          Positioned(
            top: metrics.scaled(HomeLayout.namePlateTopGap),
            left: (metrics.designWidth - metrics.namePlateWidth) / 2,
            child: _NamePlate(
              width: metrics.namePlateWidth,
              name: name,
              level: level,
              expRatio: expRatio,
            ),
          ),
          Positioned(
            left: metrics.scaled(HomeLayout.menuLeft),
            top: metrics.scaled(HomeLayout.menuTop),
            child: Transform.scale(
              scale: metrics.scale,
              alignment: Alignment.topLeft,
              child: const _MenuButton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top HUDとBottom Navigationの残り領域へペットを収める。
class _PetStage extends StatelessWidget {
  const _PetStage({required this.metrics});

  final HomeLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('home-pet-stage'),
      builder: (context, constraints) {
        final size = math.min(
          metrics.designWidth * HomeLayout.petWidthFactor,
          constraints.maxHeight * 0.96,
        );
        return Align(
          alignment: const Alignment(0, HomeLayout.petAlignmentY),
          child: SizedBox.square(
            dimension: size,
            child: Image.asset(
              'asset/pets/katsuonapet.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home-menu-button'),
      width: HomeLayout.menuButtonSize,
      height: HomeLayout.menuButtonSize,
      decoration: BoxDecoration(
        color: HomeLayout.menuFill,
        borderRadius: BorderRadius.circular(HomeLayout.menuRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.menu,
          color: HomeLayout.line,
          size: HomeLayout.menuIconSize,
        ),
        onPressed: () {},
        tooltip: 'メニュー',
      ),
    );
  }
}

/// プレート画像を親として、表示値を割合座標で重ねる。
class _NamePlate extends StatelessWidget {
  const _NamePlate({
    required this.width,
    required this.name,
    required this.level,
    required this.expRatio,
  });

  final double width;
  final String name;
  final int level;
  final double expRatio;

  @override
  Widget build(BuildContext context) {
    final l = HomeLayout.namePlate;
    final height = width / HomeLayout.namePlateAspectRatio;
    final expRect = l.expBar;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('asset/others/name-plate.png', fit: BoxFit.fill),
          ),
          Align(
            alignment: l.alignmentOf(l.nameCenter),
            child: SizedBox(
              width: width * l.nameMaxWidthFactor,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: height * l.nameHeightFactor,
                    fontWeight: FontWeight.bold,
                    color: HomeLayout.nameColor,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: l.alignmentOf(l.levelCenter),
            child: Text(
              '$level',
              style: TextStyle(
                fontSize: height * l.levelHeightFactor,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: width * expRect.left,
            top: height * expRect.top,
            child: Container(
              width: width * expRect.width * expRatio.clamp(0.0, 1.0),
              height: height * expRect.height,
              decoration: BoxDecoration(
                color: HomeLayout.expFill,
                borderRadius: BorderRadius.circular(
                  height * expRect.height / 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 基準幅で作ったタブ一式を一つのコンポーネントとして比例拡縮する。
class _ResponsiveBottomNavigation extends StatelessWidget {
  const _ResponsiveBottomNavigation({required this.metrics});

  final HomeLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('home-bottom-navigation'),
      width: metrics.designWidth,
      height: metrics.bottomNavigationHeight,
      child: const FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: HomeLayout.referenceWidth,
          height: HomeLayout.tabBarHeight + HomeLayout.cameraBumpProtrusion,
          child: _BottomTabBar(),
        ),
      ),
    );
  }
}

/// タブ本体と中央カメラの背景を一体の形状として描画する。
class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar();

  @override
  Widget build(BuildContext context) {
    const inset = HomeLayout.cameraBumpProtrusion;
    const totalHeight = HomeLayout.tabBarHeight + inset;
    // 円の上端をWidgetの上端へ揃える。
    const cameraCenterY = HomeLayout.cameraBumpRadius;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 8,
            right: 8,
            top: 0,
            bottom: 0,
            child: PhysicalShape(
              clipper: _TabBarClipper(
                radius: HomeLayout.tabBarRadius,
                topInset: inset,
                bumpRadius: HomeLayout.cameraBumpRadius,
                bumpCenterY: cameraCenterY,
              ),
              color: HomeLayout.tabBarColor,
              elevation: 6,
              shadowColor: Color(0x40000000),
              child: Padding(
                padding: EdgeInsets.only(top: inset),
                child: Row(
                  children: [
                    _TabItem(
                      asset: 'asset/tabs/zukan.png',
                      label: '図鑑',
                      itemOffset: HomeLayout.tabOuterItemOffset,
                    ),
                    _TabItem(
                      asset: 'asset/tabs/nikki.png',
                      label: '日記',
                      itemOffset: HomeLayout.tabInnerItemOffset,
                    ),
                    _CameraTabSlot(),
                    _TabItem(
                      asset: 'asset/tabs/kaiwa.png',
                      label: '会話',
                      itemOffset: HomeLayout.tabInnerItemOffset,
                    ),
                    _TabItem(
                      asset: 'asset/tabs/gacha.png',
                      label: 'ガチャ',
                      itemOffset: HomeLayout.tabOuterItemOffset,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: cameraCenterY - HomeLayout.cameraOrangeSize / 2,
            left: 0,
            right: 0,
            child: Center(child: _CameraButton()),
          ),
        ],
      ),
    );
  }
}

/// 直線的なタブバーと、中央上部でカメラを囲う円形の膨らみを
/// 一体化させるクリッパ。
class _TabBarClipper extends CustomClipper<Path> {
  const _TabBarClipper({
    required this.radius,
    required this.topInset,
    required this.bumpRadius,
    required this.bumpCenterY,
  });

  /// 角の丸み。
  final double radius;

  /// バー本体の上端が全体上端から下がる量（膨らみの突き出し分）。
  final double topInset;

  /// カメラを囲う膨らみの半径。
  final double bumpRadius;

  /// 膨らみ（円）の中心 Y。
  final double bumpCenterY;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final t = topInset;
    final bar = Path()
      ..moveTo(0, t + r)
      ..quadraticBezierTo(0, t, r, t)
      ..lineTo(w - r, t)
      ..quadraticBezierTo(w, t, w, t + r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..close();

    final bump = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(w / 2, bumpCenterY), radius: bumpRadius),
      );

    return Path.combine(PathOperation.union, bar, bump);
  }

  @override
  bool shouldReclip(_TabBarClipper oldClipper) {
    return oldClipper.radius != radius ||
        oldClipper.topInset != topInset ||
        oldClipper.bumpRadius != bumpRadius ||
        oldClipper.bumpCenterY != bumpCenterY;
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.asset,
    required this.label,
    required this.itemOffset,
  });

  final String asset;
  final String label;
  final double itemOffset;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Transform.translate(
          offset: Offset(0, itemOffset),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                asset,
                width: HomeLayout.tabIconSize,
                height: HomeLayout.tabIconSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: HomeLayout.tabLabelSize,
                  color: HomeLayout.tabLabelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 中央カメラのラベル枠。ボタン本体は [_BottomTabBar] が上に重ねて描画するため、
/// ここではアイコン分の高さを確保しつつラベルだけを他タブと同じ位置に表示する。
class _CameraTabSlot extends StatelessWidget {
  const _CameraTabSlot();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, HomeLayout.tabCenterItemOffset),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: HomeLayout.tabIconSize),
            SizedBox(height: 2),
            Text(
              HomeLayout.cameraLabel,
              style: TextStyle(
                fontSize: HomeLayout.tabLabelSize,
                color: HomeLayout.tabLabelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 中央のカメラボタン（オレンジ円）。囲うクリーム色のリングはバー側の
/// 膨らみ（[_TabBarClipper]）が担うため、ここではオレンジ円のみ描画する。
class _CameraButton extends StatelessWidget {
  const _CameraButton();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: HomeLayout.cameraLabel,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          width: HomeLayout.cameraOrangeSize,
          height: HomeLayout.cameraOrangeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFC64B), Color(0xFFF6A623)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            key: const ValueKey('home-camera-button'),
            customBorder: const CircleBorder(),
            mouseCursor: SystemMouseCursors.click,
            onTap: () => context.push('/camera'),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: HomeLayout.cameraIconSize,
                ),
                Container(
                  width: HomeLayout.cameraLensSize,
                  height: HomeLayout.cameraLensSize,
                  padding: const EdgeInsets.all(
                    HomeLayout.cameraLensYellowWidth,
                  ),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: HomeLayout.cameraLensYellowColor,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(
                      HomeLayout.cameraLensWhiteWidth,
                    ),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HomeLayout.cameraLensColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
