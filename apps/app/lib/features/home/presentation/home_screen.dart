import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_bottom_navigation.dart';
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
                        AppBottomNavigation(
                          key: const ValueKey('home-bottom-navigation'),
                          activeTab: AppTab.home,
                          width: metrics.designWidth,
                        ),
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
              scale: metrics.menuScale,
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
