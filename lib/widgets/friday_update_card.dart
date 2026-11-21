import 'package:flutter/material.dart';

import '../models/friday_update.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import 'tag_chip.dart';

/// Card that displays one [FridayUpdate] model object.
///
/// The X button calls [onRemove]; the parent screen removes the item from
/// its list and offers Undo.
class FridayUpdateCard extends StatelessWidget {
  const FridayUpdateCard({
    super.key,
    required this.update,
    required this.onRemove,
    this.onTap,
  });

  final FridayUpdate update;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final meta = update.isDemo
        ? '${DateFormatter.short(update.date)}  ·  Demo'
        : DateFormatter.short(update.date);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TagChip(label: update.category),
                  const Gap(AppSpacing.sm),
                  Expanded(
                    child: Text(
                      meta,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove update',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: onRemove,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(update.title, style: AppTextStyles.title),
                    const Gap(AppSpacing.xs),
                    Text(update.body, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
