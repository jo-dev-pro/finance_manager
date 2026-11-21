import 'package:flutter/material.dart';

import '../../../core/utils/responsive_extension.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';

class AssetManagementGuideScreen extends StatelessWidget {
  const AssetManagementGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: MainAppBar(
          titleText: '자산 관리 앱 사용 가이드',
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorColor: context.primaryColor,
            labelColor: context.primaryColor,
            unselectedLabelColor: Colors.grey,
            labelPadding: EdgeInsets.symmetric(horizontal: 28),
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'DB규칙'),
              Tab(icon: Icon(Icons.account_balance), text: '은행'),
              Tab(icon: Icon(Icons.show_chart), text: '증권'),
              Tab(icon: Icon(Icons.savings), text: '연금'),
            ],
          ),
        ),
        body: MainConstrainedBox(
          child: const TabBarView(
            children: [
              _OverviewGuideTab(),
              _BankGuideTab(),
              _StockGuideTab(),
              _PensionGuideTab(),
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
      children: [
        SizedBox(height: 16),
        _buildSectionCard(
          title: '📌 자산 관리 시스템 개요',
          color: context.primaryColor,
          child: const Text(
            '본 앱은 은행(현금), 연금, 주식 3가지 자산 영역을 매월 말 스냅샷(기준년월) 기반으로 추적하고 관리합니다.\n\n'
            '동일한 달에 데이터를 다시 저장하더라도 덮어쓰기(Merge) 방식으로 최신 상태가 유지되며, 전월 데이터를 자동으로 불러와 편리하게 입력·수정할 수 있습니다.',
            style: TextStyle(fontSize: 14, height: 1.55),
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
                accentColor: Colors.indigo,
              ),
              Divider(height: 16),
              _RuleItem(
                domain: '연금 계좌 요약',
                collection: 'monthly_pension_account_balance',
                rule: 'YYYY-MM_계정ID',
                desc: '계좌 공통 예수금 및 월 입금·인출액',
                accentColor: Colors.indigo,
              ),
              Divider(height: 16),
              _RuleItem(
                domain: '연금 상품별 월말',
                collection: 'monthly_pension_balance',
                rule: 'YYYY-MM_계정ID_상품ID',
                desc: '상품별 평가액, 원금, 매도·수령액',
                accentColor: Colors.indigo,
              ),
              Divider(height: 16),
              _RuleItem(
                domain: '주식 계좌 요약',
                collection: 'monthly_stock_account_balance',
                rule: 'YYYY-MM_계정ID',
                desc: '주식 계좌별 월말 요약 현황 및 환율',
                accentColor: Colors.indigo,
              ),
              Divider(height: 16),
              _RuleItem(
                domain: '주식 종목별 월말',
                collection: 'monthly_stock_balance',
                rule: 'YYYY-MM_계정ID_종목ID',
                desc: '종목별 평가액, 수량, 배당 및 매도 내역',
                accentColor: Colors.indigo,
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
    final accent = Colors.blue.shade700;

    return ListView(
      children: [
              SizedBox(height: 16),
        _buildSectionCard(
          title: '🏦 은행 계좌 관리 가이드',
          color: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuideStepItem(
                step: '1',
                title: '기준월 선택',
                content: '상단에서 작성하고자 하는 기준년월(예: 2026-11)을 선택하거나 확인합니다.',
                accentColor: accent,
              ),
              _GuideStepItem(
                step: '2',
                title: '월말 잔액 입력',
                content: '보유한 입출금 통장, 예금, 적금 계좌의 해당 월말 최종 잔액을 입력합니다.',
                accentColor: accent,
              ),
              _GuideStepItem(
                step: '3',
                title: '저장 및 갱신',
                content:
                    '저장 시 YYYY-MM_계정ID 문서 ID로 기록됩니다. 추후 금액 변경 시 기존 데이터를 불러와 수정한 뒤 저장하면 최신 상태로 갱신됩니다.',
                accentColor: accent,
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
    final accent = Colors.teal.shade700;

    return ListView(
      children: [
              SizedBox(height: 16),
        _buildSectionCard(
          title: '🛡️ 연금 계좌 관리 가이드',
          color: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuideStepItem(
                step: '1',
                title: '계좌 공통 현금성 자산 (예수금) 입력',
                content:
                    'IRP, 연금저축 계좌 상단의 현금성 자산 영역에서 계좌 내 예수금(현금성 잔액)과 당월 입금·인출액을 입력합니다.',
                accentColor: accent,
              ),
              _GuideStepItem(
                step: '2',
                title: '개별 투자 상품 평가액 입력',
                content:
                    '보유 중인 펀드·ETF 상품별로 당월 평가액(또는 보유 좌수/기준가), 당월 입금액·매도액을 입력합니다.',
                accentColor: accent,
              ),
              _GuideStepItem(
                step: '3',
                title: '현금성 자산 분리 관리',
                content:
                    '중복 집계를 막기 위해 계좌 공통 예수금은 계좌 요약 영역에서 관리하고, 개별 투자 상품 평가액과 합산해 총 연금 자산을 계산합니다.',
                accentColor: accent,
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
    final accent = Colors.red.shade800;

    return ListView(
      children: [
              SizedBox(height: 16),
        _buildSectionCard(
          title: '📈 주식 계좌 관리 가이드',
          color: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuideStepItem(
                step: '1',
                title: '주식 계좌 요약 관리',
                content:
                    '계좌별 예수금, 원금, 입출금 및 외화 계좌 환율 정보를 관리합니다 (monthly_stock_account_balance).',
                accentColor: accent,
              ),
              _GuideStepItem(
                step: '2',
                title: '종목별 포트폴리오 관리',
                content:
                    '보유 종목별로 당월 평가액, 보유 수량, 현재가, 당월/누적 배당 및 매도 내역을 기록합니다 (monthly_stock_balance).',
                accentColor: accent,
              ),
              _GuideStepItem(
                step: '3',
                title: '월별 추이 및 평가 분석',
                content:
                    'YYYY-MM_계정ID_종목ID 기준으로 저장된 스냅샷을 통해 전월 대비 변동, 계좌별 비중, 월말 수익률 추이를 확인할 수 있습니다.',
                accentColor: accent,
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
    elevation: 1,
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
          const Divider(height: 18),
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
  final Color accentColor;

  const _RuleItem({
    required this.domain,
    required this.collection,
    required this.rule,
    required this.desc,
    this.accentColor = Colors.indigo,
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
              Flexible(
                child: Text(
                  domain,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  rule,
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• 컬렉션: $collection',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 2),
          Text(
            '• 설명: $desc',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _GuideStepItem extends StatelessWidget {
  final String step;
  final String title;
  final String content;
  final Color accentColor;

  const _GuideStepItem({
    required this.step,
    required this.title,
    required this.content,
    this.accentColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              step,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: accentColor,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
