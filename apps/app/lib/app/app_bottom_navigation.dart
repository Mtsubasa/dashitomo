import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_navigation_layout.dart';

enum AppTab {
  zukan('/zukan', '図鑑'),
  diary('/diary', 'カメラ'),
  home('/home', 'ホーム'),
  conversation('/conversation', '会話'),
  gacha('/gacha', 'ガチャ');

  const AppTab(this.path, this.label);

  final String path;
  final String label;
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.activeTab,
    required this.width,
  });

  final AppTab activeTab;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height =
        width /
        AppBottomNavigationLayout.referenceWidth *
        (AppBottomNavigationLayout.barHeight +
            AppBottomNavigationLayout.topInset);
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: AppBottomNavigationLayout.referenceWidth,
          height:
              AppBottomNavigationLayout.barHeight +
              AppBottomNavigationLayout.topInset,
          child: _BottomTabBar(activeTab: activeTab),
        ),
      ),
    );
  }
}

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar({required this.activeTab});

  final AppTab activeTab;

  @override
  Widget build(BuildContext context) {
    const inset = AppBottomNavigationLayout.topInset;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 8,
          right: 8,
          top: 0,
          bottom: 0,
          child: PhysicalShape(
            clipper: const _TabBarClipper(
              radius: AppBottomNavigationLayout.barRadius,
              topInset: inset,
            ),
            color: AppBottomNavigationLayout.barColor,
            elevation: 6,
            shadowColor: const Color(0x40000000),
            child: Padding(
              padding: const EdgeInsets.only(top: inset),
              child: Row(
                children: [
                  _TabItem(
                    tab: AppTab.zukan,
                    asset: 'asset/tabs/zukan.png',
                    isActive: activeTab == AppTab.zukan,
                  ),
                  _TabItem(
                    tab: AppTab.diary,
                    asset: 'asset/tabs/camera.png',
                    assetScale: AppBottomNavigationLayout.paddedIconScale,
                    isActive: activeTab == AppTab.diary,
                  ),
                  _TabItem(
                    tab: AppTab.home,
                    asset: 'asset/tabs/home.png',
                    assetScale: AppBottomNavigationLayout.homeIconScale,
                    isActive: activeTab == AppTab.home,
                  ),
                  _TabItem(
                    tab: AppTab.conversation,
                    asset: 'asset/tabs/kaiwa.png',
                    isActive: activeTab == AppTab.conversation,
                  ),
                  _TabItem(
                    tab: AppTab.gacha,
                    asset: 'asset/tabs/gacha.png',
                    isActive: activeTab == AppTab.gacha,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabBarClipper extends CustomClipper<Path> {
  const _TabBarClipper({required this.radius, required this.topInset});

  final double radius;
  final double topInset;

  @override
  Path getClip(Size size) {
    final bar = Path()
      ..moveTo(0, topInset + radius)
      ..quadraticBezierTo(0, topInset, radius, topInset)
      ..lineTo(size.width - radius, topInset)
      ..quadraticBezierTo(size.width, topInset, size.width, topInset + radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..close();
    return bar;
  }

  @override
  bool shouldReclip(_TabBarClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.topInset != topInset;
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.asset,
    required this.isActive,
    this.assetScale = 1,
  });

  final AppTab tab;
  final String asset;
  final bool isActive;
  final double assetScale;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: isActive,
        button: true,
        label: tab.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // タブ切り替えのたびにブラウザの履歴エントリが積み上がらないようにする。
          onTap: () => Router.neglect(context, () => context.go(tab.path)),
          child: Transform.translate(
            offset: const Offset(0, AppBottomNavigationLayout.itemOffset),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  key: ValueKey('tab-icon-${tab.name}'),
                  width: AppBottomNavigationLayout.iconSize,
                  height: AppBottomNavigationLayout.iconSize,
                  child: ClipRect(
                    child: Transform.scale(
                      scale: assetScale,
                      child: Image.asset(asset, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: AppBottomNavigationLayout.labelWidth,
                  height: AppBottomNavigationLayout.labelHeight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tab.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: AppBottomNavigationLayout.labelSize,
                        color: isActive
                            ? AppBottomNavigationLayout.activeColor
                            : AppBottomNavigationLayout.labelColor,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w600,
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
