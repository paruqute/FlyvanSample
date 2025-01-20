import 'package:flutter/material.dart';

import '../utils/colors.dart';


class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    this.name,
    this.onPressed,
  });

  final String? name;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titleTextStyle: Theme
          .of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: primaryColor, fontSize: 18),
      title: Text(
        "$name",
      ),
      content: Text("Are you sure ?", style: Theme
          .of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontSize: 15),),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Close dialog
          child: Text(
            "Cancel",
            style: Theme
                .of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: primaryColor, fontSize: 12),
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(
            "Confirm",
            style: Theme
                .of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }
}