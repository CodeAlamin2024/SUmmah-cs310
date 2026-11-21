import 'package:flutter/material.dart';

import '../models/prayer_schedule.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';

/// A table of prayers with separate adhan and iqamah columns (S1, S2).
///
/// The [nextPrayer] row gets a gold edge and a "Next" tag. When [now] is
/// given, prayers whose iqamah has already passed are greyed out.
class PrayerTable extends StatelessWidget {
  const PrayerTable({
    super.key,
    required this.prayers,
    this.nextPrayer,
    this.now,
    this.showArabic = false,
  });

  final List<PrayerSchedule> prayers;
  final Prayer? nextPrayer;
  final DateTime? now;
  final bool showArabic;

  @override
  Widget build(BuildContext context) {
    final now = this.now;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _HeaderRow(),
          for (final schedule in prayers)
            PrayerCard(
              schedule: schedule,
              isNext: schedule.prayer == nextPrayer,
              isPast: now != null &&
                  schedule.prayer != nextPrayer &&
                  !schedule.iqamahTime.isAfter(now),
              showArabic: showArabic,
            ),
        ],
      ),
    );
  }
}

/// One prayer row: name, adhan time and iqamah time.
class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.schedule,
    this.isNext = false,
    this.isPast = false,
    this.showArabic = false,
  });

  final PrayerSchedule schedule;
  final bool isNext;
  final bool isPast;
  final bool showArabic;

  static const double timeColumnWidth = 60;
  static const double _accentWidth = 3;

  @override
  Widget build(BuildContext context) {
    final color = isPast ? AppColors.textDisabled : AppColors.textPrimary;
    final timeStyle = AppTextStyles.body.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final adhan = DateFormatter.time(schedule.adhanTime);
    final iqamah = DateFormatter.time(schedule.iqamahTime);

    return Semantics(
      label: '${schedule.prayerName}, adhan $adhan, iqamah $iqamah'
          '${isNext ? ', next prayer' : ''}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: isNext ? AppColors.nextPrayerBackground : null,
          border: Border(
            top: const BorderSide(color: AppColors.divider),
            left: isNext
                ? const BorderSide(color: AppColors.accent, width: _accentWidth)
                : BorderSide.none,
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          isNext ? AppSpacing.lg - _accentWidth : AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      schedule.prayerName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: isNext ? AppColors.primary : color,
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (showArabic) ...[
                    const Gap(6),
                    Text(
                      schedule.prayer.arabicName,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: isPast ? AppColors.textDisabled : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (isNext) ...[
                    const Gap(6),
                    const NextTag(),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: timeColumnWidth,
              child: Text(adhan, style: timeStyle, textAlign: TextAlign.right),
            ),
            SizedBox(
              width: timeColumnWidth,
              child: Text(iqamah, style: timeStyle, textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}

/// The small gold "Next" label.
class NextTag extends StatelessWidget {
  const NextTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        'Next',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, 10, AppSpacing.lg, AppSpacing.sm),
        child: Row(
          children: [
            Expanded(child: Text('Prayer', style: AppTextStyles.caption)),
            SizedBox(
              width: PrayerCard.timeColumnWidth,
              child: Text('Adhan', style: AppTextStyles.caption, textAlign: TextAlign.right),
            ),
            SizedBox(
              width: PrayerCard.timeColumnWidth,
              child: Text('Iqamah', style: AppTextStyles.caption, textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}
