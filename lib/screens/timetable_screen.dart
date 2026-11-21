import 'package:flutter/material.dart';

import '../services/prayer_service.dart';
import '../state/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/empty_state.dart';
import '../widgets/prayer_card.dart';
import '../widgets/responsive_scroll_body.dart';

/// S2 – Prayer timetable.
///
/// Adhan and iqamah times for today or any chosen date (arrows or the
/// calendar button). Today's next prayer is highlighted, a banner says how
/// long until the next adhan or iqamah, and the masjid's notes for the day
/// are shown under the table. Dates without published times show an empty
/// state instead of an error.
///
/// This widget is a tab body: the bottom navigation bar is provided by the
/// parent shell, so there is no Scaffold here.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  /// The chosen date, or null to follow today (also after midnight).
  DateTime? _selected;

  void _changeDay(DateTime current, int days) {
    setState(() => _selected = current.add(Duration(days: days)));
  }

  Future<void> _pickDate(DateTime current, DateTime today) async {
    final first = DateTime(today.year - 1, today.month, today.day);
    final last = DateTime(today.year + 1, today.month, today.day);
    var initial = DateTime(current.year, current.month, current.day);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      currentDate: DateTime(today.year, today.month, today.day),
      helpText: 'Choose a date',
    );
    if (picked == null || !mounted) return;
    setState(() => _selected = PrayerService.dateOnly(picked));
  }

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
            final selected = _selected ?? today;
            final isToday = PrayerService.isSameDay(selected, today);
            final day = state.dayFor(selected);
            final status = isToday ? PrayerService.status(state.dayFor, now) : null;
            final notes = day?.notes;

            return ResponsiveScrollBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Prayer timetable', style: AppTextStyles.h1),
                      ),
                      IconButton(
                        tooltip: 'Choose a date',
                        color: AppColors.primary,
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: () => _pickDate(selected, today),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  _DateSelector(
                    date: selected,
                    isToday: isToday,
                    onPrevious: () => _changeDay(selected, -1),
                    onNext: () => _changeDay(selected, 1),
                  ),
                  const Gap(AppSpacing.md),
                  if (status != null)
                    _InfoBanner(
                      icon: Icons.schedule,
                      title: '${status.next.label} in '
                          '${DateFormatter.relative(status.remaining)}',
                      subtitle: status.next.type == PrayerEventType.adhan
                          ? 'Iqamah at ${DateFormatter.time(status.next.schedule.iqamahTime)}'
                          : 'Adhan was at ${DateFormatter.time(status.next.schedule.adhanTime)}',
                    ),
                  if (!isToday)
                    _InfoBanner(
                      icon: Icons.info_outline_rounded,
                      title: 'You are viewing another day',
                      subtitle: 'The countdown on Home always uses today.',
                      action: TextButton(
                        onPressed: () => setState(() => _selected = null),
                        child: const Text('Back to today'),
                      ),
                    ),
                  const Gap(AppSpacing.md),
                  if (day != null) ...[
                    PrayerTable(
                      prayers: day.prayers,
                      showArabic: true,
                      nextPrayer:
                          isToday ? PrayerService.highlightedPrayer(status, now) : null,
                      now: isToday ? now : null,
                    ),
                    if (notes != null) ...[
                      const Gap(AppSpacing.md),
                      _NotesCard(notes: notes),
                    ],
                  ] else
                    EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'No timetable for this date',
                      message: 'Times for ${DateFormatter.long(selected)} have not been '
                          'published yet. Choose another date or check back later.',
                      actionLabel: 'Choose another date',
                      onAction: () => _pickDate(selected, today),
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

/// Previous / next day arrows around the chosen date and a "Today" chip.
class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            color: AppColors.primary,
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  DateFormatter.shortWithWeekday(date),
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: isToday ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    isToday ? 'Today' : 'Not today',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.textOnPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            color: AppColors.primary,
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// Light green banner: the next event today, or a hint when viewing
/// another day.
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const Gap(AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const Gap(2),
                Text(subtitle, style: AppTextStyles.caption),
                if (action != null) action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The masjid's notes for the chosen day (e.g. "Jumu'ah replaces Dhuhr").
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_outlined, size: 18, color: AppColors.primary),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notes for this day', style: AppTextStyles.label),
                const Gap(AppSpacing.xs),
                Text(notes, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
