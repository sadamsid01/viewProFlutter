import 'package:flutter/material.dart';

showInvalidJWTDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error: No JWT provided'),
      content: const Text(
          'To create the conversations client, a JWT must be supplied on line 44 of `main.dart`'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}