import 'package:flutter/material.dart';
import '../../../core/theme/premium_theme.dart';

/// Zodiac sign data
class ZodiacData {
  final String id;
  final String name;
  final String symbol;
  final String dateRange;
  final Color color;

  const ZodiacData({
    required this.id,
    required this.name,
    required this.symbol,
    required this.dateRange,
    required this.color,
  });
}

/// All zodiac signs
final allZodiacSigns = [
  ZodiacData(
    id: 'koc',
    name: 'Koç',
    symbol: '♈',
    dateRange: '21 Mar - 19 Nis',
    color: const Color(0xFFFF6B6B),
  ),
  ZodiacData(
    id: 'boga',
    name: 'Boğa',
    symbol: '♉',
    dateRange: '20 Nis - 20 May',
    color: const Color(0xFF4ADE80),
  ),
  ZodiacData(
    id: 'ikizler',
    name: 'İkizler',
    symbol: '♊',
    dateRange: '21 May - 20 Haz',
    color: const Color(0xFFFFD700),
  ),
  ZodiacData(
    id: 'yengec',
    name: 'Yengeç',
    symbol: '♋',
    dateRange: '21 Haz - 22 Tem',
    color: const Color(0xFF4A9DFF),
  ),
  ZodiacData(
    id: 'aslan',
    name: 'Aslan',
    symbol: '♌',
    dateRange: '23 Tem - 22 Ağu',
    color: const Color(0xFFFF9F43),
  ),
  ZodiacData(
    id: 'basak',
    name: 'Başak',
    symbol: '♍',
    dateRange: '23 Ağu - 22 Eyl',
    color: const Color(0xFF8B5CF6),
  ),
  ZodiacData(
    id: 'terazi',
    name: 'Terazi',
    symbol: '♎',
    dateRange: '23 Eyl - 22 Eki',
    color: const Color(0xFFFF6B9D),
  ),
  ZodiacData(
    id: 'akrep',
    name: 'Akrep',
    symbol: '♏',
    dateRange: '23 Eki - 21 Kas',
    color: const Color(0xFFDC2626),
  ),
  ZodiacData(
    id: 'yay',
    name: 'Yay',
    symbol: '♐',
    dateRange: '22 Kas - 21 Ara',
    color: const Color(0xFF7C3AED),
  ),
  ZodiacData(
    id: 'oglak',
    name: 'Oğlak',
    symbol: '♑',
    dateRange: '22 Ara - 19 Oca',
    color: const Color(0xFF059669),
  ),
  ZodiacData(
    id: 'kova',
    name: 'Kova',
    symbol: '♒',
    dateRange: '20 Oca - 18 Şub',
    color: const Color(0xFF5EEAD4),
  ),
  ZodiacData(
    id: 'balik',
    name: 'Balık',
    symbol: '♓',
    dateRange: '19 Şub - 20 Mar',
    color: const Color(0xFF3B82F6),
  ),
];

/// Horizontal zodiac selector with glow effect
class HorizontalZodiacSelector extends StatefulWidget {
  final String? selectedId;
  final ValueChanged<ZodiacData> onSelect;
  final bool showLabels;
  final double itemSize;

  const HorizontalZodiacSelector({
    super.key,
    this.selectedId,
    required this.onSelect,
    this.showLabels = true,
    this.itemSize = 64,
  });

  @override
  State<HorizontalZodiacSelector> createState() =>
      _HorizontalZodiacSelectorState();
}

class _HorizontalZodiacSelectorState extends State<HorizontalZodiacSelector> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to selected item after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    if (widget.selectedId == null) return;

    final index =
        allZodiacSigns.indexWhere((z) => z.id == widget.selectedId);
    if (index != -1) {
      final offset = index * (widget.itemSize + PremiumSpacing.md);
      _scrollController.animateTo(
        offset,
        duration: PremiumDurations.normal,
        curve: PremiumCurves.smooth,
      );
    }
  }

  @override
  void didUpdateWidget(HorizontalZodiacSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.showLabels ? widget.itemSize + 28 : widget.itemSize,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: PremiumSpacing.lg),
        itemCount: allZodiacSigns.length,
        itemBuilder: (context, index) {
          final zodiac = allZodiacSigns[index];
          final isSelected = zodiac.id == widget.selectedId;

          return Padding(
            padding: EdgeInsets.only(
              right: index < allZodiacSigns.length - 1
                  ? PremiumSpacing.md
                  : 0,
            ),
            child: _ZodiacItem(
              zodiac: zodiac,
              isSelected: isSelected,
              size: widget.itemSize,
              showLabel: widget.showLabels,
              onTap: () => widget.onSelect(zodiac),
            ),
          );
        },
      ),
    );
  }
}

class _ZodiacItem extends StatelessWidget {
  final ZodiacData zodiac;
  final bool isSelected;
  final double size;
  final bool showLabel;
  final VoidCallback onTap;

  const _ZodiacItem({
    required this.zodiac,
    required this.isSelected,
    required this.size,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: PremiumDurations.normal,
            curve: PremiumCurves.smooth,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected
                  ? zodiac.color.withOpacity(0.2)
                  : PremiumColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? zodiac.color
                    : PremiumColors.borderSubtle,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: zodiac.color.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: PremiumDurations.fast,
                style: TextStyle(
                  fontSize: isSelected ? size * 0.45 : size * 0.38,
                  color: isSelected
                      ? zodiac.color
                      : PremiumColors.textSecondary,
                ),
                child: Text(zodiac.symbol),
              ),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: PremiumSpacing.sm),
            AnimatedDefaultTextStyle(
              duration: PremiumDurations.fast,
              style: TextStyle(
                color: isSelected
                    ? zodiac.color
                    : PremiumColors.textTertiary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(zodiac.name),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact zodiac chip selector (alternative style)
class ZodiacChipSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<ZodiacData> onSelect;

  const ZodiacChipSelector({
    super.key,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: PremiumSpacing.sm,
      runSpacing: PremiumSpacing.sm,
      children: allZodiacSigns.map((zodiac) {
        final isSelected = zodiac.id == selectedId;

        return GestureDetector(
          onTap: () => onSelect(zodiac),
          child: AnimatedContainer(
            duration: PremiumDurations.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: PremiumSpacing.md,
              vertical: PremiumSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? zodiac.color.withOpacity(0.15)
                  : PremiumColors.cardBackground,
              borderRadius: BorderRadius.circular(PremiumRadius.full),
              border: Border.all(
                color: isSelected
                    ? zodiac.color
                    : PremiumColors.borderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  zodiac.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? zodiac.color
                        : PremiumColors.textSecondary,
                  ),
                ),
                const SizedBox(width: PremiumSpacing.xs),
                Text(
                  zodiac.name,
                  style: TextStyle(
                    color: isSelected
                        ? zodiac.color
                        : PremiumColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Large zodiac display card
class ZodiacDisplayCard extends StatelessWidget {
  final ZodiacData zodiac;
  final bool showGlow;

  const ZodiacDisplayCard({
    super.key,
    required this.zodiac,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            zodiac.color.withOpacity(0.15),
            zodiac.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumRadius.xl),
        border: Border.all(
          color: zodiac.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: zodiac.color.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            zodiac.symbol,
            style: TextStyle(
              fontSize: 64,
              color: zodiac.color,
              shadows: [
                Shadow(
                  color: zodiac.color.withOpacity(0.5),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: PremiumSpacing.md),
          Text(
            zodiac.name,
            style: const TextStyle(
              color: PremiumColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: PremiumSpacing.xs),
          Text(
            zodiac.dateRange,
            style: TextStyle(
              color: PremiumColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
