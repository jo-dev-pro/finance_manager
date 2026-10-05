import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard/dashboard_provider.dart';
import '../../core/utils/number_formatter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<String>>>(
      availableYearMonthsProvider,
      (previous, next) {
        next.whenData((months) {
          if (months.isNotEmpty) {
            final selectedMonth = ref.read(selectedYearMonthProvider);
            if (selectedMonth == null || !months.contains(selectedMonth)) {
              ref.read(selectedYearMonthProvider.notifier).select(months.first);
            }
          }
        });
      },
    );

    final monthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        elevation: 0,
      ),
      body: monthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 자산/기준월 데이터가 없습니다.'));
          }

          final String activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref.read(selectedYearMonthProvider.notifier).select(activeCurrentMonth);
            });
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(availableYearMonthsProvider);
                  ref.invalidate(dashboardSummaryProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSelectorHeader(
                            context,
                            ref,
                            months,
                            activeCurrentMonth,
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                summaryAsync.when(
                                  data: (summary) {
                                    final num totalValuation = summary.totalValuation;
                                    final num totalInvested = summary.totalInvested;
                                    final num profitOrLoss = summary.profitOrLoss;
                                    final num returnRate = summary.returnRate;

                                    final num bankBalance = summary.bankBalance;
                                    final num stockBalance = summary.stockBalance;
                                    final num pensionBalance = summary.pensionBalance;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade600,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '총 자산 평가액',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                totalValuation.toWon(),
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
                                                        '투자 원금',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        totalInvested.toWon(),
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
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          profitOrLoss.toSignedPriceText(
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          returnRate.toSignedPercentText(
                                                            withParentheses: true,
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        const Text(
                                          '자산별 현황',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        _buildAssetTile(
                                          icon: Icons.account_balance,
                                          color: Colors.blue.shade100,
                                          iconColor: Colors.blue.shade800,
                                          title: '은행 잔액',
                                          amountWon: bankBalance.toWon(),
                                        ),
                                        _buildAssetTile(
                                          icon: Icons.show_chart,
                                          color: Colors.orange.shade100,
                                          iconColor: Colors.orange.shade800,
                                          title: '증권 평가액',
                                          amountWon: stockBalance.toWon(),
                                        ),
                                        _buildAssetTile(
                                          icon: Icons.savings,
                                          color: Colors.green.shade100,
                                          iconColor: Colors.green.shade800,
                                          title: '연금 평가액',
                                          amountWon: pensionBalance.toWon(),
                                        ),
                                        const SizedBox(height: 28),

                                        const Text(
                                          '자산 비중',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        _buildAssetRatioChartCard(summary),
                                      ],
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  error: (e, st) => Center(child: Text('데이터 로드 오류: $e')),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAssetRatioChartCard(dynamic summary) {
    final double bank = (summary.bankBalance ?? 0).toDouble();
    final double stock = (summary.stockBalance ?? 0).toDouble();
    final double pension = (summary.pensionBalance ?? 0).toDouble();
    final double total = bank + stock + pension;

    if (total <= 0) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('자산 데이터가 존재하지 않습니다.')),
        ),
      );
    }

    final double bankRatio = (bank / total) * 100;
    final double stockRatio = (stock / total) * 100;
    final double pensionRatio = (pension / total) * 100;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    if (bank > 0)
                      PieChartSectionData(
                        color: Colors.blue.shade600,
                        value: bank,
                        title: bankRatio.toPercent(fractionDigits: 1),
                        radius: 35,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (stock > 0)
                      PieChartSectionData(
                        color: Colors.orange.shade600,
                        value: stock,
                        title: stockRatio.toPercent(fractionDigits: 1),
                        radius: 35,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (pension > 0)
                      PieChartSectionData(
                        color: Colors.green.shade600,
                        value: pension,
                        title: pensionRatio.toPercent(fractionDigits: 1),
                        radius: 35,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  color: Colors.blue.shade600,
                  label: '은행',
                  percentageRatio: bankRatio,
                ),
                _buildLegendItem(
                  color: Colors.orange.shade600,
                  label: '증권',
                  percentageRatio: stockRatio,
                ),
                _buildLegendItem(
                  color: Colors.green.shade600,
                  label: '연금',
                  percentageRatio: pensionRatio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required double percentageRatio,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(
          percentageRatio.toPercent(fractionDigits: 1),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMonthSelectorHeader(
    BuildContext context,
    WidgetRef ref,
    List<String> months,
    String currentMonth,
  ) {
    final currentIndex = months.indexOf(currentMonth);

    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentIndex >= 0 && currentIndex < months.length - 1)
                ? () {
                    ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex + 1]);
                  }
                : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: months.contains(currentMonth) ? currentMonth : months.first,
              icon: const Icon(Icons.arrow_drop_down),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              items: months.map((String month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(
                    month,
                    style: const TextStyle(color: Colors.black87),
                  ),
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
                    ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex - 1]);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetTile({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String amountWon,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountWon,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}