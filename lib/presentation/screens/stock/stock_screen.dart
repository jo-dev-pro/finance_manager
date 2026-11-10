import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widget/stock_account_grid.dart';
import 'widget/stock_portion_section.dart';
import 'widget/stock_return_rate_chart.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final TransformationController _transformationController =
      TransformationController();

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
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 자산 현황'),
        elevation: 0,
        actions: [
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
          const SizedBox(width: 16),
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

          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonthSelectorHeader(
                  months: months,
                  currentMonth: activeCurrentMonth,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        balancesAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (err, _) => Text('오류: $err'),
                          data: (balances) {
                            final accountBalances =
                                accountBalancesAsync.value ?? [];
                            final lastAccountBalances =
                                lastAccountBalancesAsync.value ?? [];
                            final accounts = accountsAsync.value ?? [];
                            final accountMap = {
                              for (var a in accounts) a.id!: a,
                            };

                            final accountExchangeRateMap = {
                              for (var ab in accountBalances)
                                ab.accountId:
                                    ((accountMap[ab.accountId]?.isForeignCurrency ?? false) &&
                                            ab.exchangeRate > 0)
                                        ? ab.exchangeRate
                                        : 1.0,
                            };
                            final lastAccountExchangeRateMap = {
                              for (var lab in lastAccountBalances)
                                lab.accountId:
                                    ((accountMap[lab.accountId]?.isForeignCurrency ?? false) &&
                                            lab.exchangeRate > 0)
                                        ? lab.exchangeRate
                                        : 1.0,
                            };

                            // 💡 계좌별 현금성 잔액(예수금) 합산
                            double totalCashBalance = 0;
                            for (var ab in accountBalances) {
                              final rate = accountExchangeRateMap[ab.accountId] ?? 1.0;
                              totalCashBalance += ab.cashBalance * rate;
                            }

                            double lastTotalCashBalance = 0;
                            for (var lab in lastAccountBalances) {
                              final rate = lastAccountExchangeRateMap[lab.accountId] ?? 1.0;
                              lastTotalCashBalance += lab.cashBalance * rate;
                            }

                            // 💡 종목별 평가액 및 원금 합산
                            final stockBalanceSum = balances.fold<double>(0.0, (
                              sum,
                              item,
                            ) {
                              final rate =
                                  accountExchangeRateMap[item.accountId] ?? 1.0;
                              return sum + (item.balance * rate);
                            });

                            final stockPrincipalSum = balances.fold<double>(0.0, (
                              sum,
                              item,
                            ) {
                              final rate =
                                  accountExchangeRateMap[item.accountId] ?? 1.0;
                              return sum + (item.principal * rate);
                            });

                            final totalPayout = balances.fold<double>(0.0, (
                              sum,
                              item,
                            ) {
                              final rate =
                                  accountExchangeRateMap[item.accountId] ?? 1.0;
                              return sum + (item.totalPayout * rate);
                            });

                            final totalWithdrawal = balances.fold<double>(0.0, (
                              sum,
                              item,
                            ) {
                              final rate =
                                  accountExchangeRateMap[item.accountId] ?? 1.0;
                              return sum + (item.totalWithdrawal * rate);
                            });

                            // 💡 최종 자산 및 원금에 예수금 반영 후 정수형 반올림(.roundToDouble())
                            final totalBalance = (stockBalanceSum + totalCashBalance).roundToDouble();
                            final totalPrincipal = (stockPrincipalSum + totalCashBalance).roundToDouble();

                            final totalProfitOrLoss =
                                (totalBalance + totalPayout + totalWithdrawal) -
                                totalPrincipal;
                            final totalReturnRate =
                                totalPrincipal > 0
                                    ? (totalProfitOrLoss / totalPrincipal) * 100
                                    : 0.0;

                            final lastStockSum = lastBalancesAsync
                                .maybeWhen(
                                  data: (lb) {
                                    return lb.fold<double>(0.0, (sum, item) {
                                      final rate =
                                          lastAccountExchangeRateMap[item
                                              .accountId] ??
                                          1.0;
                                      return sum + (item.balance * rate);
                                    });
                                  },
                                  orElse: () => 0.0,
                                );
                            final lastTotalBalance = (lastStockSum + lastTotalCashBalance).roundToDouble();

                            return SummaryCard(
                              title: '주식 자산 전체 금액',
                              mainAmountText: totalBalance.round().toWon(),
                              principalText: totalPrincipal.round().toWon(),
                              profitLossWidget: Row(
                                children: [
                                  totalProfitOrLoss.round().toSignedPriceText(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    positiveColor: const Color(0xFFFF8A80),
                                    negativeColor: const Color(0xFF82B1FF),
                                    zeroColor: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  totalReturnRate.toSignedPercentText(
                                    withParentheses: true,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    positiveColor: const Color(0xFFFF8A80),
                                    negativeColor: const Color(0xFF82B1FF),
                                    zeroColor: Colors.white,
                                  ),
                                ],
                              ),
                              subInfoWidgets: [
                                if (totalPayout > 0)
                                  Text(
                                    '누적 배당: ${totalPayout.round().toWon()}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                if (totalWithdrawal > 0)
                                  Text(
                                    '누적 인출: ${totalWithdrawal.round().toWon()}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                              diffFromLastMonthWidget: Row(
                                children: [
                                  const Text(
                                    '전월 대비: ',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  (totalBalance - lastTotalBalance)
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
                            );
                          },
                        ),

                        const SectionTitle(
                          '주식 계좌 목록',
                          topSpacing: 24,
                          bottomSpacing: 12,
                        ),

                        balancesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (err, _) => Text('로드 실패: $err'),
                          data: (balances) {
                            if (balances.isEmpty) {
                              return const Center(
                                child: Text('등록된 주식 계좌 데이터가 없습니다.'),
                              );
                            }

                            final accountBalances =
                                accountBalancesAsync.value ?? [];
                            final accounts = accountsAsync.value ?? [];
                            final accountNames = accountNamesAsync.value ?? [];
                            final stockItems = stockItemsAsync.value ?? [];
                            final accountMap = {
                              for (var a in accounts) a.id!: a,
                            };

                            final accountExchangeRateMap = {
                              for (var ab in accountBalances)
                                ab.accountId:
                                    ((accountMap[ab.accountId]?.isForeignCurrency ?? false) &&
                                            ab.exchangeRate > 0)
                                        ? ab.exchangeRate
                                        : 1.0,
                            };
                            final accountCashMap = {
                              for (var ab in accountBalances)
                                ab.accountId: ab.cashBalance,
                            };

                            final Map<String, List<MonthlyStockBalance>>
                                accountGroups = {};
                            for (var item in balances) {
                              accountGroups
                                  .putIfAbsent(item.accountId, () => [])
                                  .add(item);
                            }

                            final accountIds = accountGroups.keys.toList();
                            
                            // 💡 전체 비중 계산용 총합 (종목 + 예수금 반영 및 반올림)
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
                            final overallTotalBalance = (calcTotalStock + calcTotalCash).roundToDouble();

                            final Map<String, String> stockMap = {
                              for (var s in stockItems)
                                s.id.toString(): s.itemName.toString(),
                            };

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StockAccountGrid(
                                  accountIds: accountIds,
                                  accountGroups: accountGroups,
                                  accountExchangeRateMap:
                                      accountExchangeRateMap,
                                  accountCashMap: accountCashMap,
                                  accounts: accounts,
                                  accountNames: accountNames,
                                  stockMap: stockMap,
                                ),

                                const SectionTitle(
                                  '계좌별 평가 비중',
                                  topSpacing: 28,
                                  bottomSpacing: 12,
                                ),

                                StockPortionSection(
                                  accountIds: accountIds,
                                  accountGroups: accountGroups,
                                  accountExchangeRateMap:
                                      accountExchangeRateMap,
                                  accountCashMap: accountCashMap,
                                  accounts: accounts,
                                  accountNames: accountNames,
                                  overallTotalBalance: overallTotalBalance,
                                  chartColors: _chartColors,
                                ),

                                const SectionTitle(
                                  '계좌별 월말 수익률 추이 (%)',
                                  topSpacing: 28,
                                  bottomSpacing: 12,
                                ),

                                StockReturnRateChart(
                                  accountIds: accountIds,
                                  months: months,
                                  accounts: accounts,
                                  accountNames: accountNames,
                                  chartColors: _chartColors,
                                ),
                              ],
                            );
                          },
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
    );
  }
}