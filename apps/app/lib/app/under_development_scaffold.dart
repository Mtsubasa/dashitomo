import 'package:flutter/material.dart';

import 'app_bottom_navigation.dart';
import 'app_bottom_navigation_layout.dart';

class UnderDevelopmentScaffold extends StatelessWidget {
  const UnderDevelopmentScaffold({super.key, required this.activeTab});

  final AppTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('asset/background/home.png', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth.clamp(0, 480).toDouble();
                return Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      children: [
                        const Expanded(
                          child: Center(
                            child: Text(
                              '現在開発中です',
                              key: ValueKey('under-development-message'),
                              style: TextStyle(
                                color: Color(0xFF4E7A2F),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AppBottomNavigation(
                          key: const ValueKey('app-bottom-navigation'),
                          activeTab: activeTab,
                          width: width,
                        ),
                        const SizedBox(
                          height: AppBottomNavigationLayout.bottomGap,
                        ),
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
