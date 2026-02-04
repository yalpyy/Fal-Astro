import 'package:flutter/material.dart';
import '../../../core/theme/premium_theme.dart';

/// Premium disclaimer banner for entertainment purposes
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PremiumColors.surfaceLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(PremiumRadius.md),
        border: Border.all(
          color: PremiumColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumSpacing.xs),
            decoration: BoxDecoration(
              color: PremiumColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(PremiumRadius.sm),
            ),
            child: const Text(
              '✨',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: PremiumSpacing.sm),
          Expanded(
            child: Text(
              'Bu içerik eğlence amaçlıdır ve profesyonel tavsiye yerine geçmez.',
              style: TextStyle(
                color: PremiumColors.textTertiary,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
