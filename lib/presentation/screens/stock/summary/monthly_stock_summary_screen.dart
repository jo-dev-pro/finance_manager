import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_extension.dart';
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
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';
import '../../../../providers/stock/stock_provider.dart';
import 'widgets/monthly_stock_account_summary_list.dart';

class MonthlyStockSummaryScreen extends ConsumerStatefulWidget {
  final Object? extra;

  const MonthlyStockSummaryScreen({super.key, this.extra});

  @override
  ConsumerState<MonthlyStockSummaryScreen> createState() =>
      _MonthlyStockSummaryScreenState();
}

class _MonthlyStockSummaryScreenState
    extends ConsumerState<MonthlyStockSummaryScreen> {
  bool _initializedFromExtra = false;
  String? _initialMonth;

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
              width: 18,
              height: 18,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Icon(
                    Icons.account_balance,
                    size: 15,
                    color: Colors.grey.shade600,
                  ),
            ),
          )
        else
          Icon(Icons.account_balance, size: 15, color: Colors.grey.shade600),
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
  void initState() {
    super.initState();

    String? initialAccountId;
    if (widget.extra is Map<String, dynamic>) {
      final map = widget.extra as Map<String, dynamic>;
      _initialMonth = map['yearMonth'] as String?;
      initialAccountId = map['accountId'] as String?;
    } else if (widget.extra is String) {
      _initialMonth = widget.extra as String;
    }

    if (initialAccountId != null) {
      Future.microtask(() {
        if (!mounted || _initializedFromExtra) return;
        _initializedFromExtra = true;
        ref
            .read(selectedStockAccountFilterProvider.notifier)
            .setFilter(initialAccountId);
      });
    } else {
      _initializedFromExtra = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final selectedAccountId = ref.watch(selectedStockAccountFilterProvider);

    final accountsAsync = ref.watch(accountProvider);
    final accountNamesAsync = ref.watch(accountNameProvider);
    final stockItemsAsync = ref.watch(stockItemProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: const MainAppBar(titleText: '주식 월말평가'),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 주식 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : (_initialMonth != null && months.contains(_initialMonth))
                  ? _initialMonth!
                  : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              if (!mounted) return;
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

          final lastMonth = _getLastYearMonth(activeCurrentMonth);

          final items =
              ref
                  .watch(monthlyStockBalanceProvider(activeCurrentMonth))
                  .value ??
              [];
          final lastItems =
              ref.watch(monthlyStockBalanceProvider(lastMonth)).value ?? [];

          final accountBalances =
              ref
                  .watch(monthlyStockAccountBalanceProvider(activeCurrentMonth))
                  .value ??
              [];
          final lastAccountBalances =
              ref.watch(monthlyStockAccountBalanceProvider(lastMonth)).value ??
              [];

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};
          final accountBalanceMap = {
            for (var ab in accountBalances) ab.accountId: ab,
          };

          final stockAccounts =
              accounts
                  .where(
                    (a) => a.accountType.trim() == '증권' && a.status == '활동',
                  )
                  .toList();

          final isValidAccountId =
              selectedAccountId == null ||
              stockAccounts.any((acc) => acc.id == selectedAccountId);
          final currentDropdownValue =
              isValidAccountId ? selectedAccountId : null;

          final selectedAcc =
              currentDropdownValue != null
                  ? accountMap[currentDropdownValue]
                  : null;
          final isSingleOverseasAccount =
              selectedAcc?.isForeignCurrency ?? false;

          final filteredAccountBalances =
              currentDropdownValue == null
                  ? accountBalances
                  : accountBalances
                      .where((ab) => ab.accountId == currentDropdownValue)
                      .toList();

          final filteredStockItems =
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

          final lastFilteredStockItems =
              currentDropdownValue == null
                  ? lastItems
                  : lastItems
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          final exchangeRateMap = {
            for (var ab in accountBalances)
              ab.accountId:
                  ((accountMap[ab.accountId]?.isForeignCurrency ?? false) &&
                          ab.exchangeRate > 0)
                      ? ab.exchangeRate
                      : 1.0,
          };
          final lastExchangeRateMap = {
            for (var lab in lastAccountBalances)
              lab.accountId:
                  ((accountMap[lab.accountId]?.isForeignCurrency ?? false) &&
                          lab.exchangeRate > 0)
                      ? lab.exchangeRate
                      : 1.0,
          };

          double totalStockBalance = 0;
          double totalPrincipal = 0;
          double totalCashBalance = 0;
          double totalPayout = 0;
          double totalCumulativeWithdrawal = 0;

          double rawForeignStockBalance = 0;
          double rawForeignCashBalance = 0;

          final List<double> appliedExchangeRates = [];

          for (var item in filteredStockItems) {
            final rate = exchangeRateMap[item.accountId] ?? 1.0;
            totalStockBalance += item.balance * rate;
            totalPayout += item.totalPayout * rate;
            if (isSingleOverseasAccount) {
              rawForeignStockBalance += item.balance;
            }
          }

          for (var ab in filteredAccountBalances) {
            final rate = exchangeRateMap[ab.accountId] ?? 1.0;
            totalCashBalance += ab.cashBalance * rate;
            totalPrincipal += ab.principal;
            totalCumulativeWithdrawal += ab.totalWithdrawal * rate;

            if (isSingleOverseasAccount) {
              rawForeignCashBalance += ab.cashBalance;
            }

            if ((accountMap[ab.accountId]?.isForeignCurrency ?? false) &&
                ab.exchangeRate > 1.0) {
              appliedExchangeRates.add(ab.exchangeRate);
            }
          }

          String? exchangeBadgeText;
          if (appliedExchangeRates.isNotEmpty) {
            final uniqueRates =
                appliedExchangeRates.map((r) => r.toStringAsFixed(2)).toSet();
            exchangeBadgeText =
                uniqueRates.length == 1
                    ? '환율: ${uniqueRates.first}원'
                    : '환율: ${uniqueRates.join(' / ')}원';
          }

          final grandTotalBalance = totalStockBalance + totalCashBalance;
          final rawForeignGrandTotal =
              rawForeignStockBalance + rawForeignCashBalance;

          final totalBalanceDisplayText =
              isSingleOverseasAccount
                  ? '${grandTotalBalance.toCurrency(isForeign: false)} (${rawForeignGrandTotal.toCurrency(isForeign: true)})'
                  : grandTotalBalance.toCurrency(isForeign: false);

          final totalProfit =
              (grandTotalBalance + totalPayout + totalCumulativeWithdrawal) -
              totalPrincipal;
          final totalReturnRate =
              totalPrincipal > 0 ? (totalProfit / totalPrincipal) * 100 : 0.0;

          final lastTotalStockBalance = lastFilteredStockItems.fold<double>(
            0.0,
            (sum, item) =>
                sum +
                (item.balance * (lastExchangeRateMap[item.accountId] ?? 1.0)),
          );
          final lastTotalCashBalance = lastFilteredAccountBalances.fold<double>(
            0.0,
            (sum, ab) =>
                sum +
                (ab.cashBalance * (lastExchangeRateMap[ab.accountId] ?? 1.0)),
          );
          final lastGrandTotalBalance =
              lastTotalStockBalance + lastTotalCashBalance;
          final summaryDiffFromLastMonth =
              grandTotalBalance - lastGrandTotalBalance;

          final accountFilterItems =
              stockAccounts.map((account) {
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
                        (val) => ref
                            .read(selectedStockAccountFilterProvider.notifier)
                            .setFilter(val),
                  ),
                  const SizedBox(height: 16),

                  MonthlyEvaluationSummaryCard(
                    title: '주식 월말평가',
                    badgeText: exchangeBadgeText,
                    totalBalanceText: totalBalanceDisplayText,
                    principalText: totalPrincipal.toCurrency(isForeign: false),
                    profitLossRowWidget: Row(
                      children: [
                        totalProfit.toSignedCurrencyText(
                          isForeign: false,
                          isDarkCard: true,
                          style: TextStyle(
                            fontSize: context.isMobile ? 14 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        totalReturnRate.toSignedPercentText(
                          isDarkCard: true,
                          withParentheses: true,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    detailMetrics: [
                      EvaluationMetric(
                        label: '현금잔액',
                        value: totalCashBalance.toCurrency(isForeign: false),
                      ),
                      EvaluationMetric(
                        label: '누적 배당',
                        value: totalPayout.toCurrency(isForeign: false),
                      ),
                      EvaluationMetric(
                        label: '누적 인출',
                        value: totalCumulativeWithdrawal.toCurrency(
                          isForeign: false,
                        ),
                      ),
                    ],
                    diffFromLastMonthWidget: summaryDiffFromLastMonth
                        .toSignedCurrencyText(
                          isForeign: false,
                          isDarkCard: true,
                          style: TextStyle(
                            fontSize: context.isMobile ? 13 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),

                  const SizedBox(height: 12),
                  const SectionTitle('계좌별 현금 및 자금 요약'),

                  MonthlyStockAccountSummaryList(
                    stockAccounts: stockAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    selectedAccountId: currentDropdownValue,
                    targetMonth: activeCurrentMonth,
                    onEditPressed: null,
                  ),

                  const SizedBox(height: 12),
                  const SectionTitle('보유 종목별 월말 내역'),

                  if (filteredStockItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          '$activeCurrentMonth에 등록된 주식 월말 데이터가 없습니다.',
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStockItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredStockItems[index];
                        final matchedAcc = accountMap[item.accountId];
                        final nameObj =
                            matchedAcc != null
                                ? accountNameMap[matchedAcc.accountNameId]
                                : null;
                        final accountName = nameObj?.accountName ?? '주식계좌';
                        final isForeign =
                            matchedAcc?.isForeignCurrency ?? false;

                        final stock = stockItemMap[item.stockItemId];
                        final stockNameOnly = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode ?? '';
                        final displayName =
                            stockCode.isNotEmpty
                                ? '$stockNameOnly ($stockCode)'
                                : stockNameOnly;

                        final lastItem = lastItems.firstWhereOrNull(
                          (prev) =>
                              prev.accountId == item.accountId &&
                              prev.stockItemId == item.stockItemId,
                        );
                        final lastBalance = lastItem?.balance ?? 0.0;
                        final diffFromLastMonth = item.balance - lastBalance;

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
                                    final monthItems =
                                        dialogRef
                                            .watch(
                                              monthlyStockBalanceProvider(ym),
                                            )
                                            .value ??
                                        [];
                                    final matchedItems = monthItems.where(
                                      (prev) =>
                                          prev.accountId == item.accountId &&
                                          prev.stockItemId == item.stockItemId,
                                    );
                                    final totalBal = matchedItems.fold<double>(
                                      0.0,
                                      (sum, prev) => sum + prev.balance,
                                    );
                                    final totalPayout = matchedItems
                                        .fold<double>(
                                          0.0,
                                          (sum, prev) => sum + prev.totalPayout,
                                        );
                                    final totalWithdrawal = matchedItems
                                        .fold<double>(
                                          0.0,
                                          (sum, prev) =>
                                              sum + prev.totalWithdrawal,
                                        );
                                    final totalPrin = matchedItems.fold<double>(
                                      0.0,
                                      (sum, prev) => sum + prev.principal,
                                    );
                                    if (totalPrin <= 0) return 0.0;
                                    final profit =
                                        (totalBal +
                                            totalPayout +
                                            totalWithdrawal) -
                                        totalPrin;
                                    return (profit / totalPrin) * 100;
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
                                      const SizedBox(width: 8),
                                      JText(
                                        '${item.quantity.toCommaString()}주 · ${item.currentPrice.toCurrency(isForeign: isForeign)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      JText(
                                        '평가액: ${item.balance.toCurrency(isForeign: isForeign)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      JText(
                                        '원금: ${item.principal.toCurrency(isForeign: isForeign)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
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
                                        JText(
                                          '당월 배당: ${item.monthlyPayout.toCurrency(isForeign: isForeign)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.teal.shade700,
                                          ),
                                        ),
                                        JText(
                                          '누적 배당: ${item.totalPayout.toCurrency(isForeign: isForeign)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.teal.shade900,
                                            fontWeight: FontWeight.bold,
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
                                      JText(
                                        '당월 매도: ${item.monthlyWithdrawal.toCurrency(isForeign: isForeign)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '전월 대비: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          diffFromLastMonth
                                              .toSignedCurrencyText(
                                                isForeign: isForeign,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                        ],
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
