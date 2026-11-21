import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../state/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../widgets/announcement_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/info_row.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scroll_body.dart';
import '../widgets/tag_chip.dart';
import 'announcements_screen.dart';

/// S3.1 – Announcement detail.
///
/// Opened from S1, S3 or S4 with the [Announcement] as the route argument:
///
/// ```dart
/// Navigator.of(context).pushNamed(AppRoutes.announcementDetail, arguments: announcement);
/// ```
///
/// Shows the full text, the network image and any event details. If an
/// admin edits the announcement while it is open, the screen updates.
class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    final state = AppState.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcement')),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          if (argument is! Announcement) {
            return ResponsiveScrollBody(
              child: EmptyState(
                icon: Icons.campaign_outlined,
                title: 'Announcement not available',
                message: 'This announcement could not be opened.',
                actionLabel: 'Go back',
                onAction: () => Navigator.of(context).pop(),
              ),
            );
          }
          // Use the latest version from the feed if there is one.
          final inFeed = state.announcementById(argument.id);
          final announcement = inFeed ?? argument;
          return _Body(
            announcement: announcement,
            canHide: inFeed != null && !state.isHidden(announcement.id),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.announcement, required this.canHide});

  final Announcement announcement;
  final bool canHide;

  @override
  Widget build(BuildContext context) {
    final imageUrl = announcement.imageUrl;
    final time = announcement.eventTime;
    final location = announcement.location;

    return ResponsiveScrollBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: AnnouncementImage(url: imageUrl, height: 190),
            ),
            const Gap(AppSpacing.lg),
          ],
          Row(
            children: [
              TagChip(label: announcement.category.label),
              const Gap(AppSpacing.sm),
              Flexible(
                child: Text(
                  'Published ${DateFormatter.long(announcement.publishedAt)}',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Text(announcement.title, style: AppTextStyles.h1),
          const Gap(AppSpacing.md),
          Text(
            announcement.description,
            style: AppTextStyles.body.copyWith(height: 1.55),
          ),
          if (announcement.hasEventDetails) ...[
            const Gap(AppSpacing.xl),
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (time != null)
                    InfoRow(icon: Icons.schedule, title: 'When', description: time),
                  if (time != null && location != null) const Gap(AppSpacing.md),
                  if (location != null)
                    InfoRow(
                      icon: Icons.location_on_outlined,
                      title: 'Where',
                      description: location,
                    ),
                ],
              ),
            ),
          ],
          if (canHide) ...[
            const Gap(AppSpacing.xxl),
            SecondaryButton(
              label: 'Hide this announcement',
              onPressed: () {
                hideAnnouncement(context, announcement);
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
