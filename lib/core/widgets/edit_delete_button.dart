import 'package:flutter/material.dart';

class EditDeleteButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double iconSize;
  final double spacing;

  const EditDeleteButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.iconSize = 18,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, size: iconSize),
          color: Colors.grey.shade700,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          onPressed: onEdit,
        ),
        SizedBox(width: spacing),
        IconButton(
          icon: Icon(Icons.delete_outline, size: iconSize),
          color: Colors.red.shade400,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
        ),
      ],
    );
  }
}