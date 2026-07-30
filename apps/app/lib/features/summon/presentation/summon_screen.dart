import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'summon_layout.dart';
import 'summon_view_model.dart';

class SummonScreen extends ConsumerWidget {
  const SummonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(summonViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('asset/background/home.png', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = SummonLayoutMetrics.fromConstraints(
                  constraints,
                );
                return Center(
                  child: SizedBox(
                    width: metrics.contentWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          key: const ValueKey('summon-heading-area'),
                          height: metrics.headingAreaHeight,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: metrics.scaled(24),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '新たな命が\n生まれました',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: SummonLayout.text,
                                    fontSize: metrics.scaled(27),
                                    height: 1.45,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: _SummonStage(metrics: metrics)),
                        _NamingPanel(
                          metrics: metrics,
                          name: state.name,
                          canWelcome: state.canWelcome,
                          onNameChanged: ref
                              .read(summonViewModelProvider.notifier)
                              .updateName,
                          onWelcome: () => context.go('/home'),
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

class _SummonStage extends StatelessWidget {
  const _SummonStage({required this.metrics});

  final SummonLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('summon-stage'),
      builder: (context, constraints) {
        final stageWidth = math.min(
          metrics.scaled(SummonLayout.stageMaxWidth),
          constraints.maxWidth,
        );
        final petSize = math.min(
          stageWidth * SummonLayout.petWidthFactor,
          constraints.maxHeight * SummonLayout.petHeightFactor,
        );
        final circleWidth = math.min(
          stageWidth * SummonLayout.circleWidthFactor,
          petSize * SummonLayout.circleToPetFactor,
        );

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: -circleWidth * SummonLayout.circleBottomCropFactor,
              child: Image.asset(
                'asset/others/magic-circle.png',
                key: const ValueKey('summon-magic-circle'),
                width: circleWidth,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Image.asset(
                'asset/pets/katsuonapet.png',
                key: const ValueKey('summon-pet'),
                width: petSize,
                height: petSize,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NamingPanel extends StatelessWidget {
  const _NamingPanel({
    required this.metrics,
    required this.name,
    required this.canWelcome,
    required this.onNameChanged,
    required this.onWelcome,
  });

  final SummonLayoutMetrics metrics;
  final String name;
  final bool canWelcome;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onWelcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('summon-naming-panel'),
      width: metrics.panelWidth,
      height: metrics.panelHeight,
      padding: EdgeInsets.fromLTRB(
        metrics.scaled(22),
        metrics.scaled(17),
        metrics.scaled(22),
        metrics.scaled(20),
      ),
      decoration: BoxDecoration(
        color: SummonLayout.panel,
        borderRadius: BorderRadius.circular(metrics.scaled(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: metrics.scaled(10),
            offset: Offset(0, metrics.scaled(3)),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: metrics.scaled(35),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '名前をつけよう',
                style: TextStyle(
                  color: SummonLayout.text,
                  fontSize: metrics.scaled(22),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: metrics.scaled(10)),
          SizedBox(
            height: metrics.interactive(SummonLayout.fieldHeight),
            child: TextFormField(
              key: const ValueKey('summon-name-field'),
              initialValue: name,
              onChanged: onNameChanged,
              textInputAction: TextInputAction.done,
              maxLength: SummonLayout.nameMaxLength,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => null,
              style: TextStyle(
                color: SummonLayout.text,
                fontSize: metrics.scaled(19),
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: SummonLayout.field,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: metrics.scaled(15),
                ),
                suffixIcon: const Icon(
                  Icons.edit_rounded,
                  color: SummonLayout.editIcon,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(
                    color: SummonLayout.button,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: metrics.scaled(12)),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('summon-welcome-button'),
                onPressed: canWelcome ? onWelcome : null,
                style: FilledButton.styleFrom(
                  backgroundColor: SummonLayout.button,
                  disabledBackgroundColor: SummonLayout.disabledButton,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(metrics.scaled(16)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: metrics.scaled(12)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ようこそ ${name.trim()}',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: metrics.scaled(22),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
