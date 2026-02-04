import 'package:flutter/material.dart';
import '../../../../core/theme/premium_theme.dart';

/// Premium fortune reading card on home screen
class FortuneCard extends StatelessWidget {
  final VoidCallback onTap;

  const FortuneCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumColors.primaryPurple.withOpacity(0.2),
              PremiumColors.accentCyan.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: PremiumColors.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.primaryPurple.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Coffee cup icon with glow
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumColors.primaryPurple.withOpacity(0.3),
                    PremiumColors.accentCyan.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(PremiumRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                '☕',
                style: TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: PremiumSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kahve Falı',
                    style: TextStyle(
                      color: PremiumColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: PremiumSpacing.xs),
                  Text(
                    MysticalStrings.coffeeFortuneHint,
                    style: TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow with glow
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.sm),
              decoration: BoxDecoration(
                color: PremiumColors.primaryPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: PremiumColors.primaryPurple,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium dreams card
class DreamsCard extends StatelessWidget {
  final VoidCallback onTap;

  const DreamsCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PremiumSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1B4B).withOpacity(0.8),
              const Color(0xFF312E81).withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(PremiumRadius.xl),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Moon icon with glow
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.3),
                    const Color(0xFF8B5CF6).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(PremiumRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Text(
                '🌙',
                style: TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: PremiumSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rüya Yorumu',
                    style: TextStyle(
                      color: PremiumColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: PremiumSpacing.xs),
                  Text(
                    MysticalStrings.dreamHint,
                    style: TextStyle(
                      color: PremiumColors.textSecondary,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(PremiumSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6366F1),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
