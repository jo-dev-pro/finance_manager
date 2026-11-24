import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';

class StockPortionSection extends ConsumerWidget {
  final String currentMonth;
  final List<Color> chartColors;

  const StockPortionSection({
    super.key,
    required this.currentMonth,
    required this.chartColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 필요한 데이터를 위젯 내부에서 직접 구독
    final balances =
        ref.watch(monthlyStockBalanceProvider(currentMonth)).value ?? [];
    final accountBalances =
        ref.watch(monthlyStockAccountBalanceProvider(currentMonth)).value ?? [];
    final accounts = ref.watch(accountProvider).value ?? [];
    final accountNames = ref.watch(accountNameProvider).value ?? [];

    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    final accountExchangeRateMap = {
      for (var ab in accountBalances)
        ab.accountId:
            ((accountMap[ab.accountId]?.isForeignCurrency ?? false) &&
                    ab.exchangeRate > 0)
                ? ab.exchangeRate
                : 1.0,
    };
    final accountCashMap = {
      for (var ab in accountBalances) ab.accountId: ab.cashBalance,
    };

    final Map<String, List<MonthlyStockBalance>> accountGroups = {};
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

    // 전체 비중 계산용 총합 (종목 + 예수금 환율 반영)
    double calcTotalStock = 0;
    double calcTotalCash = 0;
    for (var item in balances) {
      final rate = accountExchangeRateMap[item.accountId] ?? 1.0;
      calcTotalStock += item.balance * rate;
    }
    for (var ab in accountBalances) {
      final rate = accountExchangeRateMap[ab.accountId] ?? 1.0;
      calcTotalCash += ab.cashBalance * rate;
    }
    final overallTotalBalance =
        (calcTotalStock + calcTotalCash).roundToDouble();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              accountIds.asMap().entries.map((entry) {
                final index = entry.key;
                final accId = entry.value;
                final items = accountGroups[accId] ?? [];

                final exchangeRate = accountExchangeRateMap[accId] ?? 1.0;
                final cashBal = (accountCashMap[accId] ?? 0.0) * exchangeRate;
                final rawBal = items.fold<double>(
                  0.0,
                  (sum, item) => sum + item.balance,
                );
                final accountTotal = (rawBal * exchangeRate) + cashBal;

                final ratio =
                    overallTotalBalance > 0
                        ? (accountTotal / overallTotalBalance) * 100
                        : 0.0;

                final matchedAcc = accountMap[accId];
                final matchedAccountName =
                    matchedAcc != null
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
                                  width: 25,
                                  height: 25,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
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
                        '${accountTotal.round().toWon()} (${ratio.toStringAsFixed(1)}%)',
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
