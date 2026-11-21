import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../models/prayer_schedule.dart';
import '../services/prayer_service.dart';
import '../state/app_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../widgets/app_dialog.dart';
import '../widgets/responsive_scroll_body.dart';
import 'announcement_form_screen.dart';
import 'timetable_form_screen.dart';

enum _AdminSection { announcements, timetable }

/// S7 – Admin dashboard.
///
/// The organiser's home with two switchable sections:
/// * Announcements: lists all announcements with add, edit (S8) and delete (D3).
/// * Timetable: lists scheduled days with add, edit (S9) and delete controls.
///
/// Everything is read from and saved to [AppState.instance], the same data the
/// student screens use, so changes appear on Home, the timetable and the
/// announcements feed straight away.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  _AdminSection _section = _AdminSection.announcements;

  AppState get _state => AppState.instance;

  void _exitToStudentView() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAnnouncementForm({Announcement? existing}) async {
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.announcementForm),
        builder: (_) => AnnouncementFormScreen(initialAnnouncement: existing),
      ),
    );

    if (!mounted || result == null) return;

    if (existing == null) {
      _state.addAnnouncement(result);
    } else {
      _state.updateAnnouncement(result);
    }

    _showMessage(
      existing == null ? 'Announcement published' : 'Announcement updated',
    );
  }

  Future<void> _confirmDeleteAnnouncement(Announcement announcement) async {
    // D3 – Delete announcement confirmation dialog.
    final confirmed = await AppDialog.show<bool>(
      context,
      title: 'Delete announcement?',
      message: '"${announcement.title}" will be removed from the '
          "announcements feed. This can't be undone.",
      actions: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            textStyle: AppTextStyles.link,
          ),
          child: const Text('Delete'),
        ),
      ],
    );

    if (!mounted || confirmed != true) return;

    _state.deleteAnnouncement(announcement.id);
    _showMessage('Announcement deleted');
  }

  DateTime _nextAvailableScheduleDate() {
    final days = _state.scheduledDays;
    if (days.isEmpty) return PrayerService.todayInTurkey();
    return days.last.date.add(const Duration(days: 1));
  }

  Future<void> _openTimetableForm({DaySchedule? existing}) async {
    final existingDates = [
      for (final day in _state.scheduledDays)
        if (existing == null || !DateFormatter.isSameDay(day.date, existing.date))
          day.date,
    ];

    final result = await Navigator.of(context).push<DaySchedule>(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.timetableForm),
        builder: (_) => TimetableFormScreen(
          schedule: existing,
          defaultDate: existing == null ? _nextAvailableScheduleDate() : null,
          existingDates: existingDates,
        ),
      ),
    );

    if (!mounted || result == null) return;

    // If the date was changed, the old day is replaced by the new one.
    _state.saveDay(result, replacing: existing?.date);
    _showMessage(existing == null ? 'Timetable added' : 'Timetable saved');
  }

  Future<void> _confirmDeleteSchedule(DaySchedule schedule) async {
    final dateLabel = DateFormatter.weekdayShort(schedule.date);

    final confirmed = await AppDialog.show<bool>(
      context,
      title: 'Delete timetable?',
      message: 'The timetable for $dateLabel will be removed. '
          "This can't be undone.",
      actions: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            textStyle: AppTextStyles.link,
          ),
          child: const Text('Delete'),
        ),
      ],
    );

    if (!mounted || confirmed != true) return;

    _state.deleteDay(schedule.date);
    _showMessage('Timetable deleted');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) => _buildPage(
        announcements: _state.allAnnouncements,
        schedules: _state.scheduledDays,
      ),
    );
  }

  Widget _buildPage({
    required List<Announcement> announcements,
    required List<DaySchedule> schedules,
  }) {
    final isAnnouncements = _section == _AdminSection.announcements;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin dashboard'),
        actions: [
          TextButton.icon(
            onPressed: _exitToStudentView,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.link,
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Student view'),
          ),
          const Gap(AppSpacing.xs),
        ],
      ),
      body: ResponsiveScrollBody(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Welcome back', style: AppTextStyles.h1),
            const Gap(AppSpacing.xs),
            const Text('Signed in as admin', style: AppTextStyles.bodySecondary),
            const Gap(AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    value: '${announcements.length}',
                    label: 'Announcements',
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: _SummaryCard(
                    value: '${schedules.length}',
                    label: 'Days scheduled',
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.lg),
            _SectionToggle(
              selected: _section,
              onChanged: (next) => setState(() => _section = next),
            ),
            const Gap(AppSpacing.lg),
            if (isAnnouncements)
              _buildAnnouncementsSection(announcements)
            else
              _buildTimetableSection(schedules),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isAnnouncements
            ? () => _openAnnouncementForm()
            : () => _openTimetableForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        icon: const Icon(Icons.add),
        label: Text(
          isAnnouncements ? 'New announcement' : 'Add day',
          style: AppTextStyles.button.copyWith(
            color: AppColors.textOnPrimary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection(List<Announcement> announcements) {
    if (announcements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.campaign_outlined, color: AppColors.textSecondary),
            Gap(AppSpacing.sm),
            Text(
              'No announcements yet. Tap "New announcement" to publish one.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final announcement in announcements)
          Padding(
            key: ValueKey(announcement.id),
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _AnnouncementAdminCard(
              announcement: announcement,
              onEdit: () => _openAnnouncementForm(existing: announcement),
              onDelete: () => _confirmDeleteAnnouncement(announcement),
            ),
          ),
      ],
    );
  }

  Widget _buildTimetableSection(List<DaySchedule> schedules) {
    if (schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.schedule_outlined, color: AppColors.textSecondary),
            Gap(AppSpacing.sm),
            Text(
              'No timetable days yet. Tap "Add day" to schedule one.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final today = PrayerService.todayInTurkey();
    final rangeLabel = 'Timetable published for '
        '${DateFormatter.range(schedules.first.date, schedules.last.date)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final day in schedules)
          Padding(
            key: ValueKey(day.date.toIso8601String()),
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ScheduleAdminCard(
              schedule: day,
              isToday: DateFormatter.isSameDay(day.date, today),
              onEdit: () => _openTimetableForm(existing: day),
              onDelete: () => _confirmDeleteSchedule(day),
            ),
          ),
        const Gap(AppSpacing.md),
        Text(
          rangeLabel,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.value, required this.label});

  final String value;
  final String label;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.h1),
          const Gap(AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionToggle extends StatelessWidget {
  const _SectionToggle({required this.selected, required this.onChanged});

  final _AdminSection selected;
  final ValueChanged<_AdminSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleSegment(
              icon: Icons.campaign_outlined,
              label: 'Announcements',
              active: selected == _AdminSection.announcements,
              onTap: () => onChanged(_AdminSection.announcements),
            ),
          ),
          Expanded(
            child: _ToggleSegment(
              icon: Icons.schedule_outlined,
              label: 'Timetable',
              active: selected == _AdminSection.timetable,
              onTap: () => onChanged(_AdminSection.timetable),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.primary : AppColors.textSecondary;

    return Material(
      color: active ? AppColors.primaryTint : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: fg),
              const Gap(AppSpacing.xs + 2),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: fg,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementAdminCard extends StatelessWidget {
  const _AnnouncementAdminCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
  });

  final Announcement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final meta =
        '${announcement.category.label}  ·  ${DateFormatter.short(announcement.publishedAt)}';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(announcement.title, style: AppTextStyles.title),
                  const Gap(AppSpacing.xs),
                  Text(meta, style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit announcement',
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete announcement',
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.primary,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleAdminCard extends StatelessWidget {
  const _ScheduleAdminCard({
    required this.schedule,
    required this.isToday,
    required this.onEdit,
    required this.onDelete,
  });

  final DaySchedule schedule;
  final bool isToday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final iqamahSummary = schedule.prayers
        .map((prayer) => DateFormatter.time(prayer.iqamahTime))
        .join('  ');
    final shortDate = DateFormatter.short(schedule.date);

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
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          DateFormatter.weekdayShort(schedule.date),
                          style: AppTextStyles.title,
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              'Today',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textOnPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      'Iqamah  $iqamahSummary',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit timetable for $shortDate',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Delete timetable for $shortDate',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}