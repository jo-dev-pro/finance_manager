import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/screen_size.dart';
import '../../../models/account/account.dart';
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../providers/pension/pension_product_provider.dart';

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

          // 당월 및 전월 상품별 데이터
          final balancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(activeCurrentMonth),
          );
          final lastBalancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(lastMonth),
          );

          // 당월 및 전월 계좌별 현금성 자산 데이터 (신규 반영)
          final accountBalancesAsync = ref.watch(
            monthlyPensionAccountBalanceNotifierProvider(activeCurrentMonth),
          );
          final lastAccountBalancesAsync = ref.watch(
            monthlyPensionAccountBalanceNotifierProvider(lastMonth),
          );

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: desktopWidthSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelectorHeader(
                    context,
                    months,
                    activeCurrentMonth,
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
                              final lastBalances =
                                  lastBalancesAsync.value ?? [];
                              final lastAccountBalances =
                                  lastAccountBalancesAsync.value ?? [];

                              // 1. 순수 상품 평가액 및 원금 합산
                              final productBalanceSum = balances.fold<double>(
                                0.0,
                                (sum, item) => sum + item.balance,
                              );
                              final productPrincipalSum = balances.fold<double>(
                                0.0,
                                (sum, item) => sum + item.principal,
                              );

                              // 2. 계좌 현금성 자산 합산
                              final accountCashSum = accountBalances
                                  .fold<double>(
                                    0.0,
                                    (sum, item) => sum + item.cashBalance,
                                  );

                              // 총 자산 = 상품 평가액 합계 + 계좌 현금성 잔액 합계
                              final totalBalance =
                                  productBalanceSum + accountCashSum;
                              final totalPrincipal =
                                  productPrincipalSum +
                                  accountCashSum; // 현금성 자산은 원금 동일 간주

                              final totalProfitOrLoss = balances.fold<double>(
                                0.0,
                                (sum, item) => sum + item.profitOrLoss,
                              );
                              final totalReturnRate =
                                  totalPrincipal > 0
                                      ? (totalProfitOrLoss / totalPrincipal) *
                                          100
                                      : 0.0;

                              // 전월 총 자산 합산
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

                              return _buildSummaryCard(
                                totalBalance: totalBalance,
                                totalPrincipal: totalPrincipal,
                                totalProfitOrLoss: totalProfitOrLoss,
                                totalReturnRate: totalReturnRate,
                                diffFromLastMonth:
                                    totalBalance - lastTotalBalance,
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '계좌 목록',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          balancesAsync.when(
                            loading: () => const CircularProgressIndicator(),
                            error: (err, _) => Text('로드 실패: $err'),
                            data: (balances) {
                              final accountBalances =
                                  accountBalancesAsync.value ?? [];

                              final accounts = accountsAsync.value ?? [];
                              final accountNames =
                                  accountNamesAsync.value ?? [];
                              final products = productsAsync.value ?? [];

                              final Map<String, List<MonthlyPensionBalance>>
                              accountGroups = {};
                              for (var item in balances) {
                                accountGroups
                                    .putIfAbsent(item.accountId, () => [])
                                    .add(item);
                              }

                              // 계좌 요약 데이터가 있는 계좌들도 그룹에 포함
                              for (var accBal in accountBalances) {
                                accountGroups.putIfAbsent(
                                  accBal.accountId,
                                  () => [],
                                );
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
                                    accounts,
                                    accountNames,
                                    products,
                                  ),
                                  const SizedBox(height: 28),
                                  const Text(
                                    '계좌별 평가 비중',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPortionSection(
                                    accountIds,
                                    accountGroups,
                                    accountCashMap,
                                    accounts,
                                    accountNames,
                                    overallTotalBalance,
                                  ),
                                  const SizedBox(height: 28),
                                  const Text(
                                    '계좌별 월말 수익률 추이 (%)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildReturnRateChart(
                                    accountIds,
                                    months,
                                    accounts,
                                    accountNames,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelectorHeader(
    BuildContext context,
    List<String> months,
    String currentMonth,
  ) {
    final currentIndex = months.indexOf(currentMonth);

    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentIndex < months.length - 1
                    ? () {
                      ref
                          .read(selectedYearMonthProvider.notifier)
                          .select(months[currentIndex + 1]);
                    }
                    : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  months.contains(currentMonth) ? currentMonth : months.first,
              icon: const Icon(Icons.arrow_drop_down),
              items:
                  months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
              onChanged: (String? newMonth) {
                if (newMonth != null) {
                  ref.read(selectedYearMonthProvider.notifier).select(newMonth);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                currentIndex > 0
                    ? () {
                      ref
                          .read(selectedYearMonthProvider.notifier)
                          .select(months[currentIndex - 1]);
                    }
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalBalance,
    required double totalPrincipal,
    required double totalProfitOrLoss,
    required double totalReturnRate,
    required double diffFromLastMonth,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '연금 자산 전체 금액',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            totalBalance.toWon(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold, 
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '총 투자 원금',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalPrincipal.toWon(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '평가 손익 (수익률)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      totalProfitOrLoss.toSignedPriceText(
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '전월 대비: ',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              diffFromLastMonth.toSignedPriceText(
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
    );
  }

  Widget _buildAccountGrid(
    List<String> accountIds,
    Map<String, List<MonthlyPensionBalance>> accountGroups,
    Map<String, double> accountCashMap,
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
        mainAxisExtent: 140, // 💡 중요: 카드 세로 높이를 140px로 고정하여 세로 공간 축소
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId] ?? [];

        final productSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final cashBalance = accountCashMap[accountId] ?? 0.0;
        final totalAccountBalance = productSum + cashBalance;

        final matchedAcc = accountMap[accountId];
        final matchedAccountName =
            matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;

        final institution = matchedAcc?.financialInstitution ?? '기타';
        final accountName = matchedAccountName?.accountName ?? accountId;

        return _AccountCard(
          institution: institution,
          accountName: accountName,
          totalBalance: totalAccountBalance,
          itemCount: items.length,
          cashBalance: cashBalance,
          onTap: () {
            _showProductDetailBottomSheet(
              context,
              institution: institution,
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
                final labelText =
                    '${matchedAcc?.financialInstitution ?? "기타"} - ${matchedAccountName?.accountName ?? accId}';

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
                        child: Text(
                          labelText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildReturnRateChart(
    List<String> accountIds,
    List<String> months,
    List<Account> accounts,
    List<dynamic> accountNames,
  ) {
    final sortedMonths = months.reversed.toList();
    final allBalances =
        ref.watch(allMonthlyPensionBalancesProvider).value ?? [];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.grey.shade900,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '수익률: ${spot.y.toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval:
                        sortedMonths.length > 12
                            ? (sortedMonths.length / 6).ceil().toDouble()
                            : 1.0,
                    getTitlesWidget: (val, meta) {
                      int idx = val.toInt();
                      if (idx >= 0 && idx < sortedMonths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            sortedMonths[idx],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              lineBarsData:
                  accountIds.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final accId = entry.value;

                    final spots =
                        sortedMonths.asMap().entries.map((mEntry) {
                          final mIdx = mEntry.key;
                          final ym = mEntry.value;

                          final items = allBalances.where(
                            (b) =>
                                b.balanceItem.yearMonth == ym &&
                                b.balanceItem.accountId == accId,
                          );
                          final totalBal = items.fold<double>(
                            0.0,
                            (s, item) => s + item.balanceItem.balance,
                          );
                          final totalPrin = items.fold<double>(
                            0.0,
                            (s, item) => s + item.balanceItem.principal,
                          );

                          final rate =
                              totalPrin > 0
                                  ? ((totalBal - totalPrin) / totalPrin) * 100
                                  : 0.0;
                          return FlSpot(mIdx.toDouble(), rate);
                        }).toList();

                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _chartColors[idx % _chartColors.length],
                      barWidth: 2.5,
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetailBottomSheet(
    BuildContext context, {
    required String institution,
    required String accountName,
    required List<MonthlyPensionBalance> products,
    required double cashBalance,
    required Map<String, String> productMap,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[$institution] $accountName 보유 자산 상세',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
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
                          '💵 계좌 현금성 자산 (예수금)',
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
                              ? '💵 계좌 공통 현금성 자산 (예수금)'
                              : (productMap[item.productId] ?? '연금 상품');

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '평가액: ${item.balance.toWon()} | 원금: ${item.principal.toWon()}\n수익률: ${item.returnRate.toStringAsFixed(1)}% (연환산: ${item.annualizedReturnRate.toStringAsFixed(1)}%)',
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

// 💡 컴팩트하고 폰트가 시원한 계좌 카드 위젯
class _AccountCard extends StatelessWidget {
  final String institution;
  final String accountName;
  final double totalBalance;
  final int itemCount;
  final double cashBalance;
  final VoidCallback onTap;

  const _AccountCard({
    required this.institution,
    required this.accountName,
    required this.totalBalance,
    required this.itemCount,
    required this.cashBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단: 금융사 & 계좌명
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institution,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // 하단: 보유 상품 정보 & 계좌 금액
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cashBalance > 0
                        ? '상품 $itemCount개 + 현금'
                        : '보유상품 $itemCount개',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    totalBalance.toWon(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E43B3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
