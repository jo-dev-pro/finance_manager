import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/jtext.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class PensionPortionSection extends ConsumerWidget {
  final String currentMonth;
  final List<Color> chartColors;

  const PensionPortionSection({
    super.key,
    required this.currentMonth,
    required this.chartColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances =
        ref.watch(monthlyPensionBalanceNotifierProvider(currentMonth)).value ??
            [];
    final accountBalances = ref
            .watch(monthlyPensionAccountBalanceNotifierProvider(currentMonth))
            .value ??
        [];
    final accounts = ref.watch(accountNotifierProvider).value ?? [];
    final accountNames = ref.watch(accountNameNotifierProvider).value ?? [];

    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    final Map<String, List<MonthlyPensionBalance>> accountGroups = {};
    for (var item in balances) {
      accountGroups.putIfAbsent(item.accountId, () => []).add(item);
    }
    for (var ab in accountBalances) {
      accountGroups.putIfAbsent(ab.accountId, () => []);
    }

    if (accountGroups.isEmpty) {
      return const SizedBox.shrink();
    }

    final accountIds = accountGroups.keys.toList();
    final accountCashMap = {
      for (var ab in accountBalances) ab.accountId: ab.cashBalance,
    };

    final totalProductSum = balances.fold<double>(
      0.0,
      (s, i) => s + i.balance,
    );
    final totalCashSum = accountBalances.fold<double>(
      0.0,
      (s, i) => s + i.cashBalance,
    );
    final overallTotalBalance = totalProductSum + totalCashSum;

    return Card(
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
                  JText(
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