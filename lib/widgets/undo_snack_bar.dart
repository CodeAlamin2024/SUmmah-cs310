import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Shows a message with an Undo button, for example after hiding an
/// announcement.
///
/// The Undo button is part of the message rather than a [SnackBarAction]
/// because newer Flutter versions keep SnackBars with actions on screen
/// until they are dismissed. This one disappears by itself after a few
/// seconds on every Flutter version.
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Expanded(child: Text(message)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            onPressed: () {
              messenger.hideCurrentSnackBar();
              onUndo();
            },
            child: const Text('Undo'),
          ),
        ],
      ),
    ),
  );
}
