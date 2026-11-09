import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/account_card.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../core/widgets/section_title.dart'; // 💡 공통 SectionTitle 적용
import '../../../core/widgets/summary_card.dart';
import '../../../models/account/account.dart';
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../providers/pension/pension_product_provider.dart';
import 'widget/pension_return_rate_chart.dart';

class PensionScreen extends ConsumerStatefulWidget {
  const PensionScreen({super.key});

  @override
  ConsumerState<PensionScreen> createState() => _PensionScreenState();
}

class _PensionScreenState extends ConsumerState<PensionScreen> {
  final TransformationController _transformationController =
      TransformationController();

  static const String kCashAssetProductId = '_CASH_ASSET_PRODUCT_ID_';

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
                              subInfoWidgets:
                                  totalAccountWithdrawalSum > 0
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
                                _buildAccountGrid(
                                  accountIds,
                                  accountGroups,
                                  accountCashMap,
                                  accountWithdrawalMap,
                                  lastAccountGroups,
                                  lastAccountCashMap,
                                  accounts,
                                  accountNames,
                                  products,
                                ),

                                const SectionTitle(
                                  '계좌별 평가 비중',
                                  topSpacing: 28,
                                  bottomSpacing: 12,
                                ),

                                _buildPortionSection(
                                  accountIds,
                                  accountGroups,
                                  accountCashMap,
                                  accounts,
                                  accountNames,
                                  overallTotalBalance,
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

  Widget _buildAccountGrid(
    List<String> accountIds,
    Map<String, List<MonthlyPensionBalance>> accountGroups,
    Map<String, double> accountCashMap,
    Map<String, double> accountWithdrawalMap,
    Map<String, List<MonthlyPensionBalance>> lastAccountGroups,
    Map<String, double> lastAccountCashMap,
    List<Account> accounts,
    List<dynamic> accountNames,
    List<dynamic> products,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    final Map<String, String> productMap = {
      for (var p in products) p.id.toString(): p.productName.toString(),
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 170,
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId] ?? [];
        final lastItems = lastAccountGroups[accountId] ?? [];

        final productSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final productPrincipalSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.principal,
        );

        final accountWithdrawal = accountWithdrawalMap[accountId] ?? 0.0;
        final cashBalance = accountCashMap[accountId] ?? 0.0;

        final totalAccountBalance = productSum + cashBalance;
        final totalAccountPrincipal = productPrincipalSum + cashBalance;

        final totalProfitOrLoss =
            (totalAccountBalance + accountWithdrawal) - totalAccountPrincipal;

        final returnRate =
            totalAccountPrincipal > 0
                ? (totalProfitOrLoss / totalAccountPrincipal) * 100
                : 0.0;

        final lastProductSum = lastItems.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final lastCashBalance = lastAccountCashMap[accountId] ?? 0.0;
        final lastTotalAccountBalance = lastProductSum + lastCashBalance;
        final diffFromLastMonth = totalAccountBalance - lastTotalAccountBalance;

        final matchedAcc = accountMap[accountId];
        final matchedAccountName =
            matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;
        final accountName = matchedAccountName?.accountName ?? accountId;

        return AccountCard(
          logoUrl: matchedAcc?.logoUrl,
          institution: '',
          accountName: accountName,
          totalBalance: totalAccountBalance,
          totalPrincipal: totalAccountPrincipal,
          totalProfitOrLoss: totalProfitOrLoss,
          returnRate: returnRate,
          totalWithdrawal: accountWithdrawal,
          diffFromLastMonth: diffFromLastMonth,
          itemCount: items.length,
          onTap: () {
            _showProductDetailBottomSheet(
              context,
              account: matchedAcc,
              accountName: accountName,
              products: items,
              cashBalance: cashBalance,
              productMap: productMap,
            );
          },
        );
      },
    );
  }

  Widget _buildPortionSection(
    List<String> accountIds,
    Map<String, List<MonthlyPensionBalance>> accountGroups,
    Map<String, double> accountCashMap,
    List<Account> accounts,
    List<dynamic> accountNames,
    double overallTotalBalance,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              accountIds.asMap().entries.map((entry) {
                final index = entry.key;
                final accId = entry.value;
                final items = accountGroups[accId] ?? [];

                final productSum = items.fold<double>(
                  0.0,
                  (s, item) => s + item.balance,
                );
                final cashBal = accountCashMap[accId] ?? 0.0;
                final accountTotal = productSum + cashBal;

                final ratio =
                    overallTotalBalance > 0
                        ? (accountTotal / overallTotalBalance) * 100
                        : 0.0;

                final matchedAcc = accountMap[accId];
                final matchedAccountName =
                    matchedAcc != null
                        ? accountNameMap[matchedAcc.accountNameId]
                        : null;
                final accountName = matchedAccountName?.accountName ?? accId;
                final logoUrl = matchedAcc?.logoUrl;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _chartColors[index % _chartColors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
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
                                      (_, __, ___) => const Icon(
                                        Icons.account_balance,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                ),
                              )
                            else
                              const Icon(
                                Icons.account_balance,
                                size: 16,
                                color: Colors.indigo,
                              ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                accountName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${accountTotal.toWon()} (${ratio.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  void _showProductDetailBottomSheet(
    BuildContext context, {
    required Account? account,
    required String accountName,
    required List<MonthlyPensionBalance> products,
    required double cashBalance,
    required Map<String, String> productMap,
  }) {
    final logoUrl = account?.logoUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.85,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (logoUrl != null && logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              logoUrl,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.account_balance,
                                    size: 22,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.account_balance,
                            size: 22,
                            color: Colors.indigo,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$accountName 보유 자산 상세',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    if (cashBalance > 0)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE0F2F1),
                          child: Icon(Icons.attach_money, color: Colors.teal),
                        ),
                        title: const Text(
                          '현금성 자산',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '잔액: ${cashBalance.toWon()}',
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ...products.map((item) {
                      final productName =
                          item.productId == kCashAssetProductId
                              ? '계좌 공통 현금성 자산 (예수금)'
                              : (productMap[item.productId] ?? '연금 상품');

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '평가액: ${item.balance.toWon()}   |   원금: ${item.principal.toWon()}\n수익률: ${item.returnRate.toStringAsFixed(1)}%   (연환산: ${item.annualizedReturnRate.toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
