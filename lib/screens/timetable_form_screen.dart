import 'package:flutter/material.dart';

import '../models/prayer_schedule.dart';
import '../services/prayer_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../utils/validators.dart';
import '../widgets/app_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scroll_body.dart';

/// One row of the form: a prayer and its two times, edited as [TimeOfDay].
class _EditablePrayer {
  const _EditablePrayer({
    required this.prayer,
    required this.adhan,
    required this.iqamah,
  });

  factory _EditablePrayer.fromSchedule(PrayerSchedule entry) {
    return _EditablePrayer(
      prayer: entry.prayer,
      adhan: TimeOfDay(hour: entry.adhanTime.hour, minute: entry.adhanTime.minute),
      iqamah: TimeOfDay(hour: entry.iqamahTime.hour, minute: entry.iqamahTime.minute),
    );
  }

  final Prayer prayer;
  final TimeOfDay adhan;
  final TimeOfDay iqamah;

  String get name => prayer.label;

  _EditablePrayer copyWith({TimeOfDay? adhan, TimeOfDay? iqamah}) {
    return _EditablePrayer(
      prayer: prayer,
      adhan: adhan ?? this.adhan,
      iqamah: iqamah ?? this.iqamah,
    );
  }

  /// Back to the shared model. Times are stored in Türkiye time (see
  /// PrayerService), so Home's countdown uses them straight away.
  PrayerSchedule toSchedule(DateTime date) {
    return PrayerSchedule(
      date: date,
      prayer: prayer,
      adhanTime: DateTime.utc(date.year, date.month, date.day, adhan.hour, adhan.minute),
      iqamahTime:
          DateTime.utc(date.year, date.month, date.day, iqamah.hour, iqamah.minute),
    );
  }
}

class _PrayerRowError {
  const _PrayerRowError({
    required this.message,
    this.adhanError = false,
    this.iqamahError = false,
  });

  final String message;
  final bool adhanError;
  final bool iqamahError;
}

/// S9 – Timetable form (create or edit a day's prayer schedule).
///
/// Lets organisers pick or change the date, edit all five adhan and iqamah
/// times via 24-hour time pickers, and add optional day notes. Validates that
/// the date is not already scheduled, every iqamah comes after its adhan, and
/// all five prayers stay in chronological order, then shows the D4
/// confirmation dialog before returning the [DaySchedule] to S7, which saves
/// it to the shared timetable used by Home (S1) and the timetable (S2).
class TimetableFormScreen extends StatefulWidget {
  const TimetableFormScreen({
    super.key,
    this.schedule,
    this.defaultDate,
    this.existingDates = const [],
  });

  /// Existing schedule when editing; `null` when adding a new day.
  final DaySchedule? schedule;

  /// Initial date used when [schedule] is `null`.
  final DateTime? defaultDate;

  /// Dates that already have a schedule (excluding the current item when
  /// editing), used to prevent duplicate days.
  final List<DateTime> existingDates;

  @override
  State<TimetableFormScreen> createState() => _TimetableFormScreenState();
}

