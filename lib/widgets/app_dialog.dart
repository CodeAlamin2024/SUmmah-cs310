import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// Shared confirmation / result dialog (D1–D4 in Figma).
///
/// * With an [icon] the content is centred and actions are stacked
///   full width (D1 "Demo account created").
/// * Without an icon the title is left-aligned and actions sit on the
///   right (D2 Publish, D3 Delete, D4 Save).
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    this.icon,
  });

  final String title;
  final String message;
  final List<Widget> actions;
  final IconData? icon;

  /// Shows the dialog over the dark brand scrim.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<Widget> Function(BuildContext dialogContext) actions,
    IconData? icon,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: AppColors.dialogBarrier,
      builder: (dialogContext) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        actions: actions(dialogContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centred = icon != null;
    final textAlign = centred ? TextAlign.center : TextAlign.start;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const Gap(AppSpacing.md),
              ],
              Text(title, style: AppTextStyles.h2, textAlign: textAlign),
              const Gap(AppSpacing.sm),
              Text(message,
                  style: AppTextStyles.bodySecondary, textAlign: textAlign),
              const Gap(AppSpacing.xl),
              if (centred)
                ...actions
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    alignment: WrapAlignment.end,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
