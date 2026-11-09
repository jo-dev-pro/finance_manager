import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String mainAmountText;
  final String? principalText;
  final Widget? profitLossWidget;
  final List<Widget>? subInfoWidgets;
  final Widget? diffFromLastMonthWidget;
  final EdgeInsetsGeometry? margin;

  const SummaryCard({
    super.key,
    required this.title,
    required this.mainAmountText,
    this.principalText,
    this.profitLossWidget,
    this.subInfoWidgets,
    this.diffFromLastMonthWidget,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            mainAmountText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (principalText != null || profitLossWidget != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (principalText != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '총 투자 원금',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        principalText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                if (profitLossWidget != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '평가 손익 (수익률)',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      profitLossWidget!,
                    ],
                  ),
              ],
            ),
          ],
          if (subInfoWidgets != null && subInfoWidgets!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: subInfoWidgets!,
            ),
          ],
          if (diffFromLastMonthWidget != null) ...[
            const SizedBox(height: 12),
            diffFromLastMonthWidget!,
          ],
        ],
      ),
    );
  }
}