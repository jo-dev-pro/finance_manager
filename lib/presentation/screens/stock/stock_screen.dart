import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/router/branches/tab_back_dashboard_scope.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/jtext.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import 'summary/monthly_stock_summary_screen.dart';
import 'widgets/stock_account_grid.dart';
import 'widgets/stock_portion_section.dart';
import 'widgets/stock_return_rate_chart.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  static const String _excludedAccountName = '지니';

  final List<Color> _chartColors = [
    Colors.indigo,
    Colors.teal,
    Colors.orange,
    Colors.deepPurple,
    Colors.blue,
    Colors.pink,
  ];

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
  Widget build(BuildContext context) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNames = ref.watch(accountNameNotifierProvider).value ?? [];

    return TabBackToDashboardScope(
      child: Scaffold(
        appBar: MainAppBar(
          titleText: '주식 자산 현황',
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.push(AppRoutePath.realtimeStock);
                  },
                  icon: const Icon(Icons.candlestick_chart),
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      AppRoutePath.monthlyStockBalance,
                      extra: selectedMonth,
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('월말주식'),
                ),
              ],
            ),
          ],
        ),
        body: availableMonthsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('데이터 실패: $err')),
          data: (months) {
            if (months.isEmpty) {
              return const Center(child: Text('등록된 주식 데이터가 없습니다.'));
            }
      
            final activeCurrentMonth =
                (selectedMonth != null && months.contains(selectedMonth))
                    ? selectedMonth
                    : months.first;
      
            final lastMonth = _getLastYearMonth(activeCurrentMonth);
      
            final balancesAsync = ref.watch(
              monthlyStockBalanceNotifierProvider(activeCurrentMonth),
            );
            final lastBalancesAsync = ref.watch(
              monthlyStockBalanceNotifierProvider(lastMonth),
            );
      
            final accountBalancesAsync = ref.watch(
              monthlyStockAccountBalanceNotifierProvider(activeCurrentMonth),
            );
            final lastAccountBalancesAsync = ref.watch(
              monthlyStockAccountBalanceNotifierProvider(lastMonth),
            );
      
            final accounts = accountsAsync.value ?? [];
            final accountNameMap = {for (var an in accountNames) an.id: an};
            final genieAccountIds =
                accounts
                    .where(
                      (a) =>
                          a.id != null &&
                          accountNameMap[a.accountNameId]?.accountName.trim() ==
                              _excludedAccountName,
                    )
                    .map((a) => a.id!)
                    .toSet();
      
            return MainConstrainedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthSelectorHeader(
                    months: months,
                    currentMonth: activeCurrentMonth,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. 상단 전체 요약 카드 ("지니" 계좌 제외)
                          balancesAsync.when(
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error: (err, _) => Text('오류: $err'),
                            data: (balances) {
                              final accountBalances =
                                  accountBalancesAsync.value ?? [];
                              final lastBalances = lastBalancesAsync.value ?? [];
                              final lastAccountBalances =
                                  lastAccountBalancesAsync.value ?? [];
                              final accountMap = {
                                for (var a in accounts) a.id!: a,
                              };
      
                              final summaryAccountBalances =
                                  accountBalances
                                      .where(
                                        (ab) =>
                                            !genieAccountIds.contains(ab.accountId),
                                      )
                                      .toList();
                              final summaryBalances =
                                  balances
                                      .where(
                                        (b) =>
                                            !genieAccountIds.contains(b.accountId),
                                      )
                                      .toList();
                              final lastSummaryAccountBalances =
                                  lastAccountBalances
                                      .where(
                                        (lab) =>
                                            !genieAccountIds.contains(
                                              lab.accountId,
                                            ),
                                      )
                                      .toList();
                              final lastSummaryBalances =
                                  lastBalances
                                      .where(
                                        (lb) =>
                                            !genieAccountIds.contains(lb.accountId),
                                      )
                                      .toList();
      
                              final accountExchangeRateMap = {
                                for (var ab in summaryAccountBalances)
                                  ab.accountId:
                                      ((accountMap[ab.accountId]
                                                      ?.isForeignCurrency ??
                                                  false) &&
                                              ab.exchangeRate > 0)
                                          ? ab.exchangeRate
                                          : 1.0,
                              };
                              final lastAccountExchangeRateMap = {
                                for (var lab in lastSummaryAccountBalances)
                                  lab.accountId:
                                      ((accountMap[lab.accountId]
                                                      ?.isForeignCurrency ??
                                                  false) &&
                                              lab.exchangeRate > 0)
                                          ? lab.exchangeRate
                                          : 1.0,
                              };
      
                              // 계좌별 현금성 잔액(예수금), 누적 원금(principal), 누적 인출액 합산 (환율 적용)
                              double totalCashBalance = 0;
                              double accountPrincipalSum = 0;
                              double totalAccountWithdrawalSum = 0;
      
                              for (var ab in summaryAccountBalances) {
                                final rate =
                                    accountExchangeRateMap[ab.accountId] ?? 1.0;
                                totalCashBalance += ab.cashBalance * rate;
                                accountPrincipalSum += ab.principal;
                                totalAccountWithdrawalSum +=
                                    ab.totalWithdrawal * rate;
                              }
      
                              // 종목별 평가액 및 누적 배당금 합산 (환율 적용)
                              final stockBalanceSum = summaryBalances.fold<double>(
                                0.0,
                                (sum, item) {
                                  final rate =
                                      accountExchangeRateMap[item.accountId] ??
                                      1.0;
                                  return sum + (item.balance * rate);
                                },
                              );
      
                              final totalPayoutSum = summaryBalances.fold<double>(
                                0.0,
                                (sum, item) {
                                  final rate =
                                      accountExchangeRateMap[item.accountId] ??
                                      1.0;
                                  return sum + (item.totalPayout * rate);
                                },
                              );
      
                              final totalBalance =
                                  (stockBalanceSum + totalCashBalance)
                                      .roundToDouble();
                              final totalPrincipal =
                                  accountPrincipalSum.roundToDouble();
      
                              final totalProfitOrLoss =
                                  (totalBalance +
                                      totalPayoutSum +
                                      totalAccountWithdrawalSum) -
                                  totalPrincipal;
      
                              final totalReturnRate =
                                  totalPrincipal > 0
                                      ? (totalProfitOrLoss / totalPrincipal) * 100
                                      : 0.0;
      
                              // 전월 총 자산 계산
                              double lastTotalCashBalance = 0;
                              for (var lab in lastSummaryAccountBalances) {
                                final rate =
                                    lastAccountExchangeRateMap[lab.accountId] ??
                                    1.0;
                                lastTotalCashBalance += lab.cashBalance * rate;
                              }
                              final lastStockSum = lastSummaryBalances
                                  .fold<double>(0.0, (sum, item) {
                                    final rate =
                                        lastAccountExchangeRateMap[item
                                            .accountId] ??
                                        1.0;
                                    return sum + (item.balance * rate);
                                  });
                              final lastTotalBalance =
                                  (lastStockSum + lastTotalCashBalance)
                                      .roundToDouble();
      
                              return InkWell(
                                onTap: () {
                                  ref
                                      .read(
                                        selectedStockAccountFilterProvider
                                            .notifier,
                                      )
                                      .state = null;
                                  context.push(
                                    AppRoutePath.monthlyStockSummary,
                                    extra: activeCurrentMonth,
                                  );
                                },
                                child: SummaryCard(
                                  title: '주식 자산',
                                  mainAmountText: totalBalance.round().toWon(),
                                  principalText: totalPrincipal.round().toWon(),
                                  profitLossWidget: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        totalProfitOrLoss.round().toSignedPriceText(
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
                                  ),
                                  subInfoWidgets: [
                                    if (totalPayoutSum > 0)
                                      JText(
                                        '누적 배당: ${totalPayoutSum.round().toWon()}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (totalAccountWithdrawalSum > 0)
                                      JText(
                                        '누적 인출: ${totalAccountWithdrawalSum.round().toWon()}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                  diffFromLastMonthWidget: (totalBalance -
                                          lastTotalBalance)
                                      .round()
                                      .toSignedPriceText(
                                        isDarkCard: true,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),
      
                          // 2. 주식 계좌 목록 그리드 ("지니" 계좌 맨 마지막 배치)
                          const SizedBox(height: 12),
                          const SectionTitle('계좌 목록'),
      
                          StockAccountGrid(
                            currentMonth: activeCurrentMonth,
                            lastMonth: lastMonth,
                            lastAccountIds: genieAccountIds,
                            onAccountTap: (accountId) {
                              context.push(
                                AppRoutePath.monthlyStockSummary,
                                extra: {
                                  'yearMonth': activeCurrentMonth,
                                  'accountId': accountId,
                                },
                              );
                            },
                          ),
      
                          // 3. 계좌별 평가 비중
                          const SizedBox(height: 12),
                          const SectionTitle('계좌별 평가 비중'),
      
                          StockPortionSection(
                            currentMonth: activeCurrentMonth,
                            chartColors: _chartColors,
                          ),
      
                          // 4. 계좌별 월말 수익률 추이
                          const SizedBox(height: 12),
                          const SectionTitle('계좌별 월말 수익률 추이 (%)'),
      
                          StockReturnRateChart(
                            currentMonth: activeCurrentMonth,
                            months: months,
                            chartColors: _chartColors,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}