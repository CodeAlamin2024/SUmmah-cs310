import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../state/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/announcement_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/responsive_scroll_body.dart';
import '../widgets/undo_snack_bar.dart';

/// S3 – Announcements.
///
/// The masjid's updates as cards students can filter by category, open
/// (S3.1) and hide on their own device (close button or swipe, with Undo).
/// When nothing matches, an empty state offers "Show all".
///
/// This widget is a tab body: the bottom navigation bar is provided by the
/// parent shell, so there is no Scaffold here.
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final filter = state.filter;
          final items = state.filteredAnnouncements;
          final canShowAll = filter != null || state.hasHiddenAnnouncements;

          return ResponsiveScrollBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Announcements', style: AppTextStyles.h1),
                const Gap(AppSpacing.xs),
                const Text(
                  'News and events from the masjid',
                  style: AppTextStyles.bodySecondary,
                ),
                const Gap(AppSpacing.lg),
                _CategoryFilters(selected: filter, onSelected: state.setFilter),
                const Gap(AppSpacing.md),
                if (items.isEmpty)
                  EmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No announcements here',
                    message: filter == null
                        ? 'There is nothing new from the masjid right now.'
                        : 'There are no ${filter.label} announcements to show.',
                    actionLabel: canShowAll ? 'Show all' : null,
                    onAction: state.showAllAnnouncements,
                  )
                else
                  for (final announcement in items)
                    Padding(
                      key: ValueKey(announcement.id),
                      padding: const EdgeInsets.only(bottom: AppSpacing.md - 2),
                      child: AnnouncementCard(
                        announcement: announcement,
                        onTap: () => openAnnouncement(context, announcement),
                        onHide: () => hideAnnouncement(context, announcement),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Opens the full announcement (S3.1).
void openAnnouncement(BuildContext context, Announcement announcement) {
  Navigator.of(context).pushNamed(
    AppRoutes.announcementDetail,
    arguments: announcement,
  );
}

/// Hides an announcement on this device and offers Undo.
void hideAnnouncement(BuildContext context, Announcement announcement) {
  final state = AppState.instance;
  state.hideAnnouncement(announcement.id);
  showUndoSnackBar(
    context,
    message: 'Announcement hidden on this device',
    onUndo: () => state.unhideAnnouncement(announcement.id),
  );
}

/// "All" plus one chip per category. Scrolls sideways on narrow phones.
class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selected, required this.onSelected});

  final AnnouncementCategory? selected;
  final ValueChanged<AnnouncementCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in AnnouncementCategory.values)
            _FilterChip(
              label: category.label,
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm - 2),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (value) => onTap(),
        showCheckmark: false,
        labelStyle: AppTextStyles.label.copyWith(
          color: selected ? AppColors.textOnPrimary : AppColors.textPrimary,
        ),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
        shape: const StadiumBorder(),
      ),
    );
  }
}
