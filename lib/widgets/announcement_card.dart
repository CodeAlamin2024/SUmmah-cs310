import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import 'tag_chip.dart';

/// An icon for each announcement category.
extension AnnouncementCategoryIcon on AnnouncementCategory {
  IconData get icon {
    switch (this) {
      case AnnouncementCategory.general:
        return Icons.info_outline_rounded;
      case AnnouncementCategory.jumuah:
        return Icons.mosque_outlined;
      case AnnouncementCategory.events:
        return Icons.event_outlined;
      case AnnouncementCategory.important:
        return Icons.priority_high_rounded;
    }
  }
}

/// One announcement in the S3 feed, built on a Flutter [Card].
///
/// When [onHide] is given, the card can be hidden with its close button or
/// by swiping it to the left.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
    this.onHide,
  });

  final Announcement announcement;
  final VoidCallback? onTap;
  final VoidCallback? onHide;

  static const double imageHeight = 120;

  @override
  Widget build(BuildContext context) {
    final imageUrl = announcement.imageUrl;
    final onHide = this.onHide;

    final card = Card(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null) AnnouncementImage(url: imageUrl, height: imageHeight),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                onHide != null ? 44 : AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TagChip(label: announcement.category.label),
                      const Gap(AppSpacing.sm),
                      Flexible(
                        child: Text(
                          DateFormatter.short(announcement.publishedAt),
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    announcement.title,
                    style: AppTextStyles.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(AppSpacing.xs),
                  Text(
                    announcement.description,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onHide == null) return card;

    return Dismissible(
      key: ValueKey('announcement-${announcement.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onHide(),
      background: const _HideBackground(),
      child: Stack(
        children: [
          card,
          Positioned(
            top: imageUrl != null ? imageHeight + 2 : 2,
            right: 2,
            child: IconButton(
              tooltip: 'Hide announcement',
              icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
              onPressed: onHide,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact announcement row, used for the "Latest announcements" preview
/// on Home (S1).
class AnnouncementTile extends StatelessWidget {
  const AnnouncementTile({super.key, required this.announcement, this.onTap});

  final Announcement announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(announcement.category.icon, size: 19, color: AppColors.primary),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      '${announcement.category.label} · '
                      '${DateFormatter.short(announcement.publishedAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// An image loaded from the network, with a placeholder while it loads and
/// a fallback icon if it cannot be loaded.
class AnnouncementImage extends StatelessWidget {
  const AnnouncementImage({super.key, required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        semanticLabel: 'Announcement image',
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return const _ImagePlaceholder(icon: Icons.image_outlined);
        },
        errorBuilder: (context, error, stackTrace) =>
            const _ImagePlaceholder(icon: Icons.image_not_supported_outlined),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.imagePlaceholder,
      child: Center(child: Icon(icon, size: 32, color: AppColors.textSecondary)),
    );
  }
}

class _HideBackground extends StatelessWidget {
  const _HideBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility_off_outlined, color: AppColors.primary, size: 20),
          const Gap(AppSpacing.sm),
          Text('Hide', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
