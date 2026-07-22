import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';
import 'web_preview_frame.dart';

class DashitomoApp extends ConsumerWidget {
  const DashitomoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'だしトモ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) =>
          WebPreviewFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}
