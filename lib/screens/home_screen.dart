import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/jumuah_info.dart';
import '../services/prayer_service.dart';
import '../state/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../widgets/announcement_card.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/empty_state.dart';
import '../widgets/prayer_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scroll_body.dart';
import '../widgets/section_header.dart';

/// S1 – Home dashboard.
///
/// Answers "when is the next prayer?" without any taps: a live countdown,
/// today's adhan and iqamah times, a Jumu'ah preview and the latest
/// announcements. The admin icon in the header opens S5.
///
/// This widget is a tab body: the bottom navigation bar is provided by the
/// parent shell, so there is no Scaffold here.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onOpenTimetable,
    this.onOpenAnnouncements,
    this.onOpenJumuah,
  });

  /// "Full timetable >" – the shell switches to the Timetable tab.
  final VoidCallback? onOpenTimetable;

  /// "View all >" – the shell switches to the Announcements tab.
  final VoidCallback? onOpenAnnouncements;

  /// "Jumu'ah details" – the shell switches to the Jumu'ah tab.
  final VoidCallback? onOpenJumuah;

  /// How many announcements are previewed on Home.
  static const int previewCount = 2;

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => ClockBuilder(
          builder: (context, now) {
            final today = PrayerService.dateOnly(now);
            final day = state.dayFor(today);
            final status = PrayerService.status(state.dayFor, now);
            final latest = state.visibleAnnouncements.take(previewCount).toList();

            return ResponsiveScrollBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const Gap(AppSpacing.lg),
                  Text(DateFormatter.full(today), style: AppTextStyles.label),
                  const Gap(AppSpacing.md),
                  CountdownTimer(status: status),
                  const Gap(AppSpacing.xl),
                  SectionHeader(
                    title: "Today's prayers",
                    actionLabel: 'Full timetable',
                    onAction: onOpenTimetable,
                  ),
                  const Gap(AppSpacing.sm),
                  if (day != null)
                    PrayerTable(
                      prayers: day.prayers,
                      nextPrayer: PrayerService.highlightedPrayer(status, now),
                      now: now,
                    )
                  else
                    const EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'No times for today',
                      message: "Today's prayer times have not been published yet.",
                    ),
                  const Gap(AppSpacing.xl),
                  const SectionHeader(title: "Jumu'ah"),
                  const Gap(AppSpacing.sm),
                  _JumuahPreview(
                    info: SampleData.jumuahInfo,
                    today: today,
                    onOpen: onOpenJumuah,
                  ),
                  const Gap(AppSpacing.xl),
                  SectionHeader(
                    title: 'Latest announcements',
                    actionLabel: 'View all',
                    onAction: onOpenAnnouncements,
                  ),
                  const Gap(AppSpacing.sm),
                  if (latest.isEmpty)
                    const Text(
                      'No announcements right now.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  for (final announcement in latest)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AnnouncementTile(
                        announcement: announcement,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.announcementDetail,
                          arguments: announcement,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// App name, masjid name and the admin entry point (S5).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Icon(Icons.mosque, color: AppColors.accent, size: 24),
        ),
        const Gap(AppSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SUmmah', style: AppTextStyles.h1),
              Text(
                'Sabancı University Masjid',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton.outlined(
          tooltip: 'Admin sign in',
          style: IconButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.admin_panel_settings_outlined, size: 22),
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminSignIn),
        ),
      ],
    );
  }
}

/// Small card with this week's Jumu'ah times and a link to S4.
class _JumuahPreview extends StatelessWidget {
  const _JumuahPreview({required this.info, required this.today, this.onOpen});

  final JumuahInfo info;
  final DateTime today;
  final VoidCallback? onOpen;

  String get _when {
    if (PrayerService.isSameDay(info.date, today)) return 'Today';
    final tomorrow = today.add(const Duration(days: 1));
    if (PrayerService.isSameDay(info.date, tomorrow)) {
      return 'Tomorrow · ${DateFormatter.dayMonth(info.date)}';
    }
    return DateFormatter.full(info.date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque_outlined, size: 20, color: AppColors.primary),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_when, style: AppTextStyles.title),
                    const Gap(2),
                    Text(
                      'Khutbah ${info.khutbahTime} · Salah ${info.salahTime}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          SecondaryButton(label: "Jumu'ah details", onPressed: onOpen),
        ],
      ),
    );
  }
}
