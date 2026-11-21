import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'primary_button.dart';

/// Friendly message for when there is nothing to show, with an optional
/// button to fix it ("No timetable for this date", "No announcements here").
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: AppColors.primary),
          ),
          const Gap(AppSpacing.lg),
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
          const Gap(AppSpacing.sm),
          Text(message, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
          if (label != null) ...[
            const Gap(AppSpacing.lg),
            SecondaryButton(label: label, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
