import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_navigation_layout.dart';

enum AppTab {
  zukan('/zukan', '図鑑'),
  diary('/diary', '日記'),
  home('/home', 'カメラ'),
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
            AppBottomNavigationLayout.cameraBumpProtrusion);
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: AppBottomNavigationLayout.referenceWidth,
          height:
              AppBottomNavigationLayout.barHeight +
              AppBottomNavigationLayout.cameraBumpProtrusion,
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
    const inset = AppBottomNavigationLayout.cameraBumpProtrusion;
    const cameraCenterY = AppBottomNavigationLayout.cameraBumpRadius;

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
              bumpRadius: AppBottomNavigationLayout.cameraBumpRadius,
              bumpCenterY: cameraCenterY,
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
                    asset: 'asset/tabs/nikki.png',
                    isActive: activeTab == AppTab.diary,
                  ),
                  _CameraTabSlot(isActive: activeTab == AppTab.home),
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
        Positioned(
          top: cameraCenterY - AppBottomNavigationLayout.cameraOrangeSize / 2,
          left: 0,
          right: 0,
          child: Center(
            child: _CameraButton(isActive: activeTab == AppTab.home),
          ),
        ),
      ],
    );
  }
}

class _TabBarClipper extends CustomClipper<Path> {
  const _TabBarClipper({
    required this.radius,
    required this.topInset,
    required this.bumpRadius,
    required this.bumpCenterY,
  });

  final double radius;
  final double topInset;
  final double bumpRadius;
  final double bumpCenterY;

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
    final bump = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, bumpCenterY),
          radius: bumpRadius,
        ),
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
    required this.tab,
    required this.asset,
    required this.isActive,
  });

  final AppTab tab;
  final String asset;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: isActive,
        button: true,
        label: tab.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go(tab.path),
          child: Transform.translate(
            offset: const Offset(0, AppBottomNavigationLayout.itemOffset),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  asset,
                  width: AppBottomNavigationLayout.iconSize,
                  height: AppBottomNavigationLayout.iconSize,
                  fit: BoxFit.contain,
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

class _CameraTabSlot extends StatelessWidget {
  const _CameraTabSlot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, AppBottomNavigationLayout.itemOffset),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppBottomNavigationLayout.iconSize),
            const SizedBox(height: 2),
            SizedBox(
              width: AppBottomNavigationLayout.labelWidth,
              height: AppBottomNavigationLayout.labelHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppTab.home.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: AppBottomNavigationLayout.labelSize,
                    color: isActive
                        ? AppBottomNavigationLayout.activeColor
                        : AppBottomNavigationLayout.labelColor,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isActive,
      button: true,
      label: AppTab.home.label,
      child: Tooltip(
        message: AppTab.home.label,
        child: Material(
          type: MaterialType.transparency,
          child: Ink(
            width: AppBottomNavigationLayout.cameraOrangeSize,
            height: AppBottomNavigationLayout.cameraOrangeSize,
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
                    size: AppBottomNavigationLayout.cameraIconSize,
                  ),
                  Container(
                    width: AppBottomNavigationLayout.cameraLensSize,
                    height: AppBottomNavigationLayout.cameraLensSize,
                    padding: const EdgeInsets.all(
                      AppBottomNavigationLayout.cameraLensYellowWidth,
                    ),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppBottomNavigationLayout.cameraLensYellowColor,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(
                        AppBottomNavigationLayout.cameraLensWhiteWidth,
                      ),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppBottomNavigationLayout.cameraLensColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
