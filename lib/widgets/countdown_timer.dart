import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/prayer_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../utils/date_format.dart';

/// Rebuilds its child every [interval] with the current Türkiye time.
///
/// The timer is cancelled when the widget is removed, so it never keeps
/// running in the background.
class ClockBuilder extends StatefulWidget {
  const ClockBuilder({
    super.key,
    this.interval = const Duration(seconds: 1),
    required this.builder,
  });

  final Duration interval;
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<ClockBuilder> createState() => _ClockBuilderState();
}

class _ClockBuilderState extends State<ClockBuilder> {
  DateTime _now = PrayerService.nowInTurkey();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(ClockBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interval != widget.interval) _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() => _now = PrayerService.nowInTurkey());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);
}

/// The dark green hero card on Home (S1): the next prayer, a live
/// countdown, its adhan and iqamah times and a progress bar.
class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key, required this.status});

  /// Null when no upcoming times are published.
  final NextPrayerStatus? status;

  @override
  Widget build(BuildContext context) {
    final status = this.status;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: -34,
            top: -30,
            child: GeometricMotif(size: 150),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl - 4),
            child: status == null ? const _NoTimes() : _Content(status: status),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.status});

  final NextPrayerStatus status;

  static const TextStyle _muted = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textOnPrimaryMuted,
  );

  @override
  Widget build(BuildContext context) {
    final schedule = status.next.schedule;
    final previous = status.previous;
    final percent = (status.progress * 100).round();

    return Semantics(
      label: 'Next prayer ${schedule.prayerName}. '
          '${status.next.type.label} in ${DateFormatter.relative(status.remaining)}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.isTomorrow ? 'Next prayer · Tomorrow' : 'Next prayer',
            style: AppTextStyles.overline,
          ),
          const Gap(AppSpacing.xs),
          Text(
            schedule.prayerName,
            style: AppTextStyles.h1.copyWith(color: AppColors.textOnPrimary),
          ),
          const Gap(AppSpacing.xs),
          ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormatter.countdown(status.remaining),
                style: AppTextStyles.display.copyWith(
                  fontSize: 38,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Text('until ${status.next.type.label}', style: _muted),
          const Gap(AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.sm,
            children: [
              _TimeColumn(label: 'Adhan', time: DateFormatter.time(schedule.adhanTime)),
              _TimeColumn(label: 'Iqamah', time: DateFormatter.time(schedule.iqamahTime)),
            ],
          ),
          const Gap(AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: status.progress,
              minHeight: 6,
              color: AppColors.accent,
              backgroundColor: AppColors.dividerOnPrimary,
            ),
          ),
          if (previous != null) ...[
            const Gap(6),
            Text(
              '$percent% of the way from ${previous.label} to ${status.next.label}',
              style: _muted,
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _Content._muted),
        Text(time, style: AppTextStyles.display.copyWith(fontSize: 20)),
      ],
    );
  }
}

class _NoTimes extends StatelessWidget {
  const _NoTimes();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Next prayer', style: AppTextStyles.overline),
          const Gap(6),
          Text(
            'No upcoming times published',
            style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary),
          ),
          const Gap(AppSpacing.xs),
          const Text(
            'The masjid has not published times for the coming days yet.',
            style: _Content._muted,
          ),
        ],
      ),
    );
  }
}

/// A quiet eight-pointed star outline used as decoration on green cards.
class GeometricMotif extends StatelessWidget {
  const GeometricMotif({super.key, this.size = 150, this.color = AppColors.motifOnPrimary});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          size: Size.square(size),
          painter: _MotifPainter(color),
        ),
      ),
    );
  }
}

class _MotifPainter extends CustomPainter {
  _MotifPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * scale;
    final center = Offset(size.width / 2, size.height / 2);

    void square(double side, double angle) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: side * scale, height: side * scale),
        paint,
      );
      canvas.restore();
    }

    square(70, 0);
    square(70, math.pi / 4);
    square(30, math.pi / 4);
    canvas.drawCircle(center, 20 * scale, paint);
  }

  @override
  bool shouldRepaint(_MotifPainter oldDelegate) => oldDelegate.color != color;
}
