import 'package:flutter/material.dart';

class BottomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;

  const BottomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.indigo.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(55), // 버튼 높이 확보
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon),
          label: Text(label, style: const TextStyle(fontSize: 16)),
          onPressed: onPressed,
        ),
      ),
    );
  }
}