import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// Section title with an optional trailing widget or "See all >" style link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Any widget shown on the right (e.g. a "Sample" chip).
  final Widget? trailing;

  /// Text link shown on the right when [trailing] is null.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    Widget? right = trailing;
    if (right == null && actionLabel != null) {
      right = InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(actionLabel!, style: AppTextStyles.link),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.h2)),
        if (right != null) ...[const Gap(AppSpacing.sm), right],
      ],
    );
  }
}
