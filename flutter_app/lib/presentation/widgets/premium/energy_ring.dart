import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/premium_theme.dart';

/// Circular energy ring for displaying scores
///
/// Emotion-first, data-second design
class EnergyRing extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final Color? glowColor;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool animate;
  final Duration animationDuration;

  const EnergyRing({
    super.key,
    required this.value,
    required this.color,
    this.glowColor,
    this.size = 80,
    this.strokeWidth = 6,
    this.child,
    this.animate = true,
    this.animationDuration = PremiumDurations.energyFlow,
  });

  @override
  State<EnergyRing> createState() => _EnergyRingState();
}

class _EnergyRingState extends State<EnergyRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PremiumCurves.energyFlow,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(EnergyRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: PremiumCurves.energyFlow,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _EnergyRingPainter(
              value: widget.animate ? _animation.value : widget.value,
              color: widget.color,
              glowColor: widget.glowColor ?? widget.color.withOpacity(0.3),
              strokeWidth: widget.strokeWidth,
            ),
            child: Center(child: widget.child),
          );
        },
      ),
    );
  }
}

class _EnergyRingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color glowColor;
  final double strokeWidth;

  _EnergyRingPainter({
    required this.value,
    required this.color,
    required this.glowColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = PremiumColors.borderSubtle.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Glow effect
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweepAngle = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Value ring
    final valuePaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: [
          color.withOpacity(0.5),
          color,
        ],
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      valuePaint,
    );

    // End cap glow
    if (value > 0) {
      final endAngle = -math.pi / 2 + sweepAngle;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final dotPaint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(endPoint, strokeWidth / 2 + 2, dotPaint);
      canvas.drawCircle(endPoint, strokeWidth / 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_EnergyRingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

/// Energy score card with ring and label
class EnergyScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final int maxScore;
  final Color color;
  final IconData icon;

  const EnergyScoreCard({
    super.key,
    required this.label,
    required this.score,
    this.maxScore = 10,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(PremiumRadius.lg),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EnergyRing(
            value: score / maxScore,
            color: color,
            size: 72,
            strokeWidth: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 2),
                Text(
                  '$score',
                  style: TextStyle(
                    color: PremiumColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PremiumSpacing.md),
          Text(
            label,
            style: TextStyle(
              color: PremiumColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Multiple energy rings in a row
class EnergyScoresRow extends StatelessWidget {
  final int loveScore;
  final int careerScore;
  final int moneyScore;
  final int healthScore;

  const EnergyScoresRow({
    super.key,
    required this.loveScore,
    required this.careerScore,
    required this.moneyScore,
    required this.healthScore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MiniEnergyRing(
          value: loveScore / 10,
          color: PremiumColors.energyLove,
          icon: Icons.favorite,
          label: 'Aşk',
        ),
        _MiniEnergyRing(
          value: careerScore / 10,
          color: PremiumColors.energyCareer,
          icon: Icons.work_outline,
          label: 'Kariyer',
        ),
        _MiniEnergyRing(
          value: moneyScore / 10,
          color: PremiumColors.energyMoney,
          icon: Icons.attach_money,
          label: 'Para',
        ),
        _MiniEnergyRing(
          value: healthScore / 10,
          color: PremiumColors.energyHealth,
          icon: Icons.favorite_border,
          label: 'Sağlık',
        ),
      ],
    );
  }
}

class _MiniEnergyRing extends StatelessWidget {
  final double value;
  final Color color;
  final IconData icon;
  final String label;

  const _MiniEnergyRing({
    required this.value,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnergyRing(
          value: value,
          color: color,
          size: 56,
          strokeWidth: 4,
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: PremiumSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: PremiumColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
