import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router_path.dart';
import '../../../core/utils/number_formatter.dart';
import '../../../models/account/account.dart';
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/pension/pension_product_provider.dart'; // 💡 상품명 매핑을 위해 추가

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
    final productsAsync = ref.watch(pensionProductNotifierProvider); // 💡 상품 목록 프로바이더 watch

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
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Text('오류: $err'),
                        data: (balances) {
                          final totalBalance = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.balance,
                          );
                          // 💡 [추가] 전체 원금 및 총 평가 손익/수익률 계산
                          final totalPrincipal = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.principal,
                          );
                          final totalProfitOrLoss = balances.fold<double>(
                            0.0,
                            (sum, item) => sum + item.profitOrLoss,
                          );
                          final totalReturnRate = totalPrincipal > 0
                              ? (totalProfitOrLoss / totalPrincipal) * 100
                              : 0.0;

                          final lastTotalBalance = lastBalancesAsync.maybeWhen(
                            data: (lb) => lb.fold<double>(
                                0.0, (sum, item) => sum + item.balance),
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
                      const SizedBox(height: 24),
                      const Text(
                        '계좌 목록',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      balancesAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (err, _) => Text('로드 실패: $err'),
                        data: (balances) {
                          if (balances.isEmpty) {
                            return const Center(
                                child: Text('등록된 연금 계좌 데이터가 없습니다.'));
                          }

                          final accounts = accountsAsync.value ?? [];
                          final accountNames = accountNamesAsync.value ?? [];
                          final products = productsAsync.value ?? []; // 💡 상품 매핑 맵 생성용

                          final Map<String, List<MonthlyPensionBalance>>
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAccountGrid(accountIds, accountGroups,
                                  accounts, accountNames, products),
                              const SizedBox(height: 28),
                              const Text(
                                '계좌별 평가 비중',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildPortionSection(accountIds, accountGroups,
                                  accounts, accountNames, totalBalance),
                              const SizedBox(height: 28),
                              const Text(
                                '계좌별 월말 수익률 추이 (%)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildReturnRateChart(accountIds, months,
                                  accounts, accountNames),
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
      BuildContext context, List<String> months, String currentMonth) {
    final currentIndex = months.indexOf(currentMonth);

    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentIndex < months.length - 1 
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
            onPressed: currentIndex > 0
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

  // 💡 [수정] 상단 대시보드에 전체 원금, 평가 손익 및 누적 수익률 반영
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
          const Text('연금 자산 전체 금액',
              style: TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            totalBalance.toWon(),
            style: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
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
                  const Text('총 투자 원금',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    totalPrincipal.toWon(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('평가 손익 (수익률)',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      totalProfitOrLoss.toSignedPriceText(
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      totalReturnRate.toSignedPercentText(
                        withParentheses: true,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
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
              const Text('전월 대비: ',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              diffFromLastMonth.toSignedPriceText(
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
    List<Account> accounts,
    List<dynamic> accountNames,
    List<dynamic> products,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};
    
    // 💡 [수정] Map<String, String>으로 명시적 캐스팅 또는 변환 적용
    final Map<String, String> productMap = {
      for (var p in products) p.id.toString(): p.productName.toString()
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId]!;
        final accountTotal =
            items.fold<double>(0.0, (sum, item) => sum + item.balance);

        final matchedAcc = accountMap[accountId];
        final matchedAccountName = matchedAcc != null
            ? accountNameMap[matchedAcc.accountNameId]
            : null;

        final institution = matchedAcc?.financialInstitution ?? '기타';
        final accountName = matchedAccountName?.accountName ?? accountId;

        return _AccountCard(
          institution: institution,
          accountName: accountName,
          totalBalance: accountTotal,
          itemCount: items.length,
          onTap: () {
            _showProductDetailBottomSheet(
              context,
              institution: institution,
              accountName: accountName,
              products: items,
              productMap: productMap, // 이제 타입이 정확히 일치하여 오류가 사라집니다.
            );
          },
        );
      },
    );
  }

  Widget _buildPortionSection(
    List<String> accountIds,
    Map<String, List<MonthlyPensionBalance>> accountGroups,
    List<Account> accounts,
    List<dynamic> accountNames,
    double totalBalance,
  ) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: accountIds.asMap().entries.map((entry) {
            final index = entry.key;
            final accId = entry.value;
            final items = accountGroups[accId]!;
            final accountTotal =
                items.fold<double>(0.0, (sum, item) => sum + item.balance);
            final ratio =
                totalBalance > 0 ? (accountTotal / totalBalance) * 100 : 0.0;

            final matchedAcc = accountMap[accId];
            final matchedAccountName = matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;
            final labelText =
                '${matchedAcc?.financialInstitution ?? "기타"} - ${matchedAccountName?.accountName ?? accId}';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      color: _chartColors[index % _chartColors.length]),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(labelText,
                          style: const TextStyle(fontSize: 13))),
                  Text('${accountTotal.toWon()} (${ratio.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
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
      child: SizedBox(
        height: 280,
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
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                    interval: sortedMonths.length > 12
                        ? (sortedMonths.length / 6).ceil().toDouble()
                        : 1.0,
                    getTitlesWidget: (val, meta) {
                      int idx = val.toInt();
                      if (idx >= 0 && idx < sortedMonths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            sortedMonths[idx],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              lineBarsData: accountIds.asMap().entries.map((entry) {
                final idx = entry.key;
                final accId = entry.value;

                final spots = sortedMonths.asMap().entries.map((mEntry) {
                  final mIdx = mEntry.key;
                  final ym = mEntry.value;

                  final items = allBalances.where((b) =>
                      b.balanceItem.yearMonth == ym &&
                      b.balanceItem.accountId == accId);
                  final totalBal = items.fold<double>(
                      0.0, (s, item) => s + item.balanceItem.balance);
                  final totalPrin = items.fold<double>(
                      0.0, (s, item) => s + item.balanceItem.principal);

                  final rate = totalPrin > 0
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

  // 💡 [수정] 바텀시트에 상품명 표기 및 매수일 기준 연환산수익률(item.annualizedReturnRate) 정상 표출
  void _showProductDetailBottomSheet(
    BuildContext context, {
    required String institution,
    required String accountName,
    required List<MonthlyPensionBalance> products,
    required Map<String, String> productMap,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('[$institution] $accountName 보유 상품',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    
                    // 현금성 자산 또는 상품명 매핑
                    final productName = item.productId == '_CASH_ASSET_PRODUCT_ID_'
                        ? '💵 계좌 공통 현금성 자산 (예수금)'
                        : (productMap[item.productId] ?? '연금 상품');

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        '평가액: ${item.balance.toWon()} | 원금: ${item.principal.toWon()}\n수익률: ${item.returnRate.toStringAsFixed(1)}% (연환산: ${item.annualizedReturnRate.toStringAsFixed(1)}%)',
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
                  Text(institution,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                  Text(accountName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(totalBalance.toWon(),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                  Text('보유상품 $itemCount개',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}