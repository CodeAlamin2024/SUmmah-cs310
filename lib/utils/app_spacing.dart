import 'package:flutter/widgets.dart';

/// Shared spacing, radius and size tokens.
class AppSpacing {
  AppSpacing._();

  // Gaps (4-point scale)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // Corner radii
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  // Sizes
  static const double buttonHeight = 52;
  static const double logoSize = 64;

  /// Content never grows wider than this, so large phones keep a
  /// comfortable reading width and small phones simply use the full width.
  static const double maxContentWidth = 480;

  static const EdgeInsets screenPadding =
      EdgeInsets.fromLTRB(lg, md, lg, xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}

/// Vertical gap helper: `const Gap(AppSpacing.lg)`.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}
