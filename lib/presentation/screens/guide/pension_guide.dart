import 'package:flutter/material.dart';

class PensionGuideScreen extends StatelessWidget {
  const PensionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연금 자산 관리 가이드'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핵심 요약 카드
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.indigo.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '계좌별 상품은 건별로 개별 등록하고,\n월말 연금 평가액은 자동으로 합산되어 가볍게 입력합니다!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // STEP 1
            _buildGuideStep(
              stepNumber: '1',
              title: '계좌별 보유 상품 등록 (최초 1회 & 추가 매수 시)',
              subtitle: '매수 건별 개별 등록/관리',
              color: Colors.blue.shade700,
              contents: [
                '같은 계좌, 같은 상품이라도 매수 시기/원금이 다르다면 건별로 각각 등록합니다.',
                '이를 통해 매수일자별 상세 이력과 개별 투자 시점을 정확하게 추적합니다.',
                '등록 항목: 연금 계좌, 연금 상품, 초기 투자 원금, 최초 매수일',
              ],
            ),
            const SizedBox(height: 16),

            // STEP 2
            _buildGuideStep(
              stepNumber: '2',
              title: '월말 연금 자산 입력 (매월 말일)',
              subtitle: '당월 발생액만 간편 입력',
              color: Colors.teal.shade700,
              contents: [
                '동일 계좌의 동일 상품은 자동으로 1줄로 합산되어 표시됩니다.',
                '당월 말 평가액: 해당 월 말일 기준의 총 평가액을 입력합니다.',
                '당월 추가 투자금 / 수령액 / 중도 인출금: 이번 달에 추가로 발생한 금액만 적습니다.',
                '💡 [중도 인출금]: 계좌 밖으로 출금해 간 자금은 인출금에 입력하면 수익률 계산이 왜곡되지 않습니다.',
                '💡 시스템이 이전 달 누적액에 알아서 더해주므로 누적액을 암산할 필요가 없습니다.',
              ],
            ),
            const SizedBox(height: 16),

            // STEP 3
            _buildGuideStep(
              stepNumber: '3',
              title: '수익률 및 자산 현황 확인',
              subtitle: '자동 계산되는 핵심 지표',
              color: Colors.purple.shade700,
              contents: [
                '총 평가손익 = (현재 평가액 + 누적 연금 수령액 + 누적 중도 인출금) - 누적 투자 원금',
                '인출해 간 자금도 회수된 성과로 인정되어 계좌 전체 수익률(%)이 정확하게 유지됩니다.',
                '수익률(%) 및 CAGR(연환산 수익률)이 자동으로 추산되어 표시됩니다.',
                '연금 수령이 완료된 상품은 [종료 상품]으로 체크하여 관리할 수 있습니다.',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required Color color,
    required List<String> contents,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...contents.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}