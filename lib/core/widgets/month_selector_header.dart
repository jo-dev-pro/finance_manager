import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard/dashboard_provider.dart';
import '../utils/responsive_extension.dart';

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
    final canGoPrev = currentIndex >= 0 && currentIndex < months.length - 1;
    final canGoNext = currentIndex > 0;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CompactArrowButton(
            icon: Icons.chevron_left,
            enabled: canGoPrev,
            onTap:
                canGoPrev
                    ? () {
                      ref
                          .read(selectedYearMonthProvider.notifier)
                          .select(months[currentIndex + 1]);
                    }
                    : null,
          ),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: months.contains(currentMonth)
                    ? currentMonth
                    : months.first,
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                selectedItemBuilder:
                    (context) =>
                        months
                            .map(
                              (month) => Center(
                                child: Text(
                                  month,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                items:
                    months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(
                          month,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newMonth) {
                  if (newMonth != null) {
                    ref
                        .read(selectedYearMonthProvider.notifier)
                        .select(newMonth);
                  }
                },
              ),
            ),
          ),
          _CompactArrowButton(
            icon: Icons.chevron_right,
            enabled: canGoNext,
            onTap:
                canGoNext
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

class _CompactArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _CompactArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 36,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.black87 : Colors.black26,
          ),
        ),
      ),
    );
  }
}