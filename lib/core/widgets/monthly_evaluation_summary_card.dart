import 'package:flutter/material.dart';

import '../utils/responsive_extension.dart';
import 'jtext.dart';

class EvaluationMetric {
  final String label;
  final String value;

  const EvaluationMetric({required this.label, required this.value});
}

class MonthlyEvaluationSummaryCard extends StatelessWidget {
  final String title;
  final String? badgeText;
  final String totalBalanceText;
  final String principalText;
  final Widget profitLossRowWidget;
  final List<EvaluationMetric> detailMetrics;
  final Widget diffFromLastMonthWidget;

  const MonthlyEvaluationSummaryCard({
    super.key,
    required this.title,
    this.badgeText,
    required this.totalBalanceText,
    required this.principalText,
    required this.profitLossRowWidget,
    required this.detailMetrics,
    required this.diffFromLastMonthWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),

              // 환율
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText!,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // 총 자산 금액 (별도 줄)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              totalBalanceText,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // 총 투자 원금 & 평가 손익(수익률)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 투자 원금',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              JText(
                principalText, 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: true,
              ),
            ],
          ),
          SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '평가손익(수익률)',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              profitLossRowWidget,
            ],
          ),

          if (detailMetrics.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < detailMetrics.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _MetricColumn(
                      label: detailMetrics[i].label,
                      value: detailMetrics[i].value,
                      crossAxisAlignment:
                          i == 0
                              ? CrossAxisAlignment.start
                              : i == detailMetrics.length - 1
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),

          Row(
            children: [
              const Text(
                '전월 대비: ',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              diffFromLastMonthWidget,
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _MetricColumn({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        JText(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: true,
        ),
      ],
    );
  }
}
