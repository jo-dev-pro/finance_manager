import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router_path.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../models/account/account.dart';
import '../../../../models/account/account_name.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class StockMobileScreen extends ConsumerStatefulWidget {
  const StockMobileScreen({super.key});

  @override
  ConsumerState<StockMobileScreen> createState() => _StockMobileScreenState();
}

class _StockMobileScreenState extends ConsumerState<StockMobileScreen> {
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
          IconButton(
            onPressed: () {
              context.push(
                AppRoutePath.monthlyStockBalance,
                extra: selectedMonth,
              );
            },
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          const SizedBox(width: 8),
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthSelectorHeader(context, months, activeCurrentMonth),
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
                          final totalBalance = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.balance,
                          );
                          final totalPrincipal = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.principal,
                          );
                          final totalPayout = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.totalPayout,
                          );
                          final totalWithdrawal = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.totalWithdrawal,
                          );

                          final totalProfitOrLoss =
                              (totalBalance + totalPayout + totalWithdrawal) -
                              totalPrincipal;
                          final totalReturnRate =
                              totalPrincipal > 0
                                  ? (totalProfitOrLoss / totalPrincipal) * 100
                                  : 0.0;

                          final lastTotalBalance = lastBalancesAsync.maybeWhen(
                            data:
                                (lb) => lb.fold<double>(
                                  0.0,
                                  (sum, item) => sum + item.balance,
                                ),
                            orElse: () => 0.0,
                          );

                          return _buildSummaryCard(
                            totalBalance: totalBalance,
                            totalPrincipal: totalPrincipal,
                            totalProfitOrLoss: totalProfitOrLoss,
                            totalReturnRate: totalReturnRate,
                            diffFromLastMonth: totalBalance - lastTotalBalance,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '주식 계좌 목록',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      balancesAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (err, _) => Text('로드 실패: $err'),
                        data: (balances) {
                          if (balances.isEmpty) {
                            return const Center(
                              child: Text('등록된 주식 계좌 데이터가 없습니다.'),
                            );
                          }

                          final accounts = accountsAsync.value ?? [];
                          final accountNames = accountNamesAsync.value ?? [];
                          final stockItems = stockItemsAsync.value ?? [];

                          final Map<String, List<MonthlyStockBalance>>
                          accountGroups = {};
                          for (var item in balances) {
                            accountGroups
                                .putIfAbsent(item.accountId, () => [])
                                .add(item);
                          }

                          final accountIds = accountGroups.keys.toList();
                          final totalBalance = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.balance,
                          );
                          final Map<String, String> stockMap = {
                            for (var s in stockItems)
                              s.id.toString(): s.itemName.toString(),
                          };

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: accountIds.length,
                                itemBuilder: (context, index) {
                                  final accountId = accountIds[index];
                                  final items = accountGroups[accountId]!;
                                  final accountTotal = items.fold<double>(
                                    0.0,
                                    (sum, item) => sum + item.balance,
                                  );

                                  final matchedAcc = accounts.firstWhere(
                                    (a) => a.id == accountId,
                                    orElse:
                                        () => const Account(
                                          financialInstitution: '기타',
                                          accountType: '증권',
                                          accountNameId: '',
                                          sortOrder: 0,
                                        ),
                                  );

                                  final matchedAccountNameObj = accountNames
                                      .firstWhere(
                                        (an) =>
                                            an.id == matchedAcc.accountNameId,
                                        orElse:
                                            () => const AccountName(
                                              id: '',
                                              accountName: '알 수 없음',
                                            ), // 💡 기본 객체 반환
                                      );

                                  final institution =
                                      matchedAcc.financialInstitution;
                                  final accountName =
                                      matchedAccountNameObj.accountName;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10.0,
                                    ),
                                    child: SizedBox(
                                      height: 100,
                                      child: _AccountCard(
                                        institution: institution,
                                        accountName: accountName,
                                        totalBalance: accountTotal,
                                        itemCount: items.length,
                                        onTap: () {
                                          _showStockDetailBottomSheet(
                                            context,
                                            institution: institution,
                                            accountName: accountName,
                                            items: items,
                                            stockMap: stockMap,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                '계좌별 평가 비중',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildPortionSection(
                                accountIds,
                                accountGroups,
                                accounts,
                                accountNames,
                                totalBalance,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                '계좌별 월말 수익률 추이 (%)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
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
                    ? () => ref
                        .read(selectedYearMonthProvider.notifier)
                        .select(months[currentIndex + 1])
                    : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  months.contains(currentMonth) ? currentMonth : months.first,
              items:
                  months
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
              onChanged: (val) {
                if (val != null)
                  ref.read(selectedYearMonthProvider.notifier).select(val);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                currentIndex > 0
                    ? () => ref
                        .read(selectedYearMonthProvider.notifier)
                        .select(months[currentIndex - 1])
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주식 자산 전체 금액',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            totalBalance.toWon(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '총 투자 원금',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalPrincipal.toWon(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      totalProfitOrLoss.toSignedPriceText(
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      totalReturnRate.toSignedPercentText(
                        withParentheses: true,
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                '전월 대비: ',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              diffFromLastMonth.toSignedPriceText(
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
    );
  }

  Widget _buildPortionSection(
    List<String> accountIds,
    Map<String, List<MonthlyStockBalance>> accountGroups,
    List<Account> accounts,
    List<dynamic> accountNames,
    double totalBalance,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children:
              accountIds.asMap().entries.map((entry) {
                final index = entry.key;
                final accId = entry.value;
                final items = accountGroups[accId]!;
                final accountTotal = items.fold<double>(
                  0.0,
                  (sum, item) => sum + item.balance,
                );
                final ratio =
                    totalBalance > 0
                        ? (accountTotal / totalBalance) * 100
                        : 0.0;

                final matchedAcc = accountMap[accId];
                final matchedAccountNameObj =
                    (matchedAcc != null)
                        ? accountNameMap[matchedAcc.accountNameId]
                        : null;
                final labelText =
                    '${matchedAcc?.financialInstitution ?? "기타"} - ${matchedAccountNameObj?.accountName ?? accId}';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _chartColors[index % _chartColors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          labelText,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${accountTotal.toWon()} (${ratio.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 13,
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

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 240,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 35),
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
                    reservedSize: 25,
                    interval:
                        sortedMonths.length > 12
                            ? (sortedMonths.length / 6).ceil().toDouble()
                            : 1.0,
                    getTitlesWidget: (val, meta) {
                      int idx = val.toInt();
                      if (idx >= 0 && idx < sortedMonths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            sortedMonths[idx],
                            style: const TextStyle(
                              fontSize: 10,
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
                      barWidth: 2.0,
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showStockDetailBottomSheet(
    BuildContext context, {
    required String institution,
    required String accountName,
    required List<MonthlyStockBalance> items,
    required Map<String, String> stockMap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[$institution] $accountName 보유 종목',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final stockName =
                        item.stockItemId == kCashAssetProductId
                            ? '💵 계좌 공통 현금성 자산 (예수금)'
                            : (stockMap[item.stockItemId] ?? '주식 종목');

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        stockName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        item.stockItemId == kCashAssetProductId
                            ? '잔액: ${item.balance.toWon()}'
                            : '평가액: ${item.balance.toWon()} | 수량: ${item.quantity.toCommaString()}주\n단가: ${item.currentPrice.toWon()} | 수익률: ${item.returnRate.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
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
  final String institution;
  final String accountName;
  final double totalBalance;
  final int itemCount;
  final VoidCallback onTap;

  const _AccountCard({
    required this.institution,
    required this.accountName,
    required this.totalBalance,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    institution,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    accountName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalBalance.toWon(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    '보유종목 $itemCount개',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
