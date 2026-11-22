import 'package:flutter/material.dart';

class MonthAccountSelectorItem {
  final String? value;
  final String label;
  final String? logoUrl;
  final bool isBold;

  const MonthAccountSelectorItem({
    required this.value,
    required this.label,
    this.logoUrl,
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

  Widget _buildAccountRow({
    required BuildContext context,
    required String label,
    String? logoUrl,
    bool isBold = false,
    bool isAllAccounts = false,
  }) {
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Row(
      children: [
        if (hasLogo)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              logoUrl,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(
                      Icons.account_balance,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
            ),
          )
        else if (isAllAccounts)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 15,
              color: Theme.of(context).primaryColor,
            ),
          )
        else
          const SizedBox(
            width: 22,
            height: 22,
            child: Icon(
              Icons.account_balance,
              size: 18,
              color: Colors.grey,
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeMonthValue =
        months.contains(currentMonth) ? currentMonth : months.first;

    final isValidAccount =
        selectedAccountValue == null ||
        accountItems.any((item) => item.value == selectedAccountValue);
    final safeAccountValue = isValidAccount ? selectedAccountValue : null;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: safeMonthValue,
                isExpanded: true,
                items:
                    months
                        .map(
                          (ym) => DropdownMenuItem<String>(
                            value: ym,
                            child: Text(
                              ym,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
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
          flex: 3,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: safeAccountValue,
                isExpanded: true,
                hint: _buildAccountRow(
                  context: context,
                  label: allAccountsLabel,
                  isBold: true,
                  isAllAccounts: true,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: _buildAccountRow(
                      context: context,
                      label: allAccountsLabel,
                      isBold: true,
                      isAllAccounts: true,
                    ),
                  ),
                  ...accountItems.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.value,
                      child: _buildAccountRow(
                        context: context,
                        label: item.label,
                        logoUrl: item.logoUrl,
                        isBold: item.isBold,
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