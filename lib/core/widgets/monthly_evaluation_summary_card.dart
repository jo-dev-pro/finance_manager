import 'package:flutter/material.dart';

import '../utils/responsive_extension.dart';
import 'jtext.dart';

class EvaluationMetric {
  final String label;
  final String value;

  const EvaluationMetric({
    required this.label,
    required this.value,
  });
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (badgeText != null && badgeText!.isNotEmpty)
                JText(
                  badgeText!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 6),
          JText(
            totalBalanceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // 총 투자 원금 & 평가 손익(수익률)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _MetricColumn(
                  label: '총 투자 원금',
                  value: principalText,
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '평가 손익 (수익률)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  profitLossRowWidget,
                ],
              ),
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
                      isMobile: isMobile,
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
  final bool isMobile;
  final CrossAxisAlignment crossAxisAlignment;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.isMobile,
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