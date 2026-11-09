import 'package:flutter/material.dart';

class EditDeleteButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EditDeleteButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Colors.grey.shade700,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onEdit,
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.red.shade400,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onDelete,
        ),
      ],
    );
  }
}