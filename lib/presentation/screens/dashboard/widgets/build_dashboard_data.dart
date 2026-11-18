import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_extension.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/summary_card.dart';
import 'asset_grid_card.dart';

class BuildDashboardData extends StatelessWidget {
  final dynamic summary;

  const BuildDashboardData({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final num totalValuation = (summary.totalValuation as num);
    final num totalInvested = (summary.totalInvested as num);
    final num profitOrLoss = (summary.profitOrLoss as num);
    final num returnRate = (summary.returnRate as num);

    final num bankBalance = (summary.bankBalance as num);
    final num stockBalance = (summary.stockBalance as num);
    final num pensionBalance = (summary.pensionBalance as num);
    final double diffFromLastMonth =
        (summary.diffFromLastMonth as num).toDouble();

    // 💡 각 자산별 전월 대비 증감액을 명시적 num 타입으로 가져오기
    final num bankDiff = ((summary.bankDiffFromLastMonth ?? 0) as num);
    final num stockDiff = ((summary.stockDiffFromLastMonth ?? 0) as num);
    final num pensionDiff = ((summary.pensionDiffFromLastMonth ?? 0) as num);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCard(
            title: '총 자산 평가액',
            mainAmountText: totalValuation.toWon(),
            principalText: totalInvested.toWon(),
            profitLossWidget: Row(
              mainAxisSize:
                  MainAxisSize.min, // 💡 크기를 최소화하여 우측 정렬이 원활하게 작동하도록 함
              mainAxisAlignment: MainAxisAlignment.end, // 💡 핵심: 우측으로 정렬
              children: [
                profitOrLoss.toSignedPriceText(
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                returnRate.toSignedPercentText(
                  isDarkCard: true,
                  withParentheses: true,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            diffFromLastMonthWidget: diffFromLastMonth.toSignedPriceText(
              isDarkCard: true,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),

          const SectionTitle('자산별 현황', topSpacing: 24, bottomSpacing: 12),

          GridView.count(
            crossAxisCount: context.isMobile ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: context.isMobile ? 1.8 : 2.5,
            children: [
              AssetGridCard(
                icon: Icons.account_balance,
                backgroundColor: Colors.blue.shade100,
                iconColor: Colors.blue.shade800,
                title: '은행 잔액',
                amountWon: bankBalance.toWon(),
                diffWidget: bankDiff.toSignedPriceText(
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AssetGridCard(
                icon: Icons.show_chart,
                backgroundColor: Colors.orange.shade100,
                iconColor: Colors.orange.shade800,
                title: '증권 평가액',
                amountWon: stockBalance.toWon(),
                diffWidget: stockDiff.toSignedPriceText(
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AssetGridCard(
                icon: Icons.savings,
                backgroundColor: Colors.green.shade100,
                iconColor: Colors.green.shade800,
                title: '연금 평가액',
                amountWon: pensionBalance.toWon(),
                diffWidget: pensionDiff.toSignedPriceText(
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SectionTitle('자산 비중', topSpacing: 28, bottomSpacing: 12),
          _buildAssetRatioChartCard(summary),
        ],
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
