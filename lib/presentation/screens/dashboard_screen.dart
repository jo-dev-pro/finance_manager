import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/asset_tile.dart';         // 💡 공통 자산 타일 임포트
import '../../core/widgets/main_constrainedbox.dart';
import '../../core/widgets/month_selector_header.dart';
import '../../core/widgets/section_title.dart';       // 💡 공통 섹션 타이틀 임포트
import '../../core/widgets/summary_card.dart';
import '../../providers/dashboard/dashboard_provider.dart';
import '../../core/utils/number_formatter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<String>>>(availableYearMonthsProvider, (
      previous,
      next,
    ) {
      next.whenData((months) {
        if (months.isNotEmpty) {
          final selectedMonth = ref.read(selectedYearMonthProvider);
          if (selectedMonth == null || !months.contains(selectedMonth)) {
            ref.read(selectedYearMonthProvider.notifier).select(months.first);
          }
        }
      });
    });

    final monthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('대시보드'), elevation: 0, scrolledUnderElevation: 0),    // 스크롤 시 그림자/색상 변화 방지
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
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

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
                    child: Builder(
                      builder: (context) {
                        final summary = summaryAsync.valueOrNull;

                        if (summary == null) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final num totalValuation = summary.totalValuation;
                        final num totalInvested = summary.totalInvested;
                        final num profitOrLoss = summary.profitOrLoss;
                        final num returnRate = summary.returnRate;

                        final num bankBalance = summary.bankBalance;
                        final num stockBalance = summary.stockBalance;
                        final num pensionBalance = summary.pensionBalance;
                        final double diffFromLastMonth = summary.diffFromLastMonth;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SummaryCard(
                              title: '총 자산 평가액',
                              mainAmountText: totalValuation.toWon(),
                              principalText: totalInvested.toWon(),
                              profitLossWidget: Row(
                                children: [
                                  profitOrLoss.toSignedPriceText(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    positiveColor: const Color(0xFFFF8A80),
                                    negativeColor: const Color(0xFF82B1FF),
                                    zeroColor: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  returnRate.toSignedPercentText(
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
                              diffFromLastMonthWidget: Row(
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
                            ),

                            // 💡 공통 SectionTitle 적용
                            const SectionTitle('자산별 현황', topSpacing: 24, bottomSpacing: 12),
                            
                            // 💡 공통 AssetTile 적용
                            AssetTile(
                              icon: Icons.account_balance,
                              backgroundColor: Colors.blue.shade100,
                              iconColor: Colors.blue.shade800,
                              title: '은행 잔액',
                              amountWon: bankBalance.toWon(),
                            ),
                            AssetTile(
                              icon: Icons.show_chart,
                              backgroundColor: Colors.orange.shade100,
                              iconColor: Colors.orange.shade800,
                              title: '증권 평가액',
                              amountWon: stockBalance.toWon(),
                            ),
                            AssetTile(
                              icon: Icons.savings,
                              backgroundColor: Colors.green.shade100,
                              iconColor: Colors.green.shade800,
                              title: '연금 평가액',
                              amountWon: pensionBalance.toWon(),
                            ),

                            const SectionTitle('자산 비중', topSpacing: 28, bottomSpacing: 12),
                            _buildAssetRatioChartCard(summary),
                          ],
                        );
                      },
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
}