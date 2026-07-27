import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/app_bottom_navigation.dart';
import '../../../app/app_bottom_navigation_layout.dart';
import 'zukan_layout.dart';

enum ZukanCategory {
  generation('世代'),
  title('称号'),
  costume('衣装');

  const ZukanCategory(this.label);

  final String label;
}

class ZukanScreen extends StatefulWidget {
  const ZukanScreen({super.key});

  @override
  State<ZukanScreen> createState() => _ZukanScreenState();
}

class _ZukanScreenState extends State<ZukanScreen> {
  ZukanCategory _category = ZukanCategory.generation;

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
                final metrics = ZukanLayoutMetrics.fromConstraints(constraints);
                return Center(
                  child: SizedBox(
                    width: metrics.width,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: metrics.scaled(
                          ZukanLayout.horizontalPadding,
                        ),
                      ),
                      child: Column(
                        children: [
                          _Header(metrics: metrics),
                          Expanded(
                            child: _ZukanPanel(
                              category: _category,
                              metrics: metrics,
                              onCategoryChanged: (category) {
                                setState(() => _category = category);
                              },
                            ),
                          ),
                          AppBottomNavigation(
                            key: const ValueKey('app-bottom-navigation'),
                            activeTab: AppTab.zukan,
                            width:
                                metrics.width -
                                metrics.scaled(
                                  ZukanLayout.horizontalPadding * 2,
                                ),
                          ),
                          SizedBox(
                            height: metrics.scaled(
                              AppBottomNavigationLayout.bottomGap,
                            ),
                          ),
                        ],
                      ),
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

class _Header extends StatelessWidget {
  const _Header({required this.metrics});

  final ZukanLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('zukan-header'),
      height: metrics.scaled(ZukanLayout.headerHeight),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: const Color(0xFFF6E3C3),
              borderRadius: BorderRadius.circular(13),
              elevation: 2,
              child: SizedBox.square(
                key: const ValueKey('zukan-menu-button'),
                dimension: metrics.interactive(ZukanLayout.menuSize),
                child: IconButton(
                  onPressed: () {},
                  tooltip: 'メニュー',
                  icon: Icon(
                    Icons.menu,
                    color: ZukanLayout.text,
                    size: metrics.scaled(30),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  metrics.interactive(ZukanLayout.menuSize) + metrics.scaled(8),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '🌱  かつお菜図鑑  🌱',
                maxLines: 1,
                style: TextStyle(
                  color: ZukanLayout.green,
                  fontSize: metrics.scaled(25),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZukanPanel extends StatelessWidget {
  const _ZukanPanel({
    required this.category,
    required this.metrics,
    required this.onCategoryChanged,
  });

  final ZukanCategory category;
  final ZukanLayoutMetrics metrics;
  final ValueChanged<ZukanCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('zukan-panel'),
      decoration: BoxDecoration(
        color: ZukanLayout.panel,
        borderRadius: BorderRadius.circular(
          metrics.scaled(ZukanLayout.panelRadius),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A5127).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(metrics.scaled(7)),
        child: Column(
          children: [
            _CategoryTabs(
              selected: category,
              metrics: metrics,
              onChanged: onCategoryChanged,
            ),
            _CollectionSummary(category: category, metrics: metrics),
            Expanded(child: _CollectionGrid(category: category)),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.selected,
    required this.metrics,
    required this.onChanged,
  });

  final ZukanCategory selected;
  final ZukanLayoutMetrics metrics;
  final ValueChanged<ZukanCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: metrics.tabOuterHeight,
      decoration: BoxDecoration(
        border: Border.all(color: ZukanLayout.line),
        borderRadius: BorderRadius.circular(
          metrics.scaled(ZukanLayout.tabRadius),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (final category in ZukanCategory.values)
            Expanded(
              child: Semantics(
                selected: category == selected,
                button: true,
                child: InkWell(
                  key: ValueKey('zukan-tab-${category.name}'),
                  onTap: () => onChanged(category),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: category == selected
                          ? ZukanLayout.tabGreen
                          : Colors.transparent,
                      border: category == ZukanCategory.generation
                          ? null
                          : const Border(
                              left: BorderSide(color: ZukanLayout.line),
                            ),
                    ),
                    child: Center(
                      child: Text(
                        category.label,
                        style: TextStyle(
                          color: category == selected
                              ? Colors.white
                              : ZukanLayout.text,
                          fontSize: metrics.scaled(15),
                          fontWeight: FontWeight.w800,
                        ),
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

class _CollectionSummary extends StatelessWidget {
  const _CollectionSummary({required this.category, required this.metrics});

  final ZukanCategory category;
  final ZukanLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final text = switch (category) {
      ZukanCategory.generation => '🌿  見つけた世代：1/9  🌿',
      ZukanCategory.title => '🌿  集めた称号：4/8  🌿',
      ZukanCategory.costume => '🌿  集めた衣装：0/9  🌿',
    };
    return SizedBox(
      height: metrics.scaled(38),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.scaled(8)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              key: const ValueKey('zukan-summary'),
              maxLines: 1,
              style: TextStyle(
                color: ZukanLayout.text,
                fontSize: metrics.scaled(13),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionGrid extends StatelessWidget {
  const _CollectionGrid({required this.category});

  final ZukanCategory category;

  @override
  Widget build(BuildContext context) {
    final items = switch (category) {
      ZukanCategory.generation => _generationItems,
      ZukanCategory.title => _titleItems,
      ZukanCategory.costume => _costumeItems,
    };
    return GridView.builder(
      key: ValueKey('zukan-grid-${category.name}'),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: ZukanLayout.gridGap,
        mainAxisSpacing: ZukanLayout.gridGap,
        childAspectRatio: ZukanLayout.cardAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CollectionCard(item: item, category: category);
      },
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.item, required this.category});

  final _CollectionItem item;
  final ZukanCategory category;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ribbonHeight =
            constraints.maxWidth / ZukanLayout.ribbonAspectRatio;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: ZukanLayout.card,
            borderRadius: BorderRadius.circular(ZukanLayout.cardRadius),
            border: Border.all(color: ZukanLayout.line.withValues(alpha: 0.55)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 5, 4, 6),
            child: Column(
              children: [
                SizedBox(
                  height: ribbonHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _MaybeSilhouette(
                        locked: item.locked,
                        child: Image.asset(
                          category == ZukanCategory.title
                              ? 'asset/others/syogo-ribon.png'
                              : 'asset/others/name-ribon.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      _RibbonLabel(
                        category: category,
                        text: item.locked ? '???' : item.ribbon,
                        locked: item.locked,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _ItemImage(item: item, category: category),
                  ),
                ),
                SizedBox(
                  height: 29,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.locked ? '???' : item.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ZukanLayout.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                if (category == ZukanCategory.title)
                  _Stars(count: item.stars, locked: item.locked),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RibbonLabel extends StatelessWidget {
  const _RibbonLabel({
    required this.category,
    required this.text,
    required this.locked,
  });

  final ZukanCategory category;
  final String text;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    if (category == ZukanCategory.title && !locked) {
      return TitleRibbonText(text: text);
    }

    final centerY = category == ZukanCategory.title
        ? ZukanLayout.lockedTitleRibbonTextCenterY
        : ZukanLayout.generationRibbonTextCenterY;
    return Align(
      alignment: Alignment(0, centerY * 2 - 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            key: locked && category == ZukanCategory.title
                ? const ValueKey('zukan-locked-ribbon-text')
                : null,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// 円弧状のリボンに沿うよう、文字ごとの中心位置と接線角度を求める。
class TitleRibbonText extends StatelessWidget {
  const TitleRibbonText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: const ValueKey('zukan-curved-ribbon-text'),
      builder: (context, constraints) {
        final glyphs = text.runes.map(String.fromCharCode).toList();
        if (glyphs.isEmpty) return const SizedBox.shrink();

        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        final fontSize = height * ZukanLayout.ribbonTextFontHeightFactor;
        final maximumSpan = width * ZukanLayout.titleRibbonTextWidthFactor;
        final naturalSpan = fontSize * 0.88 * math.max(1, glyphs.length - 1);
        final span = math.min(maximumSpan, naturalSpan);
        final centerYFactor = ZukanLayout.titleRibbonCenterYFor(glyphs.length);
        final glyphSpanRatio =
            (glyphs.length - 1) /
            (ZukanLayout.titleRibbonReferenceGlyphCount - 1);
        final curveScale = math
            .pow(glyphSpanRatio, ZukanLayout.titleRibbonCurveExponent)
            .toDouble()
            .clamp(
              ZukanLayout.titleRibbonMinimumCurveScale,
              ZukanLayout.titleRibbonMaximumCurveScale,
            );
        final curveDepth =
            height * ZukanLayout.titleRibbonCurveDepthFactor * curveScale;
        final centerY = height * centerYFactor;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < glyphs.length; index++)
              _CurvedRibbonGlyph(
                ribbonText: text,
                glyph: glyphs[index],
                index: index,
                glyphCount: glyphs.length,
                span: span,
                center: Offset(width / 2, centerY),
                curveDepth: curveDepth,
                fontSize: fontSize,
              ),
          ],
        );
      },
    );
  }
}

class _CurvedRibbonGlyph extends StatelessWidget {
  const _CurvedRibbonGlyph({
    required this.glyph,
    required this.ribbonText,
    required this.index,
    required this.glyphCount,
    required this.span,
    required this.center,
    required this.curveDepth,
    required this.fontSize,
  });

  final String glyph;
  final String ribbonText;
  final int index;
  final int glyphCount;
  final double span;
  final Offset center;
  final double curveDepth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final progress = glyphCount == 1 ? 0.0 : index / (glyphCount - 1);
    final normalizedX = progress * 2 - 1;
    final glyphCenter = Offset(
      center.dx + normalizedX * span / 2,
      center.dy + curveDepth * normalizedX * normalizedX,
    );
    final angle = span == 0
        ? 0.0
        : math.atan(4 * curveDepth * normalizedX / span);
    final boxSize = fontSize * 1.35;

    return Positioned(
      key: ValueKey('zukan-curved-ribbon-glyph-$ribbonText-$index'),
      left: glyphCenter.dx - boxSize / 2,
      top: glyphCenter.dy - boxSize / 2,
      width: boxSize,
      height: boxSize,
      child: Transform.rotate(
        angle: angle,
        child: Center(
          child: Text(
            glyph,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.item, required this.category});

  final _CollectionItem item;
  final ZukanCategory category;

  @override
  Widget build(BuildContext context) {
    if (category == ZukanCategory.title) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableDimension = math.min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final dimension =
              availableDimension * ZukanLayout.titleRingSizeFactor;
          return OverflowBox(
            alignment: Alignment.center,
            minWidth: 0,
            minHeight: 0,
            maxWidth: dimension,
            maxHeight: dimension,
            child: SizedBox.square(
              key: ValueKey('zukan-title-ring-${item.asset}'),
              dimension: dimension,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _MaybeSilhouette(
                    locked: item.locked,
                    child: Image.asset(
                      item.asset,
                      key: item.locked
                          ? const ValueKey('zukan-title-silhouette')
                          : null,
                      width: dimension,
                      height: dimension,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (!item.locked)
                    SizedBox.square(
                      dimension: dimension * ZukanLayout.titlePetSizeFactor,
                      child: Image.asset(
                        'asset/pets/katsuonapet.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
    return Image.asset(
      item.asset,
      key: item.locked ? const ValueKey('zukan-pet-silhouette') : null,
      fit: BoxFit.contain,
    );
  }
}

class _MaybeSilhouette extends StatelessWidget {
  const _MaybeSilhouette({required this.locked, required this.child});

  final bool locked;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(ZukanLayout.locked, BlendMode.srcIn),
      child: child,
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.count, required this.locked});

  final int count;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final filledCount = count.clamp(0, 4);
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < 4; index++)
            Icon(
              Icons.star_rounded,
              size: 14,
              color: !locked && index < filledCount
                  ? ZukanLayout.star
                  : ZukanLayout.locked.withValues(alpha: 0.55),
            ),
        ],
      ),
    );
  }
}

class _CollectionItem {
  const _CollectionItem({
    required this.ribbon,
    required this.label,
    required this.asset,
    this.stars = 0,
    this.locked = false,
  });

  final String ribbon;
  final String label;
  final String asset;
  final int stars;
  final bool locked;
}

const _generationItems = [
  _CollectionItem(
    ribbon: '一代目',
    label: '一代目 かつ男',
    asset: 'asset/pets/katsuonapet.png',
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
];

const _titleItems = [
  _CollectionItem(
    ribbon: 'はじめての芽吹き',
    label: 'かつお菜を育てた',
    asset: 'asset/others/bronze-ring.png',
    stars: 1,
  ),
  _CollectionItem(
    ribbon: 'おしゃべり上手',
    label: '会話を50回した',
    asset: 'asset/others/silver-ring.png',
    stars: 2,
  ),
  _CollectionItem(
    ribbon: 'かつお菜マスター',
    label: 'すべての世代を見つけた',
    asset: 'asset/others/gold-ring.png',
    stars: 3,
  ),
  _CollectionItem(
    ribbon: '虹色コレクター',
    label: '特別な思い出を集めた',
    asset: 'asset/others/rainbow-ring.png',
    stars: 4,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/others/bronze-ring.png',
    stars: 0,
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/others/silver-ring.png',
    stars: 0,
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/others/gold-ring.png',
    stars: 0,
    locked: true,
  ),
  _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/others/rainbow-ring.png',
    stars: 0,
    locked: true,
  ),
];

final _costumeItems = List.generate(
  9,
  (index) => const _CollectionItem(
    ribbon: '',
    label: '',
    asset: 'asset/pets/silhouette.png',
    locked: true,
  ),
  growable: false,
);
