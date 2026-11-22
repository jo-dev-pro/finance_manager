import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class PensionReturnRateChart extends ConsumerStatefulWidget {
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
  ConsumerState<PensionReturnRateChart> createState() =>
      _PensionReturnRateChartState();
}

class _PensionReturnRateChartState
    extends ConsumerState<PensionReturnRateChart> {
  List<LineBarSpot> _touchedSpots = [];
  Offset? _touchLocalPosition;

  Widget _buildAccountLogo(String? logoUrl, Color fallbackColor) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          logoUrl,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.account_balance,
                size: 14,
                color: fallbackColor,
              ),
        ),
      );
    }
    return Icon(
      Icons.account_balance,
      size: 14,
      color: fallbackColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBalances =
        ref.watch(allMonthlyPensionBalancesProvider).value ?? [];
    final currentBalances =
        ref
            .watch(monthlyPensionBalanceNotifierProvider(widget.currentMonth))
            .value ??
        [];
    final currentAccountBalances =
        ref
            .watch(
              monthlyPensionAccountBalanceNotifierProvider(widget.currentMonth),
            )
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

    final sortedMonths = widget.months.reversed.toList();
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    // 월별 계좌 데이터 맵 캐싱 (연월 -> 계좌리스트)
    final monthlyAccountBalanceMap = {
      for (var ym in sortedMonths)
        ym:
            ref.watch(monthlyPensionAccountBalanceNotifierProvider(ym)).value ??
            [],
    };

    final seriesAccountNames =
        accountIds.map((accId) {
          final matchedAcc = accountMap[accId];
          final matchedName =
              matchedAcc != null
                  ? accountNameMap[matchedAcc.accountNameId]
                  : null;
          return matchedName?.accountName ?? accId;
        }).toList();

    final seriesLogoUrls =
        accountIds.map((accId) => accountMap[accId]?.logoUrl).toList();

    return Card(
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
                    final name = seriesAccountNames[idx];
                    final logoUrl = seriesLogoUrls[idx];
                    final color =
                        widget.chartColors[idx % widget.chartColors.length];

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
                        _buildAccountLogo(logoUrl, color),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final hasTooltip =
                      _touchedSpots.isNotEmpty && _touchLocalPosition != null;

                  double tooltipLeft = (_touchLocalPosition?.dx ?? 0) + 12;
                  if (tooltipLeft + 175 > constraints.maxWidth) {
                    tooltipLeft =
                        ((_touchLocalPosition?.dx ?? 0) - 185)
                            .clamp(0.0, constraints.maxWidth - 175);
                  }
                  final tooltipTop = ((_touchLocalPosition?.dy ?? 0) - 24)
                      .clamp(0.0, constraints.maxHeight - 130);

                  return Stack(
                    children: [
                      LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color: Colors.grey.shade200,
                                  strokeWidth: 1,
                                ),
                            getDrawingVerticalLine:
                                (value) => FlLine(
                                  color: Colors.grey.shade100,
                                  strokeWidth: 1,
                                ),
                          ),
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response?.lineBarSpots == null ||
                                  response!.lineBarSpots!.isEmpty) {
                                if (_touchedSpots.isNotEmpty ||
                                    _touchLocalPosition != null) {
                                  setState(() {
                                    _touchedSpots = [];
                                    _touchLocalPosition = null;
                                  });
                                }
                                return;
                              }
                              setState(() {
                                _touchedSpots =
                                    List<LineBarSpot>.from(
                                      response.lineBarSpots!,
                                    )
                                      ..sort(
                                        (a, b) => b.y.compareTo(a.y),
                                      );
                                _touchLocalPosition = event.localPosition;
                              });
                            },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (spots) =>
                                      spots.map((_) => null).toList(),
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
                                        ? (sortedMonths.length / 6)
                                            .ceil()
                                            .toDouble()
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
                                      final productBal = items.fold<double>(
                                        0.0,
                                        (s, item) => s + item.balanceItem.balance,
                                      );

                                      final accBalObj =
                                          monthlyAccountBalanceMap[ym]
                                              ?.firstWhereOrNull(
                                                (ab) => ab.accountId == accId,
                                              );

                                      final cashBal =
                                          accBalObj?.cashBalance ?? 0.0;
                                      final withdrawal =
                                          accBalObj?.totalWithdrawal ?? 0.0;
                                      // 월말 계좌 기준 원금 우선 사용, 없으면 상품 원금 합산
                                      final totalPrin =
                                          accBalObj != null &&
                                                  accBalObj.principal > 0
                                              ? accBalObj.principal
                                              : items.fold<double>(
                                                0.0,
                                                (s, item) =>
                                                    s +
                                                    item.balanceItem.principal,
                                              );

                                      final totalBal = productBal + cashBal;
                                      final profit =
                                          (totalBal + withdrawal) - totalPrin;

                                      final rate =
                                          totalPrin > 0
                                              ? (profit / totalPrin) * 100
                                              : 0.0;
                                      return FlSpot(mIdx.toDouble(), rate);
                                    }).toList();

                                return LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color:
                                      widget.chartColors[idx %
                                          widget.chartColors.length],
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(show: false),
                                );
                              }).toList(),
                        ),
                      ),
                      if (hasTooltip)
                        Positioned(
                          left: tooltipLeft,
                          top: tooltipTop,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900.withValues(
                                  alpha: 0.92,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    _touchedSpots.map((spot) {
                                      final isValid =
                                          spot.barIndex >= 0 &&
                                          spot.barIndex <
                                              seriesAccountNames.length;
                                      final accName =
                                          isValid
                                              ? seriesAccountNames[spot
                                                  .barIndex]
                                              : '';
                                      final logoUrl =
                                          isValid
                                              ? seriesLogoUrls[spot.barIndex]
                                              : null;
                                      final lineColor =
                                          widget.chartColors[spot.barIndex %
                                              widget.chartColors.length];
                                      final rateText =
                                          '${spot.y.toStringAsFixed(1)}%';

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildAccountLogo(
                                              logoUrl,
                                              lineColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '$accName ',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              rateText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}