class _TimetableFormScreenState extends State<TimetableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late final DateTime _initialDate;
  late final List<_EditablePrayer> _initialPrayers;
  late final List<_EditablePrayer> _prayers;
  late final TextEditingController _notesController;

  bool _showValidationErrors = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool get _isEditing => widget.schedule != null;

  static List<_EditablePrayer> _defaultPrayers() => const [
        _EditablePrayer(
          prayer: Prayer.fajr,
          adhan: TimeOfDay(hour: 6, minute: 30),
          iqamah: TimeOfDay(hour: 6, minute: 50),
        ),
        _EditablePrayer(
          prayer: Prayer.dhuhr,
          adhan: TimeOfDay(hour: 12, minute: 50),
          iqamah: TimeOfDay(hour: 13, minute: 5),
        ),
        _EditablePrayer(
          prayer: Prayer.asr,
          adhan: TimeOfDay(hour: 15, minute: 20),
          iqamah: TimeOfDay(hour: 15, minute: 35),
        ),
        _EditablePrayer(
          prayer: Prayer.maghrib,
          adhan: TimeOfDay(hour: 17, minute: 40),
          iqamah: TimeOfDay(hour: 17, minute: 46),
        ),
        _EditablePrayer(
          prayer: Prayer.isha,
          adhan: TimeOfDay(hour: 19, minute: 5),
          iqamah: TimeOfDay(hour: 19, minute: 25),
        ),
      ];

  @override
  void initState() {
    super.initState();
    final existing = widget.schedule;
    _initialDate = PrayerService.dateOnly(
      existing?.date ?? widget.defaultDate ?? PrayerService.todayInTurkey(),
    );
    _selectedDate = _initialDate;
    _initialPrayers = existing != null
        ? [for (final entry in existing.prayers) _EditablePrayer.fromSchedule(entry)]
        : _defaultPrayers();
    _prayers = List<_EditablePrayer>.from(_initialPrayers);
    _notesController =
        TextEditingController(text: widget.schedule?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    if (!DateFormatter.isSameDay(_selectedDate, _initialDate)) {
      return true;
    }
    final initialNotes = widget.schedule?.notes?.trim() ?? '';
    if (_notesController.text.trim() != initialNotes) {
      return true;
    }
    for (var i = 0; i < _prayers.length; i++) {
      final original = _initialPrayers[i];
      if (_prayers[i].adhan != original.adhan ||
          _prayers[i].iqamah != original.iqamah) {
        return true;
      }
    }
    return false;
  }

  String? _validateDate() {
    final isDuplicate = widget.existingDates
        .any((d) => DateFormatter.isSameDay(d, _selectedDate));
    if (isDuplicate) {
      return 'A timetable for ${DateFormatter.short(_selectedDate)} already exists';
    }
    return null;
  }

  /// Validates all 10 prayer times:
  /// 1. Each prayer's iqamah must come strictly after its own adhan.
  /// 2. Each prayer's adhan must come strictly after the previous prayer's iqamah.
  Map<int, _PrayerRowError> _validatePrayers() {
    final errors = <int, _PrayerRowError>{};

    for (var i = 0; i < _prayers.length; i++) {
      final current = _prayers[i];
      final adhanMin = DateFormatter.toMinutes(current.adhan);
      final iqamahMin = DateFormatter.toMinutes(current.iqamah);

      if (i > 0) {
        final prev = _prayers[i - 1];
        final prevIqamahMin = DateFormatter.toMinutes(prev.iqamah);
        if (adhanMin <= prevIqamahMin) {
          errors[i] = _PrayerRowError(
            message: '${current.name} adhan must be after '
                '${prev.name} iqamah (${DateFormatter.time24(prev.iqamah)})',
            adhanError: true,
          );
          continue;
        }
      }

      if (iqamahMin <= adhanMin) {
        errors[i] = _PrayerRowError(
          message:
              'Iqamah must be after adhan (${DateFormatter.time24(current.adhan)})',
          iqamahError: true,
        );
      }
    }

    return errors;
  }

  Future<void> _handleClose() async {
    FocusScope.of(context).unfocus();

    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    final discard = await AppDialog.show<bool>(
      context,
      title: 'Discard changes?',
      message: 'Your unsaved timetable edits will be lost.',
      actions: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Keep editing'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            textStyle: AppTextStyles.link,
          ),
          child: const Text('Discard'),
        ),
      ],
    );

    if (!mounted || discard != true) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedDate = PrayerService.dateOnly(picked));
  }

  Future<void> _pickTime(int index, {required bool isAdhan}) async {
    FocusScope.of(context).unfocus();
    final current = isAdhan ? _prayers[index].adhan : _prayers[index].iqamah;

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;
    setState(() {
      _prayers[index] = isAdhan
          ? _prayers[index].copyWith(adhan: picked)
          : _prayers[index].copyWith(iqamah: picked);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final notesValid = _formKey.currentState!.validate();
    final dateError = _validateDate();
    final timeErrors = _validatePrayers();

    if (!notesValid || dateError != null || timeErrors.isNotEmpty) {
      setState(() {
        _showValidationErrors = true;
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    // D4 – Save timetable confirmation dialog.
    final confirmed = await AppDialog.show<bool>(
      context,
      title: 'Save timetable for ${DateFormatter.short(_selectedDate)}?',
      message: 'Home and the timetable will use the new times straight away.',
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
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.link,
          ),
          child: const Text('Save'),
        ),
      ],
    );

    if (!mounted || confirmed != true) return;

    final date = PrayerService.dateOnly(_selectedDate);
    final notes = _notesController.text.trim();
    final result = DaySchedule(
      date: date,
      prayers: List<PrayerSchedule>.unmodifiable(
        [for (final prayer in _prayers) prayer.toSchedule(date)],
      ),
      notes: notes.isEmpty ? null : notes,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final dateError = _showValidationErrors ? _validateDate() : null;
    final errors = _showValidationErrors
        ? _validatePrayers()
        : const <int, _PrayerRowError>{};

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleClose();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: _handleClose,
          ),
          title: Text(_isEditing ? 'Edit timetable' : 'Add timetable'),
        ),
        body: ResponsiveScrollBody(
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InkWell(
                    key: const Key('timetable_date_picker'),
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: dateError != null
                              ? AppColors.error
                              : AppColors.border,
                          width: dateError != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const Gap(AppSpacing.sm),
                          Expanded(
                            child: Text(
                              DateFormatter.weekdayLong(_selectedDate),
                              style: AppTextStyles.title,
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (dateError != null) ...[
                  const Gap(AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.error_outline,
                          size: 14,
                          color: AppColors.error,
                        ),
                      ),
                      const Gap(AppSpacing.xs),
                      Expanded(
                        child: Text(dateError, style: AppTextStyles.error),
                      ),
                    ],
                  ),
                ],
                const Gap(AppSpacing.lg),
                const Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: Text('Prayer', style: AppTextStyles.caption),
                    ),
                    Gap(AppSpacing.sm),
                    Expanded(
                      child: Text('Adhan', style: AppTextStyles.caption),
                    ),
                    Gap(AppSpacing.sm),
                    Expanded(
                      child: Text('Iqamah', style: AppTextStyles.caption),
                    ),
                  ],
                ),
                const Gap(AppSpacing.sm),
                for (var i = 0; i < _prayers.length; i++)
                  _PrayerTimeRow(
                    prayer: _prayers[i],
                    error: errors[i],
                    onPickAdhan: () => _pickTime(i, isAdhan: true),
                    onPickIqamah: () => _pickTime(i, isAdhan: false),
                  ),
                const Gap(AppSpacing.md),
                const Text(
                  'Notes for this day (optional)',
                  style: AppTextStyles.label,
                ),
                const Gap(AppSpacing.xs + 2),
                TextFormField(
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body,
                  validator: Validators.timetableNotes,
                  decoration: const InputDecoration(
                    hintText: 'For example, Isha iqamah is later this week',
                  ),
                ),
                const Gap(AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: _isEditing ? 'Save changes' : 'Add timetable',
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerTimeRow extends StatelessWidget {
  const _PrayerTimeRow({
    required this.prayer,
    required this.error,
    required this.onPickAdhan,
    required this.onPickIqamah,
  });

  final _EditablePrayer prayer;
  final _PrayerRowError? error;
  final VoidCallback onPickAdhan;
  final VoidCallback onPickIqamah;

  @override
  Widget build(BuildContext context) {
    final keyPrefix = prayer.name.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 84,
                child: Text(prayer.name, style: AppTextStyles.title),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _TimeFieldButton(
                  key: Key('adhan_$keyPrefix'),
                  time: prayer.adhan,
                  hasError: error?.adhanError ?? false,
                  onTap: onPickAdhan,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _TimeFieldButton(
                  key: Key('iqamah_$keyPrefix'),
                  time: prayer.iqamah,
                  hasError: error?.iqamahError ?? false,
                  onTap: onPickIqamah,
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const Gap(AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.error_outline,
                    size: 14,
                    color: AppColors.error,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Expanded(
                  child: Text(error!.message, style: AppTextStyles.error),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeFieldButton extends StatelessWidget {
  const _TimeFieldButton({
    super.key,
    required this.time,
    required this.hasError,
    required this.onTap,
  });

  final TimeOfDay time;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormatter.time24(time),
                  style: AppTextStyles.body,
                ),
              ),
              const Icon(
                Icons.schedule,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}