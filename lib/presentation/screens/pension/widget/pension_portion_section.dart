import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/account/account.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';

class PensionPortionSection extends StatelessWidget {
  final List<String> accountIds;
  final Map<String, List<MonthlyPensionBalance>> accountGroups;
  final Map<String, double> accountCashMap;
  final List<Account> accounts;
  final List<dynamic> accountNames;
  final double overallTotalBalance;
  final List<Color> chartColors;

  const PensionPortionSection({
    super.key,
    required this.accountIds,
    required this.accountGroups,
    required this.accountCashMap,
    required this.accounts,
    required this.accountNames,
    required this.overallTotalBalance,
    required this.chartColors,
  });

  @override
  Widget build(BuildContext context) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: accountIds.asMap().entries.map((entry) {
            final index = entry.key;
            final accId = entry.value;
            final items = accountGroups[accId] ?? [];

            final productSum = items.fold<double>(
              0.0,
              (s, item) => s + item.balance,
            );
            final cashBal = accountCashMap[accId] ?? 0.0;
            final accountTotal = productSum + cashBal;

            final ratio = overallTotalBalance > 0
                ? (accountTotal / overallTotalBalance) * 100
                : 0.0;

            final matchedAcc = accountMap[accId];
            final matchedAccountName = matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;
            final accountName = matchedAccountName?.accountName ?? accId;
            final logoUrl = matchedAcc?.logoUrl;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: chartColors[index % chartColors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        if (logoUrl != null && logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              logoUrl,
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.account_balance,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.account_balance,
                            size: 16,
                            color: Colors.indigo,
                          ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            accountName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${accountTotal.toWon()} (${ratio.toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}