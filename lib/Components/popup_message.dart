import 'package:flutter/material.dart';

/// Small helper to show a consistent popup message across the app.
/// Usage:
/// await showPopupMessage(context, title: 'Title', message: 'Body text');
Future<T?> showPopupMessage<T>(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  final Widget dialogContent = content ?? (message != null ? Text(message) : const SizedBox.shrink());

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: dialogContent,
      actions: actions ?? [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        )
      ],
    ),
  );
}
