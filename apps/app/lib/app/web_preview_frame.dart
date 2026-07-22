import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Web上でモバイル向けUIを基準アスペクト比の端末枠に収める。
///
/// 枠の実サイズを子の`MediaQuery`へ反映し、画面側がブラウザ全体ではなく
/// プレビュー領域の制約を基準にレイアウトできるようにする。
class WebPreviewFrame extends StatelessWidget {
  const WebPreviewFrame({super.key, required this.child});

  final Widget child;

  /// デザイン比較に使う基準viewport。
  static const figmaWidth = 402.0;
  static const figmaHeight = 755.0;

  static const _maxFrameHeight = 900.0;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return ColoredBox(
      color: const Color(0xFF1F2430),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _maxFrameHeight),
          child: AspectRatio(
            aspectRatio: figmaWidth / figmaHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _MediaQuerySizeOverride(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaQuerySizeOverride extends StatelessWidget {
  const _MediaQuerySizeOverride({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: child,
        );
      },
    );
  }
}
