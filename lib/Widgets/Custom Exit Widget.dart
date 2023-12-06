import 'package:flutter/material.dart';

class ExitConfirmationDialog extends StatelessWidget {
  String? title;
  String? content;
  ExitConfirmationDialog({super.key, required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title!),
      content: Text(content!),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('YES'),
        ),
      ],
    );
  }
}