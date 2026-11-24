import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/widgets/jtext.dart';
import '../../../../../core/widgets/monthly_return_rate_chart_dialog.dart';
import '../../../../../models/account/account_name.dart';
import '../../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class MonthlyPensionAccountSummaryList extends ConsumerWidget {
  final List<dynamic> pensionAccounts;
  final Map<String?, AccountName?> accountNameMap;
  final Map<String, MonthlyPensionAccountBalance> accountBalanceMap;
  final String? selectedAccountId;
  final String targetMonth;
  final Function(
    String accId,
    String displayName,
    MonthlyPensionAccountBalance? currentBal,
  )?
  onEditPressed;

  const MonthlyPensionAccountSummaryList({
    super.key,
    required this.pensionAccounts,
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
    if (pensionAccounts.isEmpty) {
      return const Text(
        '등록된 연금 계좌가 없습니다.',
        style: TextStyle(color: Colors.grey),
      );
    }

    final displayAccounts =
        selectedAccountId == null
            ? pensionAccounts
            : pensionAccounts.where((a) => a.id == selectedAccountId).toList();

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
        final String? logoUrl = acc.logoUrl as String?;

        final accBalanceData = accountBalanceMap[accId];
        final cash = accBalanceData?.cashBalance ?? 0.0;
        final monthlyWith = accBalanceData?.monthlyWithdrawal ?? 0.0;
        final totalWith = accBalanceData?.totalWithdrawal ?? 0.0;

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
                        final allBalances =
                            dialogRef
                                .watch(allMonthlyPensionBalancesProvider)
                                .value ??
                            [];
                        final items = allBalances.where(
                          (b) =>
                              b.balanceItem.yearMonth == ym &&
                              b.balanceItem.accountId == accId,
                        );
                        final productBal = items.fold<double>(
                          0.0,
                          (sum, item) => sum + item.balanceItem.balance,
                        );
                        final accBalList =
                            dialogRef
                                .watch(monthlyPensionAccountBalanceProvider(ym))
                                .value ??
                            [];
                        final accBal = accBalList.firstWhereOrNull(
                          (ab) => ab.accountId == accId,
                        );
                        final cashBal = accBal?.cashBalance ?? 0.0;
                        final withdrawal = accBal?.totalWithdrawal ?? 0.0;
                        final totalPrin =
                            accBal != null && accBal.principal > 0
                                ? accBal.principal
                                : items.fold<double>(
                                  0.0,
                                  (sum, item) =>
                                      sum + item.balanceItem.principal,
                                );
                        if (totalPrin <= 0) return 0.0;
                        final profit =
                            (productBal + cashBal + withdrawal) - totalPrin;
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
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            JText(
                              '현금: ${cash.toWon()}',
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
                              '당월 인출: ${monthlyWith.toWon()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            JText(
                              '(누적: ${totalWith.toWon()})',
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
