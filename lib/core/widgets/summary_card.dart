import 'package:finance_manager/core/utils/responsive_extension.dart';
import 'package:flutter/material.dart';

import 'jtext.dart';

// 각 탭별 상단의 요약 카드 (모바일/데스크톱 반응형 대응)
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
          JText(
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

            // 💡 LayoutBuilder를 사용하여 화면 폭에 따라 Row/Column 자동 분기 (모바일 잘림 방지)
            LayoutBuilder(
              builder: (context, constraints) {
                if (context.isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (principalText != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '총 투자 원금',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Flexible(
                              child: JText(
                                principalText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // 폰트 크기를 살짝 조절하여 오버플로우 방지
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (principalText != null && profitLossWidget != null)
                        const SizedBox(height: 10),

                      if (profitLossWidget != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '평가 손익 (수익률)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            profitLossWidget!,
                          ],
                        ),

                        if (subInfoWidgets != null &&
                            subInfoWidgets!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: subInfoWidgets!,
                          ),
                        ],
                      ],
                    ],
                  );
                }

                // 일반적인 넓은 화면(데스크톱/큰 태블릿)에서는 기존처럼 좌우(Row) 배치 유지
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (principalText != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '총 투자 원금',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                JText(
                                  principalText!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: true,
                                ),
                              ],
                            ),
                          ),
                        if (principalText != null && profitLossWidget != null)
                          const SizedBox(width: 8),
                        if (profitLossWidget != null)
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
                              profitLossWidget!,
                            ],
                          ),
                      ],
                    ),
                    if (subInfoWidgets != null &&
                        subInfoWidgets!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: subInfoWidgets!,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],

          if (diffFromLastMonthWidget != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (context.isMobile) {
                  return Row(
                    children: [
                      Text(
                        '전월 대비: ',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      diffFromLastMonthWidget!,
                    ],
                  );
                }
                return Row(
                  children: [
                    Text(
                      '전월 대비: ',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),

                    diffFromLastMonthWidget!,
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
