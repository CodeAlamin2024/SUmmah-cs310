import 'package:flutter/material.dart';

import '../utils/app_spacing.dart';

/// Scrollable, centred body with a maximum content width.
///
/// * Scrolls on small phones and when the keyboard is open, so screens
///   never show overflow errors.
/// * Caps the width on large phones / tablets so layouts don't stretch.
class ResponsiveScrollBody extends StatelessWidget {
  const ResponsiveScrollBody({
    super.key,
    required this.child,
    this.padding = AppSpacing.screenPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
