import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard/dashboard_provider.dart';

typedef MonthlyReturnRateCalculator = double Function(
  WidgetRef ref,
  String yearMonth,
);

class MonthlyReturnRateChartDialog extends ConsumerWidget {
  final String titleText;
  final String accountName;
  final String? logoUrl;
  final MonthlyReturnRateCalculator rateCalculator;
  final String emptyMessage;
  final bool showAccountLogoInTitleRow;

  const MonthlyReturnRateChartDialog({
    super.key,
    required this.titleText,
    required this.accountName,
    required this.logoUrl,
    required this.rateCalculator,
    this.emptyMessage = '표시할 월별 수익률 데이터가 없습니다.',
    this.showAccountLogoInTitleRow = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String titleText,
    required String accountName,
    required String? logoUrl,
    required MonthlyReturnRateCalculator rateCalculator,
    String emptyMessage = '표시할 월별 수익률 데이터가 없습니다.',
    bool showAccountLogoInTitleRow = false,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (_) => MonthlyReturnRateChartDialog(
            titleText: titleText,
            accountName: accountName,
            logoUrl: logoUrl,
            rateCalculator: rateCalculator,
            emptyMessage: emptyMessage,
            showAccountLogoInTitleRow: showAccountLogoInTitleRow,
          ),
    );
  }

  Widget _buildAccountLogo({
    required String? logoUrl,
    required double size,
  }) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.account_balance,
                size: size - 2,
                color: Colors.grey.shade600,
              ),
        ),
      );
    }
    return Icon(
      Icons.account_balance,
      size: size - 2,
      color: Colors.grey.shade600,
    );
  }

  Widget _buildAccountLogoAndName() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAccountLogo(logoUrl: logoUrl, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            accountName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    if (showAccountLogoInTitleRow) {
      return Row(
        children: [
          _buildAccountLogo(logoUrl: logoUrl, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titleText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titleText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        _buildAccountLogoAndName(),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(availableYearMonthsProvider).value ?? [];
    final sortedMonths = months.reversed.toList();

    final monthlyReturnRates =
        sortedMonths.map((ym) => rateCalculator(ref, ym)).toList();

    final maxVal =
        monthlyReturnRates.isEmpty
            ? 10.0
            : monthlyReturnRates.reduce((a, b) => a > b ? a : b);
    final minVal =
        monthlyReturnRates.isEmpty
            ? 0.0
            : monthlyReturnRates.reduce((a, b) => a < b ? a : b);
    final span = (maxVal - minVal).abs();
    final margin = span > 0 ? span * 0.15 : 5.0;
    final paddedMax = maxVal + margin;
    final paddedMin = minVal - margin;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildTitle(),
      content: SizedBox(
        width: 420,
        height: 260,
        child:
            sortedMonths.isEmpty
                ? Center(child: Text(emptyMessage))
                : LineChart(
                  LineChartData(
                    minY: paddedMin,
                    maxY: paddedMax,
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
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            final ym =
                                (idx >= 0 && idx < sortedMonths.length)
                                    ? sortedMonths[idx]
                                    : '';
                            final rateStr = spot.y.toStringAsFixed(1);
                            return LineTooltipItem(
                              '$ym\n$rateStr%',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
                          reservedSize: 48,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
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
                          reservedSize: 28,
                          interval:
                              sortedMonths.length > 6
                                  ? (sortedMonths.length / 4).ceil().toDouble()
                                  : 1.0,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
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
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            monthlyReturnRates
                                .asMap()
                                .entries
                                .map(
                                  (entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry.value,
                                  ),
                                )
                                .toList(),
                        isCurved: true,
                        color: Colors.indigo,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.indigo.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}