import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/widgets/jtext.dart';
import '../../../../../core/widgets/monthly_return_rate_chart_dialog.dart';
import '../../../../../models/account/account_name.dart';
import '../../../../../models/monthly_data/monthly_stock_account_balance.dart';
import '../../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../../providers/monthly_data/monthly_stock_balance_provider.dart';

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
  )?
  onEditPressed;

  const MonthlyStockAccountSummaryList({
    super.key,
    required this.stockAccounts,
    required this.accountNameMap,
    required this.accountBalanceMap,
    required this.selectedAccountId,
    required this.targetMonth,
    this.onEditPressed,
  });

  Widget _buildAccountLogo(String? logoUrl, {double size = 18}) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.account_balance,
                size: size - 2,
                color: Colors.grey.shade600,
              ),
        ),
      );
    }
    return Icon(
      Icons.account_balance,
      size: size - 2,
      color: Colors.grey.shade600,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stockAccounts.isEmpty) {
      return const Text(
        '등록된 증권 계좌가 없습니다.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final displayAccounts =
        selectedAccountId == null
            ? stockAccounts
            : stockAccounts.where((a) => a.id == selectedAccountId).toList();

    if (displayAccounts.isEmpty) {
      return const Text(
        '해당 계좌 정보가 없습니다.',
        style: TextStyle(color: Colors.grey),
      );
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
        final String? logoUrl = acc?.logoUrl as String?;

        final isOverseasAccount = acc.isForeignCurrency == true;

        final accBalanceData = accountBalanceMap[accId];
        final cash = accBalanceData?.cashBalance ?? 0.0;
        final monthlyWith = accBalanceData?.monthlyWithdrawal ?? 0.0;
        final totalWith = accBalanceData?.totalWithdrawal ?? 0.0;
        final exchangeRate = accBalanceData?.exchangeRate ?? 1.0;

        final cashStr = isOverseasAccount ? cash.toUSD() : cash.toWon();
        final monthlyWithStr =
            isOverseasAccount ? monthlyWith.toUSD() : monthlyWith.toWon();
        final totalWithStr =
            isOverseasAccount ? totalWith.toUSD() : totalWith.toWon();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap:
                accId.isEmpty
                    ? null
                    : () => MonthlyReturnRateChartDialog.show(
                      context,
                      titleText: '$accName 월별 수익률 (%)',
                      accountName: accName,
                      logoUrl: logoUrl,
                      showAccountLogoInTitleRow: true,
                      rateCalculator: (dialogRef, ym) {
                        final stockItems =
                            dialogRef
                                .watch(monthlyStockBalanceNotifierProvider(ym))
                                .value ??
                            [];
                        final accBalList =
                            dialogRef
                                .watch(
                                  monthlyStockAccountBalanceNotifierProvider(
                                    ym,
                                  ),
                                )
                                .value ??
                            [];
                        final accBal = accBalList.firstWhereOrNull(
                          (ab) => ab.accountId == accId,
                        );
                        final rate =
                            (isOverseasAccount &&
                                    accBal != null &&
                                    accBal.exchangeRate > 0)
                                ? accBal.exchangeRate
                                : 1.0;
                        final matchedStockItems = stockItems.where(
                          (item) => item.accountId == accId,
                        );
                        final stockEvalKrw = matchedStockItems.fold<double>(
                          0.0,
                          (sum, item) => sum + (item.balance * rate),
                        );
                        final payoutKrw = matchedStockItems.fold<double>(
                          0.0,
                          (sum, item) => sum + (item.totalPayout * rate),
                        );
                        final cashKrw = (accBal?.cashBalance ?? 0.0) * rate;
                        final withdrawalKrw =
                            (accBal?.totalWithdrawal ?? 0.0) * rate;
                        final totalPrin = accBal?.principal ?? 0.0;
                        if (totalPrin <= 0) return 0.0;
                        final profit =
                            (stockEvalKrw +
                                cashKrw +
                                payoutKrw +
                                withdrawalKrw) -
                            totalPrin;
                        return (profit / totalPrin) * 100;
                      },
                    ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAccountLogo(logoUrl),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                accName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isOverseasAccount && exchangeRate > 1.0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(환율: ${exchangeRate.toCommaString()})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            JText(
                              '현금: $cashStr',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '|',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            JText(
                              '당월 인출: $monthlyWithStr',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            JText(
                              '(누적: $totalWithStr)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.indigo.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onEditPressed != null)
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.indigo,
                      ),
                      onPressed:
                          () => onEditPressed!(accId, accName, accBalanceData),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
