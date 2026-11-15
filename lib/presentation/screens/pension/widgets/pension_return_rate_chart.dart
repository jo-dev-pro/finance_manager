import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class PensionReturnRateChart extends ConsumerWidget {
  final String currentMonth;
  final List<String> months;
  final List<Color> chartColors;

  const PensionReturnRateChart({
    super.key,
    required this.currentMonth,
    required this.months,
    required this.chartColors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBalances = ref.watch(allMonthlyPensionBalancesProvider).value ?? [];
    final currentBalances =
        ref.watch(monthlyPensionBalanceNotifierProvider(currentMonth)).value ??
            [];
    final currentAccountBalances = ref
            .watch(monthlyPensionAccountBalanceNotifierProvider(currentMonth))
            .value ??
        [];
    final accounts = ref.watch(accountNotifierProvider).value ?? [];
    final accountNames = ref.watch(accountNameNotifierProvider).value ?? [];

    // 현재 선택 월 기준 계좌 ID 목록 추출
    final accountIdSet = <String>{
      for (var item in currentBalances) item.accountId,
      for (var ab in currentAccountBalances) ab.accountId,
    };
    final accountIds = accountIdSet.toList();

    final sortedMonths = months.reversed.toList();
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    // 월별 계좌 데이터 맵 캐싱 (연월 -> 계좌리스트)
    final monthlyAccountBalanceMap = {
      for (var ym in sortedMonths)
        ym: ref
                .watch(monthlyPensionAccountBalanceNotifierProvider(ym))
                .value ??
            [],
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: accountIds.asMap().entries.map((entry) {
                final idx = entry.key;
                final accId = entry.value;
                final matchedAcc = accountMap[accId];
                final matchedName = matchedAcc != null
                    ? accountNameMap[matchedAcc.accountNameId]
                    : null;
                final name = matchedName?.accountName ?? accId;
                final logoUrl = matchedAcc?.logoUrl;
                final color = chartColors[idx % chartColors.length];

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
                          errorBuilder: (_, __, ___) => const Icon(
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
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                    getDrawingVerticalLine: (value) =>
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
                  lineBarsData: accountIds.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final accId = entry.value;

                    final spots = sortedMonths.asMap().entries.map((mEntry) {
                      final mIdx = mEntry.key;
                      final ym = mEntry.value;

                      final items = allBalances.where(
                        (b) =>
                            b.balanceItem.yearMonth == ym &&
                            b.balanceItem.accountId == accId,
                      );
                      final productBal = items.fold<double>(
                        0.0,
                        (s, item) => s + item.balanceItem.balance,
                      );

                      final accBalObj = monthlyAccountBalanceMap[ym]
                          ?.firstWhereOrNull((ab) => ab.accountId == accId);

                      final cashBal = accBalObj?.cashBalance ?? 0.0;
                      final withdrawal = accBalObj?.totalWithdrawal ?? 0.0;
                      // 월말 계좌 기준 원금 우선 사용, 없으면 상품 원금 합산
                      final totalPrin = accBalObj != null && accBalObj.principal > 0
                          ? accBalObj.principal
                          : items.fold<double>(
                              0.0,
                              (s, item) => s + item.balanceItem.principal,
                            );

                      final totalBal = productBal + cashBal;
                      final profit = (totalBal + withdrawal) - totalPrin;

                      final rate =
                          totalPrin > 0 ? (profit / totalPrin) * 100 : 0.0;
                      return FlSpot(mIdx.toDouble(), rate);
                    }).toList();

                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: chartColors[idx % chartColors.length],
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
}