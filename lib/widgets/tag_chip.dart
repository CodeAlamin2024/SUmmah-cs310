import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// Small rounded label: categories ("Jumu'ah"), "Sample", demo notices.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final IconData? icon;

  /// Outlined chips are used for "demo only" notices, filled ones for categories.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: outlined ? AppColors.surface : AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: outlined ? AppColors.border : AppColors.primaryTint,
        ),
      ),
      // Text.rich (instead of a Row) lets the label wrap on narrow screens
      // and still works inside rows that give unbounded width.
      child: Text.rich(
        TextSpan(
          children: [
            if (icon != null) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(icon, size: 14, color: AppColors.textSecondary),
              ),
              const WidgetSpan(child: SizedBox(width: AppSpacing.xs)),
            ],
            TextSpan(text: label),
          ],
        ),
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: outlined ? AppColors.textSecondary : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
