import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/account/account_name.dart';
import '../../../../models/monthly_data/monthly_stock_account_balance.dart';

class MonthlyStockAccountSummaryList extends ConsumerWidget {
  final List<dynamic> stockAccounts;
  final Map<String?, AccountName?> accountNameMap;
  final Map<String, MonthlyStockAccountBalance> accountBalanceMap;
  final String? selectedAccountId;
  final String targetMonth;
  final void Function(
    String accountId,
    String accountDisplayName,
    MonthlyStockAccountBalance? currentBalance,
  ) onEditPressed;

  const MonthlyStockAccountSummaryList({
    super.key,
    required this.stockAccounts,
    required this.accountNameMap,
    required this.accountBalanceMap,
    required this.selectedAccountId,
    required this.targetMonth,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stockAccounts.isEmpty) {
      return const Text('등록된 증권 계좌가 없습니다.', style: TextStyle(color: Colors.grey));
    }

    final displayAccounts = selectedAccountId == null
        ? stockAccounts
        : stockAccounts.where((a) => a.id == selectedAccountId).toList();

    if (displayAccounts.isEmpty) {
      return const Text('해당 계좌 정보가 없습니다.', style: TextStyle(color: Colors.grey));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayAccounts.length,
      itemBuilder: (context, index) {
        final acc = displayAccounts[index];
        final accId = acc.id ?? '';
        final nameObj = accountNameMap[acc.accountNameId];
        final accName = nameObj?.accountName ?? '계좌';
        final institution = acc.financialInstitution;

        final isOverseasAccount = acc.isForeignCurrency;

        final accBalanceData = accountBalanceMap[accId];
        final cash = accBalanceData?.cashBalance ?? 0.0;
        final monthlyWith = accBalanceData?.monthlyWithdrawal ?? 0.0;
        final totalWith = accBalanceData?.totalWithdrawal ?? 0.0;
        final exchangeRate = accBalanceData?.exchangeRate ?? 1.0;

        final cashStr = isOverseasAccount ? cash.toUSD() : cash.toWon();
        final monthlyWithStr = isOverseasAccount ? monthlyWith.toUSD() : monthlyWith.toWon();
        final totalWithStr = isOverseasAccount ? totalWith.toUSD() : totalWith.toWon();

        return Card(
          elevation: 1.0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$institution -$accName',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (isOverseasAccount && exchangeRate > 1.0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(환율: ${exchangeRate.toCommaString()})',
                              style: TextStyle(fontSize: 11, color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '현금성 잔액: $cashStr',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 8),
                          Text('|', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                          const SizedBox(width: 8),
                          Text(
                            '당월 인출: $monthlyWithStr',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(누적: $totalWithStr)',
                            style: TextStyle(fontSize: 11, color: Colors.indigo.shade600, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.indigo),
                  onPressed: () => onEditPressed(
                    accId,
                    '$institution$accName',
                    accBalanceData,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}