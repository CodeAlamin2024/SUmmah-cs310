import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/friday_update.dart';
import '../models/jumuah_info.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';
import '../widgets/friday_update_card.dart';
import '../widgets/info_row.dart';
import '../widgets/responsive_scroll_body.dart';
import '../widgets/section_header.dart';
import '../widgets/tag_chip.dart';
import '../widgets/undo_snack_bar.dart';

/// S4 – Jumu'ah tab.
///
/// Shows this Friday's khutbah / salah times, a bundled (local) masjid image,
/// location + khutbah info, congregation notices and a list of
/// [FridayUpdate] cards that can be removed (with Undo).
///
/// This widget is a tab body: the bottom navigation bar is provided by
/// the parent shell, so there is no Scaffold here.
class JumuahScreen extends StatefulWidget {
  const JumuahScreen({super.key, this.onSeeAllUpdates, this.onOpenUpdate});

  /// "All Friday updates >" – the shell switches to the Announcements tab
  /// with the Jumu'ah filter.
  final VoidCallback? onSeeAllUpdates;

  /// Tapping a card – opens the announcement detail screen (S3.1).
  final ValueChanged<FridayUpdate>? onOpenUpdate;

  @override
  State<JumuahScreen> createState() => _JumuahScreenState();
}

class _JumuahScreenState extends State<JumuahScreen> {
  final JumuahInfo _info = SampleData.jumuahInfo;
  final List<CongregationNotice> _notices = SampleData.congregationNotices;
  final List<FridayUpdate> _updates = SampleData.fridayUpdates();

  /// Removes the card and shows a SnackBar with Undo.
  void _removeUpdate(FridayUpdate update) {
    final index = _updates.indexOf(update);
    if (index == -1) return;

    setState(() => _updates.removeAt(index));

    showUndoSnackBar(
      context,
      message: 'Update hidden on this device',
      onUndo: () {
        if (!mounted) return;
        setState(() {
          _updates.insert(math.min(index, _updates.length), update);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ResponsiveScrollBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Jumu'ah", style: AppTextStyles.h1),
            const Gap(AppSpacing.lg),
            _FridayHeroCard(info: _info),
            const Gap(AppSpacing.lg),
            const _MasjidImage(),
            const Gap(AppSpacing.lg),
            InfoRow(
              icon: Icons.location_on_outlined,
              title: _info.locationName,
              description: _info.locationNote,
            ),
            const Gap(AppSpacing.md),
            InfoRow(
              icon: Icons.record_voice_over_outlined,
              title: 'Khutbah',
              description: _info.khutbahNote,
            ),
            const Gap(AppSpacing.xl),
            const SectionHeader(
              title: 'Congregation notices',
              trailing: TagChip(label: 'Sample', outlined: true),
            ),
            const Gap(AppSpacing.sm),
            _NoticesCard(notices: _notices),
            const Gap(AppSpacing.xl),
            SectionHeader(
              title: 'Friday updates',
              actionLabel: 'All Friday updates',
              onAction: widget.onSeeAllUpdates,
            ),
            const Gap(AppSpacing.sm),
            if (_updates.isEmpty)
              const _EmptyUpdates()
            else
              for (final update in _updates)
                Padding(
                  key: ValueKey(update.id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: FridayUpdateCard(
                    update: update,
                    onRemove: () => _removeUpdate(update),
                    onTap: widget.onOpenUpdate == null
                        ? null
                        : () => widget.onOpenUpdate!(update),
                  ),
                ),
            const Gap(AppSpacing.md),
            const Text(
              "Jumu'ah times and notices are sample data.",
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dark green card with the date and times of this Friday's prayer.
class _FridayHeroCard extends StatelessWidget {
  const _FridayHeroCard({required this.info});

  final JumuahInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Friday', style: AppTextStyles.overline),
          const Gap(AppSpacing.xs),
          // scaleDown keeps the long date on one line on narrow phones
          // instead of overflowing.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(DateFormatter.long(info.date),
                style: AppTextStyles.display),
          ),
          const Gap(AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.md,
            children: [
              _TimeBlock(label: 'Khutbah', time: info.khutbahTime),
              _TimeBlock(label: 'Salah', time: info.salahTime),
            ],
          ),
          const Gap(AppSpacing.lg),
          const Divider(height: 1, color: AppColors.dividerOnPrimary),
          const Gap(AppSpacing.md),
          Text(
            'Sample times for the CS310 demo.',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textOnPrimaryMuted),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textOnPrimaryMuted)),
        Text(time, style: AppTextStyles.display.copyWith(fontSize: 22)),
      ],
    );
  }
}

/// Local (bundled) image of the masjid – satisfies the "local image" requirement.
class _MasjidImage extends StatelessWidget {
  const _MasjidImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AspectRatio(
        aspectRatio: 12 / 5,
        child: Image.asset(
          'assets/images/jumuah_mosque.png',
          fit: BoxFit.cover,
          semanticLabel: "Illustration of Sabancı University Masjid",
        ),
      ),
    );
  }
}

class _NoticesCard extends StatelessWidget {
  const _NoticesCard({required this.notices});

  final List<CongregationNotice> notices;

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
          for (var i = 0; i < notices.length; i++) ...[
            if (i > 0) const Gap(AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(notices[i].icon, size: 18, color: AppColors.primary),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Text(notices[i].text, style: AppTextStyles.body),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyUpdates extends StatelessWidget {
  const _EmptyUpdates();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textSecondary),
          Gap(AppSpacing.sm),
          Text(
            'No Friday updates to show.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
