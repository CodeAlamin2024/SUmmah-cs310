import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'tag_chip.dart';

/// Logo + title + subtitle block at the top of the sign-in screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: AppSpacing.logoSize,
          height: AppSpacing.logoSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(Icons.mosque, color: AppColors.accent, size: 34),
        ),
        const Gap(AppSpacing.lg),
        Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
        const Gap(AppSpacing.xs),
        Text(subtitle,
            style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Dashed-style notice that the screen is UI-only in Step 2.
class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TagChip(label: text, icon: Icons.science_outlined, outlined: true);
  }
}

/// "Don't have an account? Create one" style footer link.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$prompt ', style: AppTextStyles.bodySecondary),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            child: Text(actionLabel, style: AppTextStyles.link),
          ),
        ),
      ],
    );
  }
}
