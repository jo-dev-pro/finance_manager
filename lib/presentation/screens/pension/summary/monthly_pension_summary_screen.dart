import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/jtext.dart';
import '../../../../core/widgets/main_appbar.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../core/widgets/month_account_selector_header.dart';
import '../../../../core/widgets/monthly_evaluation_summary_card.dart';
import '../../../../core/widgets/monthly_return_rate_chart_dialog.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../monthly_data/monthly_pension_balance_screen.dart';
import 'widgets/monthly_pension_account_summary_list.dart';

class MonthlyPensionSummaryScreen extends ConsumerWidget {
  final Object? extra;

  const MonthlyPensionSummaryScreen({super.key, this.extra});

  String _getLastYearMonth(String currentYearMonth) {
    try {
      final parts = currentYearMonth.split('-');
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final DateTime lastMonthDate = DateTime(year, month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return currentYearMonth;
    }
  }

  Widget _buildAccountLogoAndName({
    required String? logoUrl,
    required String accountName,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logoUrl != null && logoUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              logoUrl,
              width: 16,
              height: 16,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Icon(
                    Icons.account_balance,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
            ),
          )
        else
          Icon(Icons.account_balance, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            accountName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? initialAccountId;

    if (extra is Map<String, dynamic>) {
      initialAccountId =
          (extra as Map<String, dynamic>)['accountId'] as String?;
    }

    if (initialAccountId != null) {
      final currentFilter = ref.read(selectedPensionAccountFilterProvider);
      if (currentFilter == null) {
        Future.microtask(() {
          ref.read(selectedPensionAccountFilterProvider.notifier).state =
              initialAccountId;
        });
      }
    }

    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final selectedAccountId = ref.watch(selectedPensionAccountFilterProvider);

    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: const MainAppBar(titleText: '연금 월말평가'),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 연금 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

          final lastMonth = _getLastYearMonth(activeCurrentMonth);

          final items =
              ref
                  .watch(
                    monthlyPensionBalanceNotifierProvider(activeCurrentMonth),
                  )
                  .value ??
              [];
          final lastItems =
              ref
                  .watch(monthlyPensionBalanceNotifierProvider(lastMonth))
                  .value ??
              [];

          final accountBalances =
              ref
                  .watch(
                    monthlyPensionAccountBalanceNotifierProvider(
                      activeCurrentMonth,
                    ),
                  )
                  .value ??
              [];
          final lastAccountBalances =
              ref
                  .watch(
                    monthlyPensionAccountBalanceNotifierProvider(lastMonth),
                  )
                  .value ??
              [];

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final products = productsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final productMap = {for (var p in products) p.id!: p.productName};
          final accountBalanceMap = {
            for (var ab in accountBalances) ab.accountId: ab,
          };

          final pensionAccounts =
              accounts
                  .where(
                    (a) => a.accountType.trim() == '연금' && a.status == '활동',
                  )
                  .toList();

          final isValidAccountId =
              selectedAccountId == null ||
              pensionAccounts.any((acc) => acc.id == selectedAccountId);
          final currentDropdownValue =
              isValidAccountId ? selectedAccountId : null;

          final filteredAccountBalances =
              currentDropdownValue == null
                  ? accountBalances
                  : accountBalances
                      .where((ab) => ab.accountId == currentDropdownValue)
                      .toList();

          final filteredPensionItems =
              currentDropdownValue == null
                  ? items
                  : items
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          final lastFilteredAccountBalances =
              currentDropdownValue == null
                  ? lastAccountBalances
                  : lastAccountBalances
                      .where((ab) => ab.accountId == currentDropdownValue)
                      .toList();

          final lastFilteredPensionItems =
              currentDropdownValue == null
                  ? lastItems
                  : lastItems
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          double totalPensionBalance = 0;
          double totalPensionPrincipal = 0;
          double totalCashBalance = 0;
          double totalMonthlyWithdrawal = 0;
          double totalCumulativeWithdrawal = 0;

          for (var b in filteredPensionItems) {
            totalPensionBalance += b.balance;
          }

          for (var ab in filteredAccountBalances) {
            totalCashBalance += ab.cashBalance;
            totalMonthlyWithdrawal += ab.monthlyWithdrawal;
            totalCumulativeWithdrawal += ab.totalWithdrawal;
            totalPensionPrincipal += ab.principal;
          }

          final grandTotalBalance = totalPensionBalance + totalCashBalance;
          final totalProfit =
              (grandTotalBalance + totalCumulativeWithdrawal) -
              totalPensionPrincipal;
          final totalReturnRate =
              totalPensionPrincipal > 0
                  ? (totalProfit / totalPensionPrincipal) * 100
                  : 0.0;

          final lastTotalPensionBalance = lastFilteredPensionItems.fold<double>(
            0.0,
            (sum, item) => sum + item.balance,
          );
          final lastTotalCashBalance = lastFilteredAccountBalances.fold<double>(
            0.0,
            (sum, ab) => sum + ab.cashBalance,
          );
          final lastGrandTotalBalance =
              lastTotalPensionBalance + lastTotalCashBalance;
          final summaryDiffFromLastMonth =
              grandTotalBalance - lastGrandTotalBalance;

          final accountFilterItems =
              pensionAccounts.map((account) {
                final accId = account.id ?? '';
                final nameObj = accountNameMap[account.accountNameId];
                final accName = nameObj?.accountName ?? '계좌';
                return MonthAccountSelectorItem(
                  value: accId,
                  label: accName,
                  logoUrl: account.logoUrl,
                );
              }).toList();

          return MainConstrainedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthAccountSelectorHeader(
                    months: months,
                    currentMonth: activeCurrentMonth,
                    onMonthChanged:
                        (val) => ref
                            .read(selectedYearMonthProvider.notifier)
                            .select(val),
                    selectedAccountValue: currentDropdownValue,
                    accountItems: accountFilterItems,
                    onAccountChanged:
                        (val) =>
                            ref
                                .read(
                                  selectedPensionAccountFilterProvider.notifier,
                                )
                                .state = val,
                  ),
                  const SizedBox(height: 16),

                  MonthlyEvaluationSummaryCard(
                    title: '연금 월말평가',
                    totalBalanceText: grandTotalBalance.round().toWon(),
                    principalText: totalPensionPrincipal.round().toWon(),
                    profitLossRowWidget: Row(
                      children: [
                        totalProfit.round().toSignedPriceText(
                          isDarkCard: true,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        totalReturnRate.toSignedPercentText(
                          isDarkCard: true,
                          withParentheses: true,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    detailMetrics: [
                      EvaluationMetric(
                        label: '현금잔액',
                        value: totalCashBalance.round().toWon(),
                      ),
                      EvaluationMetric(
                        label: '당월 인출',
                        value: totalMonthlyWithdrawal.round().toWon(),
                      ),
                      EvaluationMetric(
                        label: '누적 인출',
                        value: totalCumulativeWithdrawal.round().toWon(),
                      ),
                    ],
                    diffFromLastMonthWidget: summaryDiffFromLastMonth
                        .round()
                        .toSignedPriceText(
                          isDarkCard: true,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),

                  const SizedBox(height: 12),
                  const SectionTitle('계좌별 현금 및 자금 요약'),

                  MonthlyPensionAccountSummaryList(
                    pensionAccounts: pensionAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    selectedAccountId: currentDropdownValue,
                    targetMonth: activeCurrentMonth,
                    onEditPressed: null,
                  ),

                  const SizedBox(height: 12),
                  const SectionTitle('보유 상품별 월말 내역'),

                  if (filteredPensionItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          '$activeCurrentMonth에 등록된 연금 월말 데이터가 없습니다.',
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPensionItems.length,
                      itemBuilder: (context, index) {
                        final balanceItem = filteredPensionItems[index];
                        final matchedAcc = accountMap[balanceItem.accountId];
                        final nameObj =
                            matchedAcc != null
                                ? accountNameMap[matchedAcc.accountNameId]
                                : null;
                        final accountName = nameObj?.accountName ?? '연금계좌';
                        final String displayName =
                            productMap[balanceItem.productId] ?? '알 수 없는 상품';
                        final lastBalanceItem = lastItems.firstWhereOrNull(
                          (item) =>
                              item.accountId == balanceItem.accountId &&
                              item.productId == balanceItem.productId,
                        );
                        final lastBalance = lastBalanceItem?.balance ?? 0.0;
                        final diffFromLastMonth =
                            balanceItem.balance - lastBalance;
                        final double returnRate = balanceItem.returnRate;
                        final double monthlySale = balanceItem.monthlySale;
                        final double totalSale = balanceItem.totalSale;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap:
                                () => MonthlyReturnRateChartDialog.show(
                                  context,
                                  titleText: '$displayName 월별 수익률 (%)',
                                  accountName: accountName,
                                  logoUrl: matchedAcc?.logoUrl,
                                  rateCalculator: (dialogRef, ym) {
                                    final allBalances =
                                        dialogRef
                                            .watch(
                                              allMonthlyPensionBalancesProvider,
                                            )
                                            .value ??
                                        [];
                                    final matchedItems = allBalances.where(
                                      (b) =>
                                          b.balanceItem.yearMonth == ym &&
                                          b.balanceItem.accountId ==
                                              balanceItem.accountId &&
                                          b.balanceItem.productId ==
                                              balanceItem.productId,
                                    );
                                    final totalBal = matchedItems.fold<double>(
                                      0.0,
                                      (sum, item) =>
                                          sum + item.balanceItem.balance,
                                    );
                                    final totalPrin = matchedItems.fold<double>(
                                      0.0,
                                      (sum, item) =>
                                          sum + item.balanceItem.principal,
                                    );
                                    if (totalPrin <= 0) return 0.0;
                                    return ((totalBal - totalPrin) /
                                            totalPrin) *
                                        100;
                                  },
                                ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: _buildAccountLogoAndName(
                                          logoUrl: matchedAcc?.logoUrl,
                                          accountName: accountName,
                                        ),
                                      ),
                                      if (balanceItem.purchaseDate != null &&
                                          balanceItem
                                              .purchaseDate!
                                              .isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '매수일: ${balanceItem.purchaseDate}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.indigo.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: JText(
                                            '평가액: ${balanceItem.balance.toWon()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: JText(
                                            '원금: ${balanceItem.principal.toWon()}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: JText(
                                              '당월 매도: ${monthlySale.toWon()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: JText(
                                              '누적 매도: ${totalSale.toWon()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.teal.shade900,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 16,
                                    color: Colors.black12,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '수익률: ',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              returnRate.toSignedPercentText(
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                withParentheses: false,
                                              ),
                                              const SizedBox(width: 6),
                                              JText(
                                                '(연환산: ${balanceItem.annualizedReturnRate.toSignedPercent()})',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '전월 대비: ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              diffFromLastMonth
                                                  .toSignedPriceText(
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
