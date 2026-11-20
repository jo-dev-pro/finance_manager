import 'package:flutter/material.dart';

class MonthAccountSelectorItem {
  final String? value;
  final String label;
  final bool isBold;

  const MonthAccountSelectorItem({
    required this.value,
    required this.label,
    this.isBold = false,
  });
}

class MonthAccountSelectorHeader extends StatelessWidget {
  final List<String> months;
  final String currentMonth;
  final ValueChanged<String> onMonthChanged;

  final String? selectedAccountValue;
  final List<MonthAccountSelectorItem> accountItems;
  final ValueChanged<String?> onAccountChanged;
  final String allAccountsLabel;

  const MonthAccountSelectorHeader({
    super.key,
    required this.months,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.selectedAccountValue,
    required this.accountItems,
    required this.onAccountChanged,
    this.allAccountsLabel = '전체 계좌',
  });

  @override
  Widget build(BuildContext context) {
    final safeMonthValue =
        months.contains(currentMonth) ? currentMonth : months.first;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeMonthValue,
                isExpanded: true,
                items: months
                    .map(
                      (ym) => DropdownMenuItem<String>(
                        value: ym,
                        child: Text(
                          ym,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) onMonthChanged(val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedAccountValue,
                isExpanded: true,
                hint: Text(allAccountsLabel),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      allAccountsLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...accountItems.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.value,
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              item.isBold ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: onAccountChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}