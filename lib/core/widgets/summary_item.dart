import 'package:flutter/material.dart';

import 'jtext.dart';

// 연금평가, 주식평가 상단의 카드내 항목별 위젯
class SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const SummaryItem({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 4),
        JText(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }
}