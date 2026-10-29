import 'package:flutter/material.dart';

class StockGuideScreen extends StatelessWidget {
  const StockGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 자산 관리 가이드'),
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
                        '복잡한 거래 내역(매수/매도) 입력 대신,\n매월 말일 기준의 보유 수량과 현재가만 스냅샷으로 가볍게 관리합니다!',
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
              title: '계좌별 보유 종목 및 투자 원금 관리',
              subtitle: '증권 계좌와 종목 매칭 & 투자 원금 등록',
              color: Colors.blue.shade700,
              contents: [
                '어느 증권 계좌(Account)에 어떤 주식 종목(StockItem)을 보유하고 있는지 매칭합니다.',
                '종목별 초기 매수 원금(Principal)과 최초 매수일을 기록하여 투자 기준점을 잡습니다.',
                '유상증자나 추가 매수 발생 시 원금(Principal) 금액을 업데이트해 평균단가 산정 기준을 유지합니다.',
              ],
            ),
            const SizedBox(height: 16),

            // STEP 2
            _buildGuideStep(
              stepNumber: '2',
              title: '월말 주식 현황 입력 (매월 말일 스냅샷)',
              subtitle: '보유 수량 및 현재가 간편 입력',
              color: Colors.teal.shade700,
              contents: [
                '개별 매수/매도 거래 내역을 일일이 기록할 필요 없이 말일 기준 현황만 입력합니다.',
                '입력 항목: 보유 수량(Quantity), 말일 기준 현재가(Current Price)',
                '시스템이 자동으로 월말 평가액(Balance = 수량 × 현재가)을 산출합니다.',
                '💡 [무상증자/주식배당]: 주식 수량이 늘어난 경우 보유 수량만 수정해 주면 됩니다.',
                '💡 [유상증자]: 추가 납입된 금액만큼 원금을 올리고 수량을 늘려 반영합니다.',
              ],
            ),
            const SizedBox(height: 16),

            // STEP 3
            _buildGuideStep(
              stepNumber: '3',
              title: '손익, 수익률 및 평균단가 자동 확인',
              subtitle: '스냅샷 데이터 기반 자동 지표 추산',
              color: Colors.purple.shade700,
              contents: [
                '평가 손익 = 월말 평가액(Balance) - 투자 원금(Principal)',
                '수익률(%) = (평가 손익 / 투자 원금) × 100',
                '평균 단가 = 투자 원금(Principal) / 보유 수량(Quantity)',
                '계좌 전체 주식 평가액은 종목별 평가액의 합산으로 자동 집계되어 대시보드에 반영됩니다.',
              ],
            ),
            const SizedBox(height: 16),

            // STEP 4
            _buildGuideStep(
              stepNumber: '4',
              title: '자산 관리 모범 활용 팁 & 유의사항',
              subtitle: '실질 수익률 관리 및 예수금 처리',
              color: Colors.orange.shade800,
              contents: [
                '💡 [거래 비용/수수료]: 매수 시 발생한 수수료나 세금은 투자 원금에 합산하여 입력하면 더욱 보수적이고 정확한 실질 수익률 추적이 가능합니다.',
                '💡 [예수금/현금 잔고]: 주식 계좌 내 예수금은 현금성 자산 항목(예: 계좌 공통 예수금)으로 등록하여 계좌 전체 자산과 함께 관리할 수 있습니다.',
                '💡 [전량 매도 종목]: 매도가 완료된 종목은 보유 종목에서 [종료/매도 완료] 상태로 전환해 깔끔하게 관리합니다.',
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