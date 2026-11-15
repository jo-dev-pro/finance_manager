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

    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 자산 현황'),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 상단 전체 요약 카드
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
                            final accounts = accountsAsync.value ?? [];
                            final accountMap = {
                              for (var a in accounts) a.id!: a,
                            };

                            final accountExchangeRateMap = {
                              for (var ab in accountBalances)
                                ab.accountId:
                                    ((accountMap[ab.accountId]
                                                    ?.isForeignCurrency ??
                                                false) &&
                                            ab.exchangeRate > 0)
                                        ? ab.exchangeRate
                                        : 1.0,
                            };
                            final lastAccountExchangeRateMap = {
                              for (var lab in lastAccountBalances)
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

                            for (var ab in accountBalances) {
                              final rate =
                                  accountExchangeRateMap[ab.accountId] ?? 1.0;
                              totalCashBalance += ab.cashBalance * rate;
                              accountPrincipalSum += ab.principal * rate;
                              totalAccountWithdrawalSum +=
                                  ab.totalWithdrawal * rate;
                            }

                            // 종목별 평가액 및 누적 배당금 합산 (환율 적용)
                            final stockBalanceSum = balances.fold<double>(0.0, (
                              sum,
                              item,
                            ) {
                              final rate =
                                  accountExchangeRateMap[item.accountId] ?? 1.0;
                              return sum + (item.balance * rate);
                            });

                            final totalPayoutSum = balances.fold<double>(0.0, (
                              sum,
                              item,
                            ) {
                              final rate =
                                  accountExchangeRateMap[item.accountId] ?? 1.0;
                              return sum + (item.totalPayout * rate);
                            });

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
                            for (var lab in lastAccountBalances) {
                              final rate =
                                  lastAccountExchangeRateMap[lab.accountId] ??
                                  1.0;
                              lastTotalCashBalance += lab.cashBalance * rate;
                            }
                            final lastStockSum = lastBalances.fold<double>(
                              0.0,
                              (sum, item) {
                                final rate =
                                    lastAccountExchangeRateMap[item
                                        .accountId] ??
                                    1.0;
                                return sum + (item.balance * rate);
                              },
                            );
                            final lastTotalBalance =
                                (lastStockSum + lastTotalCashBalance)
                                    .roundToDouble();

                            return GestureDetector(
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
                                title: '주식 자산 전체 금액',
                                mainAmountText: totalBalance.round().toWon(),
                                principalText: totalPrincipal.round().toWon(),
                                profitLossWidget: Row(
                                  children: [
                                    totalProfitOrLoss
                                        .round()
                                        .toSignedPriceText(
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          positiveColor: const Color(
                                            0xFFFF8A80,
                                          ),
                                          negativeColor: const Color(
                                            0xFF82B1FF,
                                          ),
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
                                  if (totalPayoutSum > 0)
                                    Text(
                                      '누적 배당: ${totalPayoutSum.round().toWon()}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (totalAccountWithdrawalSum > 0)
                                    Text(
                                      '계좌 누적 인출: ${totalAccountWithdrawalSum.round().toWon()}',
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
                                          positiveColor: const Color(
                                            0xFFFF8A80,
                                          ),
                                          negativeColor: const Color(
                                            0xFF82B1FF,
                                          ),
                                          zeroColor: Colors.white,
                                        ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // 2. 주식 계좌 목록 그리드
                        const SectionTitle(
                          '주식 계좌 목록',
                          topSpacing: 24,
                          bottomSpacing: 12,
                        ),
                        StockAccountGrid(
                          currentMonth: activeCurrentMonth,
                          lastMonth: lastMonth,
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
                        const SectionTitle(
                          '계좌별 평가 비중',
                          topSpacing: 28,
                          bottomSpacing: 12,
                        ),
                        StockPortionSection(
                          currentMonth: activeCurrentMonth,
                          chartColors: _chartColors,
                        ),

                        // 4. 계좌별 월말 수익률 추이
                        const SectionTitle(
                          '계좌별 월말 수익률 추이 (%)',
                          topSpacing: 28,
                          bottomSpacing: 12,
                        ),
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
    );
  }
}