import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard/dashboard_provider.dart';

class MonthSelectorHeader extends ConsumerWidget {
  final List<String> months;
  final String currentMonth;

  const MonthSelectorHeader({
    super.key,
    required this.months,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = months.indexOf(currentMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentIndex >= 0 && currentIndex < months.length - 1)
                ? () {
                    ref
                        .read(selectedYearMonthProvider.notifier)
                        .select(months[currentIndex + 1]);
                  }
                : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: months.contains(currentMonth) ? currentMonth : months.first,
              icon: const Icon(Icons.arrow_drop_down),
              items: months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(
                    month,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newMonth) {
                if (newMonth != null) {
                  ref.read(selectedYearMonthProvider.notifier).select(newMonth);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentIndex > 0
                ? () {
                    ref
                        .read(selectedYearMonthProvider.notifier)
                        .select(months[currentIndex - 1]);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}