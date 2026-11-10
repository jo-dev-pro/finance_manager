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
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../providers/pension/pension_product_provider.dart';
import 'widget/pension_account_grid.dart';
import 'widget/pension_portion_section.dart'; // 💡 연금 비중 섹션 위젯 임포트
import 'widget/pension_return_rate_chart.dart';

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
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('연금 자산 현황'),
        elevation: 0,
        scrolledUnderElevation: 0,     // 스크롤 시 그림자/색상 변화 방지
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
          const SizedBox(width: 16),
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
                            final lastBalances = lastBalancesAsync.value ?? [];
                            final lastAccountBalances =
                                lastAccountBalancesAsync.value ?? [];

                            final productBalanceSum = balances.fold<double>(
                              0.0,
                              (sum, item) => sum + item.balance,
                            );
                            final productPrincipalSum = balances.fold<double>(
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
                            final totalPrincipal =
                                productPrincipalSum + accountCashSum;

                            final totalProfitOrLoss =
                                (totalBalance + totalAccountWithdrawalSum) -
                                totalPrincipal;

                            final totalReturnRate = totalPrincipal > 0
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

                            return SummaryCard(
                              title: '연금 자산 전체 금액',
                              mainAmountText: totalBalance.toWon(),
                              principalText: totalPrincipal.toWon(),
                              profitLossWidget: Row(
                                children: [
                                  totalProfitOrLoss.toSignedPriceText(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  totalReturnRate.toSignedPercentText(
                                    withParentheses: true,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              subInfoWidgets: totalAccountWithdrawalSum > 0
                                  ? [
                                      Text(
                                        '계좌 누적 인출액: ${totalAccountWithdrawalSum.toWon()}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ]
                                  : null,
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
                          '계좌 목록',
                          topSpacing: 24,
                          bottomSpacing: 12,
                        ),

                        balancesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (err, _) => Text('로드 실패: $err'),
                          data: (balances) {
                            final accountBalances =
                                accountBalancesAsync.value ?? [];
                            final lastBalances = lastBalancesAsync.value ?? [];
                            final lastAccountBalances =
                                lastAccountBalancesAsync.value ?? [];

                            final accounts = accountsAsync.value ?? [];
                            final accountNames = accountNamesAsync.value ?? [];
                            final products = productsAsync.value ?? [];

                            final Map<String, List<MonthlyPensionBalance>>
                                accountGroups = {};
                            for (var item in balances) {
                              accountGroups
                                  .putIfAbsent(item.accountId, () => [])
                                  .add(item);
                            }

                            for (var accBal in accountBalances) {
                              accountGroups.putIfAbsent(
                                accBal.accountId,
                                () => [],
                              );
                            }

                            final Map<String, List<MonthlyPensionBalance>>
                                lastAccountGroups = {};
                            for (var item in lastBalances) {
                              lastAccountGroups
                                  .putIfAbsent(item.accountId, () => [])
                                  .add(item);
                            }

                            if (accountGroups.isEmpty) {
                              return const Center(
                                child: Text('등록된 연금 계좌 데이터가 없습니다.'),
                              );
                            }

                            final accountIds = accountGroups.keys.toList();
                            final accountCashMap = {
                              for (var ab in accountBalances)
                                ab.accountId: ab.cashBalance,
                            };
                            final accountWithdrawalMap = {
                              for (var ab in accountBalances)
                                ab.accountId: ab.totalWithdrawal,
                            };
                            final lastAccountCashMap = {
                              for (var lab in lastAccountBalances)
                                lab.accountId: lab.cashBalance,
                            };

                            final totalProductSum = balances.fold<double>(
                              0.0,
                              (s, i) => s + i.balance,
                            );
                            final totalCashSum = accountBalances.fold<double>(
                              0.0,
                              (s, i) => s + i.cashBalance,
                            );
                            final overallTotalBalance =
                                totalProductSum + totalCashSum;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PensionAccountGrid(
                                  accountIds: accountIds,
                                  accountGroups: accountGroups,
                                  accountCashMap: accountCashMap,
                                  accountWithdrawalMap: accountWithdrawalMap,
                                  lastAccountGroups: lastAccountGroups,
                                  lastAccountCashMap: lastAccountCashMap,
                                  accounts: accounts,
                                  accountNames: accountNames,
                                  products: products,
                                ),

                                const SectionTitle(
                                  '계좌별 평가 비중',
                                  topSpacing: 28,
                                  bottomSpacing: 12,
                                ),

                                // 💡 분리한 PensionPortionSection 위젯 호출
                                PensionPortionSection(
                                  accountIds: accountIds,
                                  accountGroups: accountGroups,
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

                                PensionReturnRateChart(
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