import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'camera_layout.dart';

/// 実カメラ接続前の撮影画面モック。
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('camera-screen'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'asset/background/camera-mock.png',
            key: const ValueKey('camera-preview-mock'),
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = CameraLayoutMetrics.fromSize(
                  constraints.biggest,
                );
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: metrics.overlayWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: metrics.scaled(CameraLayout.closeLeftGap),
                          top: metrics.scaled(CameraLayout.closeTopGap),
                          child: _CloseButton(metrics: metrics),
                        ),
                        Positioned(
                          left:
                              metrics.overlayWidth * CameraLayout.petLeftFactor,
                          bottom: metrics.scaled(CameraLayout.petBottomGap),
                          child: Image.asset(
                            'asset/pets/katsuonapet.png',
                            key: const ValueKey('camera-pet'),
                            width: metrics.petWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: metrics.scaled(CameraLayout.shutterBottomGap),
                          child: Center(
                            child: _ShutterControl(
                              size: metrics.shutterSize,
                              scale: metrics.scale,
                            ),
                          ),
                        ),
                        Positioned(
                          right: metrics.scaled(CameraLayout.switchRightGap),
                          bottom: metrics.scaled(CameraLayout.switchBottomGap),
                          child: _SwitchControl(metrics: metrics),
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

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.metrics});

  final CameraLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: const ValueKey('camera-close-button'),
      dimension: metrics.closeButtonSize,
      child: Material(
        color: CameraLayout.closeButtonColor,
        shape: const CircleBorder(),
        elevation: 2,
        child: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          icon: Icon(
            Icons.close,
            color: CameraLayout.iconColor,
            size: metrics.scaled(CameraLayout.closeIconSize),
          ),
          tooltip: '閉じる',
        ),
      ),
    );
  }
}

/// モック段階では撮影処理を持たない。
class _ShutterControl extends StatelessWidget {
  const _ShutterControl({required this.size, required this.scale});

  final double size;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('camera-shutter-control'),
        width: size,
        height: size,
        padding: EdgeInsets.all(CameraLayout.shutterInnerGap * scale),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: CameraLayout.controlColor,
            width: CameraLayout.shutterOuterBorderWidth * scale,
          ),
          color: Colors.black.withValues(alpha: 0.12),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CameraLayout.shutterColor,
            border: Border.all(
              color: CameraLayout.controlColor,
              width: CameraLayout.shutterInnerBorderWidth * scale,
            ),
          ),
        ),
      ),
    );
  }
}

/// モック段階ではカメラ切替処理を持たない。
class _SwitchControl extends StatelessWidget {
  const _SwitchControl({required this.metrics});

  final CameraLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('camera-switch-control'),
        width: metrics.switchButtonSize,
        height: metrics.switchButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CameraLayout.controlColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.cameraswitch,
          color: CameraLayout.iconColor,
          size: metrics.scaled(CameraLayout.switchIconSize),
        ),
      ),
    );
  }
}
