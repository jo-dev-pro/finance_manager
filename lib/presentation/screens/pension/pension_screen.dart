import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/jtext.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/summary_card.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import 'monthly_data/monthly_pension_balance_screen.dart';
import 'widgets/pension_account_grid.dart';
import 'widgets/pension_portion_section.dart';
import 'widgets/pension_return_rate_chart.dart';

class PensionScreen extends ConsumerStatefulWidget {
  const PensionScreen({super.key});

  @override
  ConsumerState<PensionScreen> createState() => _PensionScreenState();
}

class _PensionScreenState extends ConsumerState<PensionScreen> {
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

    return Scaffold(
      appBar: MainAppBar(
        titleText: '연금 자산 현황',
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              context.push(
                AppRoutePath.monthlyPensionBalance,
                extra: selectedMonth,
              );
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('월말연금'),
          ),
        ],
      ),

      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('데이터 실패: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 연금 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : months.first;

          final lastMonth = _getLastYearMonth(activeCurrentMonth);

          final balancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(activeCurrentMonth),
          );
          final lastBalancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(lastMonth),
          );

          final accountBalancesAsync = ref.watch(
            monthlyPensionAccountBalanceNotifierProvider(activeCurrentMonth),
          );
          final lastAccountBalancesAsync = ref.watch(
            monthlyPensionAccountBalanceNotifierProvider(lastMonth),
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
                        // 1. 전체 요약 카드
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

                            final productBalanceSum = balances.fold<double>(
                              0.0,
                              (sum, item) => sum + item.balance,
                            );

                            // 월말 계좌별 누적 원금(principal) 합산[cite: 9]
                            final accountPrincipalSum = accountBalances
                                .fold<double>(
                                  0.0,
                                  (sum, item) => sum + item.principal,
                                );

                            final totalAccountWithdrawalSum = accountBalances
                                .fold<double>(
                                  0.0,
                                  (sum, item) => sum + item.totalWithdrawal,
                                );

                            final accountCashSum = accountBalances.fold<double>(
                              0.0,
                              (sum, item) => sum + item.cashBalance,
                            );

                            final totalBalance =
                                productBalanceSum + accountCashSum;
                            final totalPrincipal = accountPrincipalSum;

                            final totalProfitOrLoss =
                                (totalBalance + totalAccountWithdrawalSum) -
                                totalPrincipal;

                            final totalReturnRate =
                                totalPrincipal > 0
                                    ? (totalProfitOrLoss / totalPrincipal) * 100
                                    : 0.0;

                            final lastProductSum = lastBalances.fold<double>(
                              0.0,
                              (sum, item) => sum + item.balance,
                            );
                            final lastCashSum = lastAccountBalances
                                .fold<double>(
                                  0.0,
                                  (sum, item) => sum + item.cashBalance,
                                );
                            final lastTotalBalance =
                                lastProductSum + lastCashSum;

                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(
                                      selectedPensionAccountFilterProvider
                                          .notifier,
                                    )
                                    .state = null;
                                context.push(
                                  AppRoutePath.monthlyPensionSummary,
                                  extra: activeCurrentMonth,
                                );
                              },
                              child: SummaryCard(
                                title: '연금 자산 전체 금액',
                                mainAmountText: totalBalance.toWon(),
                                principalText: totalPrincipal.toWon(),
                                profitLossWidget: Row(
                                  children: [
                                    totalProfitOrLoss.toSignedPriceText(
                                      // isDarkCard: true 는 인디고 바탕위에 다크모드로 하면 색깔이 밝아짐
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
                                subInfoWidgets:
                                    totalAccountWithdrawalSum > 0
                                        ? [
                                          JText(
                                            '계좌 누적 인출액: ${totalAccountWithdrawalSum.toWon()}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ]
                                        : null,
                                diffFromLastMonthWidget: (totalBalance -
                                        lastTotalBalance)
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

                        // 2. 계좌 목록 그리드
                        const SizedBox(height: 12),
                        const SectionTitle('계좌 목록'),

                        PensionAccountGrid(
                          currentMonth: activeCurrentMonth,
                          lastMonth: lastMonth,
                          onAccountTap: (accountId) {
                            context.push(
                              AppRoutePath.monthlyPensionSummary,
                              extra: {
                                'yearMonth': activeCurrentMonth,
                                'accountId': accountId,
                              },
                            );
                          },
                        ),

                        // 3. 계좌별 평가 비중 섹션
                        const SizedBox(height: 12),
                        const SectionTitle('계좌별 평가 비중'),

                        PensionPortionSection(
                          currentMonth: activeCurrentMonth,
                          chartColors: _chartColors,
                        ),

                        // 4. 계좌별 월말 수익률 추이 차트
                        const SizedBox(height: 12),
                        const SectionTitle('계좌별 월말 수익률 추이 (%)'),

                        PensionReturnRateChart(
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
