import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/conversation/presentation/conversation_screen.dart';
import '../features/diary/presentation/diary_screen.dart';
import '../features/gacha/presentation/gacha_screen.dart';
import '../features/health/presentation/health_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/summon/presentation/summon_screen.dart';
import '../features/zukan/presentation/zukan_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/', pageBuilder: _slidePage(const HealthScreen())),
      GoRoute(
        path: '/home',
        pageBuilder: _slidePage(const HomeScreen()),
      ),
      GoRoute(
        path: '/conversation',
        pageBuilder: _slidePage(const ConversationScreen()),
      ),
      GoRoute(
        path: '/diary',
        pageBuilder: _slidePage(const DiaryScreen()),
      ),
      GoRoute(
        path: '/gacha',
        pageBuilder: _slidePage(const GachaScreen()),
      ),
      GoRoute(
        path: '/summon',
        pageBuilder: _slidePage(const SummonScreen()),
      ),
      GoRoute(
        path: '/zukan',
        pageBuilder: _slidePage(const ZukanScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// 画面遷移を右から左へのスライドで統一するための[Page]ビルダー。
Page<void> Function(BuildContext, GoRouterState) _slidePage(Widget child) {
  return (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
