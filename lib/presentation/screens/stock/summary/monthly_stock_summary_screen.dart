import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';
import 'widgets/monthly_stock_account_summary_list.dart';

final selectedStockAccountFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

class MonthlyStockSummaryScreen extends ConsumerWidget {
  final Object? extra;

  const MonthlyStockSummaryScreen({super.key, this.extra});

  String _getLastYearMonth(String currentYearMonth) {
    try {
      final parts = currentYearMonth.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      DateTime lastMonthDate = DateTime(year, month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return currentYearMonth;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? initialMonth;
    String? initialAccountId;

    if (extra is Map<String, dynamic>) {
      initialMonth = (extra as Map<String, dynamic>)['yearMonth'] as String?;
      initialAccountId =
          (extra as Map<String, dynamic>)['accountId'] as String?;
    } else if (extra is String) {
      initialMonth = extra as String;
    }

    if (initialAccountId != null) {
      final currentFilter = ref.read(selectedStockAccountFilterProvider);
      if (currentFilter == null) {
        Future.microtask(() {
          ref.read(selectedStockAccountFilterProvider.notifier).state =
              initialAccountId;
        });
      }
    }

    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final selectedAccountId = ref.watch(selectedStockAccountFilterProvider);

    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주식 월말평가')),
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
                  : (initialMonth != null && months.contains(initialMonth))
                  ? initialMonth
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
                    monthlyStockBalanceNotifierProvider(activeCurrentMonth),
                  )
                  .value ??
              [];
          final lastItems =
              ref.watch(monthlyStockBalanceNotifierProvider(lastMonth)).value ??
              [];

          final accountBalances =
              ref
                  .watch(
                    monthlyStockAccountBalanceNotifierProvider(
                      activeCurrentMonth,
                    ),
                  )
                  .value ??
              [];
          final lastAccountBalances =
              ref
                  .watch(monthlyStockAccountBalanceNotifierProvider(lastMonth))
                  .value ??
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

          // 필터링된 당월/전월 데이터
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

          // 당월/전월 환율 맵 (단일 해외계좌 필터 시에는 원래 달러 단위 유지를 위해 1.0 적용)
          final exchangeRateMap = {
            for (var ab in accountBalances)
              ab.accountId:
                  (!isSingleOverseasAccount &&
                          (accountMap[ab.accountId]?.isForeignCurrency ??
                              false) &&
                          ab.exchangeRate > 0)
                      ? ab.exchangeRate
                      : 1.0,
          };
          final lastExchangeRateMap = {
            for (var lab in lastAccountBalances)
              lab.accountId:
                  (!isSingleOverseasAccount &&
                          (accountMap[lab.accountId]?.isForeignCurrency ??
                              false) &&
                          lab.exchangeRate > 0)
                      ? lab.exchangeRate
                      : 1.0,
          };

          double totalStockBalance = 0;
          double totalPrincipal = 0;
          double totalCashBalance = 0;
          double totalPayout = 0;
          double totalMonthlyWithdrawal = 0;
          double totalCumulativeWithdrawal = 0;
          double appliedExchangeRate = 1.0;

          for (var item in filteredStockItems) {
            final rate = exchangeRateMap[item.accountId] ?? 1.0;
            totalStockBalance += item.balance * rate;
            totalPayout += item.totalPayout * rate;
            totalCumulativeWithdrawal += item.totalWithdrawal * rate;
          }

          for (var ab in filteredAccountBalances) {
            final rate = exchangeRateMap[ab.accountId] ?? 1.0;
            totalCashBalance += ab.cashBalance * rate;
            totalPrincipal += ab.principal * rate;
            totalMonthlyWithdrawal += ab.monthlyWithdrawal * rate;
            totalCumulativeWithdrawal += ab.totalWithdrawal * rate;
            if (ab.exchangeRate > 1.0) {
              appliedExchangeRate = ab.exchangeRate;
            }
          }

          final grandTotalBalance = totalStockBalance + totalCashBalance;
          final totalProfit =
              (grandTotalBalance + totalPayout + totalCumulativeWithdrawal) -
              totalPrincipal;

          // 전월 총 자산 집계
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

          String formatCurrency(double val) {
            return isSingleOverseasAccount ? val.toUSD() : val.round().toWon();
          }

          return MainConstrainedBox(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 연월 및 계좌 선택 드롭다운
                  Row(
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
                              value:
                                  months.contains(activeCurrentMonth)
                                      ? activeCurrentMonth
                                      : months.first,
                              isExpanded: true,
                              items:
                                  months.map((ym) {
                                    return DropdownMenuItem(
                                      value: ym,
                                      child: Text(
                                        ym,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                      .read(selectedYearMonthProvider.notifier)
                                      .select(val);
                                }
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
                              value: currentDropdownValue,
                              isExpanded: true,
                              hint: const Text('전체 계좌'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    '전체 계좌',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                ...stockAccounts.map((account) {
                                  final accId = account.id ?? '';
                                  final nameObj =
                                      accountNameMap[account.accountNameId];
                                  final accName = nameObj?.accountName ?? '계좌';
                                  final institution =
                                      account.financialInstitution;
                                  return DropdownMenuItem<String?>(
                                    value: accId,
                                    child: Text(
                                      '$institution $accName',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                ref
                                    .read(
                                      selectedStockAccountFilterProvider
                                          .notifier,
                                    )
                                    .state = val;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. 상단 요약 카드 (SummaryCard 디자인 통일)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (isSingleOverseasAccount &&
                            appliedExchangeRate > 1.0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '적용 환율: ${appliedExchangeRate.toCommaString()}원/\$',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '원화 환산: ${(grandTotalBalance * appliedExchangeRate).round().toWon()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWhiteSummaryItem(
                              label: '총 자산',
                              value: formatCurrency(grandTotalBalance),
                            ),
                            _buildWhiteSummaryItem(
                              label: '총 원금',
                              value: formatCurrency(totalPrincipal),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '총 손익',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                isSingleOverseasAccount
                                    ? Text(
                                      '${totalProfit > 0 ? '+' : ''}${totalProfit.toUSD()}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            totalProfit > 0
                                                ? const Color(0xFFFF8A80)
                                                : totalProfit < 0
                                                ? const Color(0xFF82B1FF)
                                                : Colors.white,
                                      ),
                                    )
                                    : totalProfit.round().toSignedPriceText(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      positiveColor: const Color(0xFFFF8A80),
                                      negativeColor: const Color(0xFF82B1FF),
                                      zeroColor: Colors.white,
                                    ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWhiteSummaryItem(
                              label: '현금성 잔액(예수금)',
                              value: formatCurrency(totalCashBalance),
                            ),
                            _buildWhiteSummaryItem(
                              label: '누적 배당금',
                              value: formatCurrency(totalPayout),
                            ),
                            _buildWhiteSummaryItem(
                              label: '누적 인출액',
                              value: formatCurrency(totalCumulativeWithdrawal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              '전월 대비: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            isSingleOverseasAccount
                                ? Text(
                                  '${summaryDiffFromLastMonth > 0 ? '+' : ''}${summaryDiffFromLastMonth.toUSD()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        summaryDiffFromLastMonth > 0
                                            ? const Color(0xFFFF8A80)
                                            : summaryDiffFromLastMonth < 0
                                            ? const Color(0xFF82B1FF)
                                            : Colors.white,
                                  ),
                                )
                                : summaryDiffFromLastMonth
                                    .round()
                                    .toSignedPriceText(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      positiveColor: const Color(0xFFFF8A80),
                                      negativeColor: const Color(0xFF82B1FF),
                                      zeroColor: Colors.white,
                                    ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '계좌별 현금 및 자금 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  MonthlyStockAccountSummaryList(
                    stockAccounts: stockAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    selectedAccountId: currentDropdownValue,
                    targetMonth: activeCurrentMonth,
                    onEditPressed: null,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '보유 종목별 월말 내역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
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
                        final balanceItem = filteredStockItems[index];

                        final matchedAcc = accountMap[balanceItem.accountId];
                        final institution =
                            matchedAcc?.financialInstitution ?? '기타 금융기관';
                        final nameObj =
                            matchedAcc != null
                                ? accountNameMap[matchedAcc.accountNameId]
                                : null;
                        final accountName = nameObj?.accountName ?? '주식계좌';
                        final isOverseas =
                            matchedAcc?.isForeignCurrency ?? false;

                        final stock = stockItemMap[balanceItem.stockItemId];
                        final stockName = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode ?? '';
                        final displayName =
                            stockCode.isNotEmpty
                                ? '$stockName ($stockCode)'
                                : stockName;

                        // 전월 동일 계좌/종목 평가액 비교
                        final lastBalanceItem = lastItems.firstWhereOrNull(
                          (item) =>
                              item.accountId == balanceItem.accountId &&
                              item.stockItemId == balanceItem.stockItemId,
                        );
                        final lastBalance = lastBalanceItem?.balance ?? 0.0;
                        final diffFromLastMonth =
                            balanceItem.balance - lastBalance;

                        String fmtItemMoney(double val) =>
                            isOverseas ? val.toUSD() : val.round().toWon();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                                      Text(
                                        '[$institution] $accountName',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (balanceItem.purchaseDate != null &&
                                          balanceItem.purchaseDate!.isNotEmpty)
                                        Text(
                                          '매수일: ${balanceItem.purchaseDate}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.indigo.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '평가액: ${fmtItemMoney(balanceItem.balance)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '원금: ${fmtItemMoney(balanceItem.principal)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '총 손익',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      isOverseas
                                          ? Text(
                                            '${balanceItem.profitOrLoss > 0 ? '+' : ''}${balanceItem.profitOrLoss.toUSD()}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  balanceItem.profitOrLoss >= 0
                                                      ? Colors.red.shade700
                                                      : Colors.blue.shade700,
                                            ),
                                          )
                                          : balanceItem.profitOrLoss
                                              .round()
                                              .toSignedPriceText(
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                positiveColor:
                                                    Colors.red.shade700,
                                                negativeColor:
                                                    Colors.blue.shade700,
                                              ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '수량: ${balanceItem.quantity.toCommaString()}주  |  현재가: ${fmtItemMoney(balanceItem.currentPrice)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '평단가: ${fmtItemMoney(balanceItem.averagePurchasePrice)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // 누적 배당금 및 누적 매도액 표시
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
                                        Text(
                                          '누적 배당: ${fmtItemMoney(balanceItem.totalPayout)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.teal.shade700,
                                          ),
                                        ),
                                        Text(
                                          '누적 매도: ${fmtItemMoney(balanceItem.totalWithdrawal)}',
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

                                  // 수익률 및 전월 대비
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '수익률: ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          balanceItem.returnRate
                                              .toSignedPercentText(
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                positiveColor:
                                                    Colors.red.shade700,
                                                negativeColor:
                                                    Colors.blue.shade700,
                                                withParentheses: false,
                                              ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(연환산: ${balanceItem.annualizedReturnRate.toSignedPercent()})',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
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
                                          isOverseas
                                              ? Text(
                                                '${diffFromLastMonth > 0 ? '+' : ''}${diffFromLastMonth.toUSD()}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      diffFromLastMonth > 0
                                                          ? Colors.red.shade700
                                                          : diffFromLastMonth <
                                                              0
                                                          ? Colors.blue.shade700
                                                          : Colors.grey,
                                                ),
                                              )
                                              : diffFromLastMonth
                                                  .round()
                                                  .toSignedPriceText(
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    positiveColor:
                                                        Colors.red.shade700,
                                                    negativeColor:
                                                        Colors.blue.shade700,
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

  Widget _buildWhiteSummaryItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
