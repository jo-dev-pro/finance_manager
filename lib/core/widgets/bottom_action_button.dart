import 'package:flutter/material.dart';
import '../utils/responsive_extension.dart'; // 프로젝트 경로에 맞게 수정

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
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.desktopWidthSize),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        ),
      ),
    );
  }
}