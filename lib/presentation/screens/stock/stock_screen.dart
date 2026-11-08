import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/screen_size.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../models/account/account.dart';
import '../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
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
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error: (err, _) => Text('오류: $err'),
                          data: (balances) {
                            final accountBalances = accountBalancesAsync.value ?? [];
                            final lastAccountBalances = lastAccountBalancesAsync.value ?? [];
                            final accounts = accountsAsync.value ?? [];
                            final accountMap = {for (var a in accounts) a.id!: a};

                            // 💡 계좌 모델의 isForeignCurrency 필드를 확인하여 외화 계좌에만 환율 적용
                            final accountExchangeRateMap = {
                              for (var ab in accountBalances)
                                ab.accountId: (accountMap[ab.accountId]?.isForeignCurrency ?? false) && ab.exchangeRate > 0
                                    ? ab.exchangeRate
                                    : 1.0,
                            };
                            final lastAccountExchangeRateMap = {
                              for (var lab in lastAccountBalances)
                                lab.accountId: (accountMap[lab.accountId]?.isForeignCurrency ?? false) && lab.exchangeRate > 0
                                    ? lab.exchangeRate
                                    : 1.0,
                            };

                            final totalBalance = balances.fold<double>(
                              0.0,
                              (sum, item) {
                                final rate = accountExchangeRateMap[item.accountId] ?? 1.0;
                                return sum + (item.balance * rate);
                              },
                            );
                            final totalPrincipal = balances.fold<double>(
                              0.0,
                              (sum, item) {
                                final rate = accountExchangeRateMap[item.accountId] ?? 1.0;
                                return sum + (item.principal * rate);
                              },
                            );

                            final totalPayout = balances.fold<double>(
                              0.0,
                              (sum, item) {
                                final rate = accountExchangeRateMap[item.accountId] ?? 1.0;
                                return sum + (item.totalPayout * rate);
                              },
                            );
                            final totalWithdrawal = balances.fold<double>(
                              0.0,
                              (sum, item) {
                                final rate = accountExchangeRateMap[item.accountId] ?? 1.0;
                                return sum + (item.totalWithdrawal * rate);
                              },
                            );

                            final totalProfitOrLoss =
                                (totalBalance + totalPayout + totalWithdrawal) -
                                totalPrincipal;
                            final totalReturnRate =
                                totalPrincipal > 0
                                    ? (totalProfitOrLoss / totalPrincipal) * 100
                                    : 0.0;

                            final lastTotalBalance = lastBalancesAsync.maybeWhen(
                              data: (lb) {
                                return lb.fold<double>(
                                  0.0,
                                  (sum, item) {
                                    final rate = lastAccountExchangeRateMap[item.accountId] ?? 1.0;
                                    return sum + (item.balance * rate);
                                  },
                                );
                              },
                              orElse: () => 0.0,
                            );

                            return _buildSummaryCard(
                              totalBalance: totalBalance,
                              totalPrincipal: totalPrincipal,
                              totalProfitOrLoss: totalProfitOrLoss,
                              totalReturnRate: totalReturnRate,
                              totalPayout: totalPayout,
                              totalWithdrawal: totalWithdrawal,
                              diffFromLastMonth:
                                  totalBalance - lastTotalBalance,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '주식 계좌 목록',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        balancesAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (err, _) => Text('로드 실패: $err'),
                          data: (balances) {
                            if (balances.isEmpty) {
                              return const Center(
                                child: Text('등록된 주식 계좌 데이터가 없습니다.'),
                              );
                            }

                            final accountBalances = accountBalancesAsync.value ?? [];
                            final accounts = accountsAsync.value ?? [];
                            final accountNames = accountNamesAsync.value ?? [];
                            final stockItems = stockItemsAsync.value ?? [];
                            final accountMap = {for (var a in accounts) a.id!: a};

                            final accountExchangeRateMap = {
                              for (var ab in accountBalances)
                                ab.accountId: (accountMap[ab.accountId]?.isForeignCurrency ?? false) && ab.exchangeRate > 0
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
                            final overallTotalBalance = balances.fold<double>(
                              0.0,
                              (sum, item) {
                                final rate = accountExchangeRateMap[item.accountId] ?? 1.0;
                                return sum + (item.balance * rate);
                              },
                            );

                            final Map<String, String> stockMap = {
                              for (var s in stockItems)
                                s.id.toString(): s.itemName.toString(),
                            };

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAccountGrid(
                                  accountIds,
                                  accountGroups,
                                  accountExchangeRateMap,
                                  accountCashMap,
                                  accounts,
                                  accountNames,
                                  stockMap,
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
                                  accountExchangeRateMap,
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
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalBalance,
    required double totalPrincipal,
    required double totalProfitOrLoss,
    required double totalReturnRate,
    required double totalPayout,
    required double totalWithdrawal,
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
            '주식 자산 전체 금액',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            totalBalance.toWon(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
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
          if (totalPayout > 0 || totalWithdrawal > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (totalPayout > 0)
                  Text(
                    '누적 배당: ${totalPayout.toWon()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                if (totalWithdrawal > 0)
                  Text(
                    '누적 인출: ${totalWithdrawal.toWon()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ],
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
    Map<String, List<MonthlyStockBalance>> accountGroups,
    Map<String, double> accountExchangeRateMap,
    Map<String, double> accountCashMap,
    List<Account> accounts,
    List<dynamic> accountNames,
    Map<String, String> stockMap,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

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
        final items = accountGroups[accountId]!;
        
        final exchangeRate = accountExchangeRateMap[accountId] ?? 1.0;
        final cashBalance = (accountCashMap[accountId] ?? 0.0) * exchangeRate;

        final rawBalance = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final rawPrincipal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.principal,
        );
        final rawPayout = items.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPayout,
        );
        final rawWithdrawal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.totalWithdrawal,
        );

        final totalBalance = (rawBalance * exchangeRate) + cashBalance;
        final totalPrincipal = (rawPrincipal * exchangeRate) + cashBalance;
        final totalPayout = rawPayout * exchangeRate;
        final totalWithdrawal = rawWithdrawal * exchangeRate;

        final totalProfitOrLoss =
            (totalBalance + totalPayout + totalWithdrawal) - totalPrincipal;
        final returnRate =
            totalPrincipal > 0
                ? (totalProfitOrLoss / totalPrincipal) * 100
                : 0.0;

        final matchedAcc = accountMap[accountId];
        final matchedAccountName =
            matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;

        final institution = matchedAcc?.financialInstitution ?? '기타';
        final accountName = matchedAccountName?.accountName ?? accountId;

        return _AccountCard(
          account: matchedAcc,
          institution: institution,
          accountName: accountName,
          totalBalance: totalBalance,
          totalPrincipal: totalPrincipal,
          totalProfitOrLoss: totalProfitOrLoss,
          returnRate: returnRate,
          totalWithdrawal: totalWithdrawal,
          itemCount: items.length,
          onTap: () {
            _showStockDetailBottomSheet(
              context,
              institution: institution,
              accountName: accountName,
              items: items,
              cashBalance: cashBalance,
              exchangeRate: exchangeRate,
              stockMap: stockMap,
            );
          },
        );
      },
    );
  }

  Widget _buildPortionSection(
    List<String> accountIds,
    Map<String, List<MonthlyStockBalance>> accountGroups,
    Map<String, double> accountExchangeRateMap,
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
                final items = accountGroups[accId]!;
                
                final exchangeRate = accountExchangeRateMap[accId] ?? 1.0;
                final cashBal = (accountCashMap[accId] ?? 0.0) * exchangeRate;
                final rawBal = items.fold<double>(
                  0.0,
                  (sum, item) => sum + item.balance,
                );
                final accountTotal = (rawBal * exchangeRate) + cashBal;

                final ratio =
                    overallTotalBalance > 0
                        ? (accountTotal / overallTotalBalance) * 100
                        : 0.0;

                final matchedAcc = accountMap[accId];
                final matchedAccountName =
                    matchedAcc != null
                        ? accountNameMap[matchedAcc.accountNameId]
                        : null;
                
                final institution = matchedAcc?.financialInstitution ?? "기타";
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
                                '[$institution] $accountName',
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

  Widget _buildReturnRateChart(
    List<String> accountIds,
    List<String> months,
    List<Account> accounts,
    List<dynamic> accountNames,
  ) {
    final sortedMonths = months.reversed.toList();
    final allBalances = ref.watch(allMonthlyStockBalancesProvider).value ?? [];

    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  accountIds.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final accId = entry.value;
                    final matchedAcc = accountMap[accId];
                    final matchedName =
                        matchedAcc != null
                            ? accountNameMap[matchedAcc.accountNameId]
                            : null;
                    final name = matchedName?.accountName ?? accId;
                    final logoUrl = matchedAcc?.logoUrl;
                    final color = _chartColors[idx % _chartColors.length];

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (logoUrl != null && logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              logoUrl,
                              width: 16,
                              height: 16,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.account_balance,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.account_balance,
                            size: 14,
                            color: Colors.indigo,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    getDrawingVerticalLine:
                        (value) =>
                            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                  ),
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
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
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
                              final totalPayout = items.fold<double>(
                                0.0,
                                (s, item) => s + item.balanceItem.totalPayout,
                              );
                              final totalWithdrawal = items.fold<double>(
                                0.0,
                                (s, item) => s + item.balanceItem.totalWithdrawal,
                              );

                              final rate =
                                  totalPrin > 0
                                      ? (((totalBal + totalPayout + totalWithdrawal) - totalPrin) / totalPrin) * 100
                                      : 0.0;
                              return FlSpot(mIdx.toDouble(), rate);
                            }).toList();

                        return LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: _chartColors[idx % _chartColors.length],
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockDetailBottomSheet(
    BuildContext context, {
    required String institution,
    required String accountName,
    required List<MonthlyStockBalance> items,
    required double cashBalance,
    required double exchangeRate,
    required Map<String, String> stockMap,
  }) {
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
                    child: Text(
                      '[$institution] $accountName 보유 종목',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          '계좌 공통 현금성 자산 (예수금)',
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
                    ...items.map((item) {
                      final stockName = stockMap[item.stockItemId] ?? '주식 종목';
                      final itemBalance = item.balance * exchangeRate;
                      final itemPrincipal = item.principal * exchangeRate;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        title: Text(
                          stockName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '평가액: ${itemBalance.toWon()}   |   원금: ${itemPrincipal.toWon()}\n수량: ${item.quantity.toCommaString()}주   |   단가: ${(item.currentPrice * exchangeRate).toWon()}\n수익률: ${item.returnRate.toStringAsFixed(1)}%',
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

class _AccountCard extends StatelessWidget {
  final Account? account;
  final String institution;
  final String accountName;
  final double totalBalance;
  final double totalPrincipal;
  final double totalProfitOrLoss;
  final double returnRate;
  final double totalWithdrawal;
  final int itemCount;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.institution,
    required this.accountName,
    required this.totalBalance,
    required this.totalPrincipal,
    required this.totalProfitOrLoss,
    required this.returnRate,
    required this.totalWithdrawal,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final logoUrl = account?.logoUrl;

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (logoUrl != null && logoUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        logoUrl,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.account_balance,
                              size: 20,
                              color: Colors.grey,
                            ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.account_balance,
                      size: 20,
                      color: Colors.indigo,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          institution,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          accountName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    totalBalance.toWon(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E43B3),
                    ),
                  ),
                ],
              ),
              const Divider(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '투자 원금',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalPrincipal.toWon(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '평가 손익 (수익률)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          totalProfitOrLoss.toSignedPriceText(
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            positiveColor: Colors.red.shade700,
                            negativeColor: Colors.blue.shade700,
                            zeroColor: Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          returnRate.toSignedPercentText(
                            withParentheses: true,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            positiveColor: Colors.red.shade700,
                            negativeColor: Colors.blue.shade700,
                            zeroColor: Colors.black87,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '보유 종목 $itemCount개',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  Opacity(
                    opacity: totalWithdrawal > 0 ? 1.0 : 0.0,
                    child: Text(
                      totalWithdrawal > 0 ? '인출액: ${totalWithdrawal.toWon()}' : '',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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