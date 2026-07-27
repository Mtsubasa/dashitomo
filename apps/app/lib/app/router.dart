import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/camera/presentation/camera_screen.dart';
import '../features/conversation/presentation/conversation_screen.dart';
import '../features/diary/presentation/diary_screen.dart';
import '../features/gacha/presentation/gacha_screen.dart';
import '../features/health/presentation/health_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/zukan/presentation/zukan_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HealthScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/conversation',
        builder: (context, state) => const ConversationScreen(),
      ),
      GoRoute(path: '/diary', builder: (context, state) => const DiaryScreen()),
      GoRoute(path: '/gacha', builder: (context, state) => const GachaScreen()),
      GoRoute(path: '/zukan', builder: (context, state) => const ZukanScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
