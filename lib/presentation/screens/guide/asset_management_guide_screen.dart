import 'package:flutter/material.dart';

import '../../../core/widgets/main_constrainedbox.dart';

class AssetManagementGuideScreen extends StatelessWidget {
  const AssetManagementGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('자산 관리 앱 사용 가이드'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: '개요 & DB규칙'),
              Tab(icon: Icon(Icons.account_balance), text: '은행 계좌'),
              Tab(icon: Icon(Icons.savings), text: '연금 계좌'),
              Tab(icon: Icon(Icons.show_chart), text: '주식 계좌'),
            ],
          ),
        ),
        body: MainConstrainedBox(
          child: const TabBarView(
            children: [
              _OverviewGuideTab(),
              _BankGuideTab(),
              _PensionGuideTab(),
              _StockGuideTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1. 전체 개요 및 DB 명명 규칙 탭
class _OverviewGuideTab extends StatelessWidget {
  const _OverviewGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionCard(
          title: '📌 자산 관리 시스템 개요',
          color: Colors.teal,
          child: const Text(
            '본 앱은 은행(현금), 연금, 주식 3가지 자산 영역을 매월 말 스냅샷(기준년월) 기반으로 추적하고 관리합니다.\n\n'
            '동일한 달에 데이터를 다시 저장하더라도 덮어쓰기(Merge) 방식으로 최신 상태가 유지되며, 전달 데이터를 자동으로 불러와 편리하게 수정할 수 있습니다.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: '🗂️ Firestore DB 컬렉션 및 문서 ID 규칙',
          color: Colors.indigo,
          child: Column(
            children: const [
              _RuleItem(
                domain: '은행 계좌 월말',
                collection: 'monthly_bank_balance',
                rule: 'YYYY-MM_계정ID',
                desc: '계좌별 월말 현금 잔액 저장',
              ),
              Divider(),
              _RuleItem(
                domain: '연금 계좌 요약',
                collection: 'monthly_pension_account_balance',
                rule: 'YYYY-MM_계정ID',
                desc: '계좌 공통 예수금 및 월 인출액',
              ),
              Divider(),
              _RuleItem(
                domain: '연금 상품별 월말',
                collection: 'monthly_pension_balance',
                rule: 'YYYY-MM_계정ID_상품ID',
                desc: '상품별 평가액, 원금, 수령액',
              ),
              Divider(),
              _RuleItem(
                domain: '주식 계좌 요약',
                collection: 'monthly_stock_account_balance',
                rule: 'YYYY-MM_계정ID',
                desc: '주식 계좌별 요약 현황',
              ),
              Divider(),
              _RuleItem(
                domain: '주식 종목별 월말',
                collection: 'monthly_stock_balance',
                rule: 'YYYY-MM_계정ID_종목ID',
                desc: '종목별 평가액, 수량, 매수일',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 2. 은행 계좌 가이드 탭
class _BankGuideTab extends StatelessWidget {
  const _BankGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionCard(
          title: '🏦 은행 계좌 관리 가이드',
          color: Colors.blue.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _GuideStepItem(
                step: '1',
                title: '기준월 선택',
                content: '상단에서 작성하고자 하는 기준년월(예: 2026-03)을 확인하거나 입력합니다.',
              ),
              _GuideStepItem(
                step: '2',
                title: '월말 잔액 입력',
                content: '보유한 입출금 통장, 예금, 적금 계좌의 해당 월말 최종 잔액을 입력합니다.',
              ),
              _GuideStepItem(
                step: '3',
                title: '저장 및 갱신',
                content: '저장 시 YYYY-MM_계정ID로 저장됩니다. 추후 금액 변경 시 기존 데이터를 자동으로 불러오므로 수정된 부분만 입력 후 저장하면 덮어쓰기됩니다.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 3. 연금 계좌 가이드 탭
class _PensionGuideTab extends StatelessWidget {
  const _PensionGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionCard(
          title: '🛡️ 연금 계좌 관리 가이드',
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _GuideStepItem(
                step: '1',
                title: '계좌 공통 현금성 자산 (예수금) 입력',
                content: 'IRP, 연금저축 계좌 상단의 민트색 카드 영역에서 계좌 내 미투자 예수금(현금성 잔액)과 당월 인출액을 입력합니다.',
              ),
              _GuideStepItem(
                step: '2',
                title: '개별 투자 상품 평가액 입력',
                content: '하단 리스트에서 실제 보유 중인 펀드/ETF 상품의 당월 평가액(또는 좌수/기준가), 누적 원금을 입력합니다.',
              ),
              _GuideStepItem(
                step: '3',
                title: '현금성자산 상품 분리 규칙',
                content: '개별 상품 목록의 "현금성자산"은 중복 계산 방지를 위해 제거되며, 계좌 공통 예수금 필드로 통합 관리됩니다.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 4. 주식 계좌 가이드 탭
class _StockGuideTab extends StatelessWidget {
  const _StockGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionCard(
          title: '📈 주식 계좌 관리 가이드',
          color: Colors.orange.shade800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _GuideStepItem(
                step: '1',
                title: '주식 계좌 요약 관리',
                content: '주식 계좌별 전체 월말 잔액 및 요약 정보를 관리합니다 (monthly_stock_account_balance).',
              ),
              _GuideStepItem(
                step: '2',
                title: '종목별 포트폴리오 관리',
                content: '계좌에 속한 보유 종목별로 당월 평가액, 보유 수량, 평단가, 매수일 정보를 기록합니다 (monthly_stock_balance).',
              ),
              _GuideStepItem(
                step: '3',
                title: '고유 문서 ID 정렬',
                content: 'YYYY-MM_계정ID_종목ID 형식으로 데이터가 저장되어, 월별 포트폴리오 변동 내역 및 자산 성장 추이를 직관적으로 분석할 수 있습니다.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets
// -----------------------------------------------------------------------------

Widget _buildSectionCard({
  required String title,
  required Color color,
  required Widget child,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    ),
  );
}

class _RuleItem extends StatelessWidget {
  final String domain;
  final String collection;
  final String rule;
  final String desc;

  const _RuleItem({
    required this.domain,
    required this.collection,
    required this.rule,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(domain, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rule,
                  style: TextStyle(fontSize: 11, color: Colors.indigo.shade800, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('• 컬렉션: $collection', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text('• 설명: $desc', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _GuideStepItem extends StatelessWidget {
  final String step;
  final String title;
  final String content;

  const _GuideStepItem({
    required this.step,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.teal.shade100,
            child: Text(step, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(content, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}