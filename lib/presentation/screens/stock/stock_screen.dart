import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  // 기본 선택 월 (현재 년월, 예: '2026-10')
  late String _selectedYearMonth;

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // 1. 데이터 프로바이더 감시
    final balancesAsync = ref.watch(monthlyStockBalanceNotifierProvider(_selectedYearMonth));
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 자산 관리'),
        actions: [
          // 기준월 변경 버튼 또는 드롭다운 등 배치 가능
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // 월 선택 다이얼로그 혹은 피커 호출 로직 구현 가능
            },
          ),
        ],
      ),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로딩 실패: $err')),
        data: (balances) {
          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          // 맵 변환 (빠른 매핑용)
          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};

          // 2. 대시보드 지표 계산 (총 평가액, 원금, 손익 등)
          double totalBalance = 0.0;
          double totalPrincipal = 0.0;
          double totalPayout = 0.0;
          double totalWithdrawal = 0.0;

          for (var b in balances) {
            totalBalance += b.balance;
            totalPrincipal += b.principal;
            totalPayout += b.totalPayout;
            totalWithdrawal += b.totalWithdrawal;
          }

          final totalProfitOrLoss = (totalBalance + totalPayout + totalWithdrawal) - totalPrincipal;
          final totalReturnRate = totalPrincipal > 0 ? (totalProfitOrLoss / totalPrincipal) * 100 : 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(monthlyStockBalanceNotifierProvider(_selectedYearMonth));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 💡 [상단 대시보드 카드]
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedYearMonth 주식 총 자산',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Chip(
                            label: Text(_selectedYearMonth, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            labelStyle: const TextStyle(color: Colors.white),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalBalance.toCommaString()} 원',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDashboardItem('투자 원금', '${totalPrincipal.toCommaString()} 원'),
                          _buildDashboardItem(
                            '평가 손익',
                            '${totalProfitOrLoss >= 0 ? '+' : ''}${totalProfitOrLoss.toCommaString()} 원',
                            color: totalProfitOrLoss >= 0 ? Colors.red.shade200 : Colors.blue.shade200,
                          ),
                          _buildDashboardItem(
                            '누적 수익률',
                            '${totalReturnRate >= 0 ? '+' : ''}${totalReturnRate.toStringAsFixed(2)}%',
                            color: totalReturnRate >= 0 ? Colors.red.shade200 : Colors.blue.shade200,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 💡 [종목별/계좌별 보유 현황 리스트 헤더]
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '보유 종목 상세 내역',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: 월말 주식 데이터 입력 다이얼로그 호출
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('월말 데이터 입력'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 💡 [보유 종목 리스트 뷰]
                if (balances.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('해당 월에 등록된 주식 데이터가 없습니다.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: balances.length,
                    itemBuilder: (context, index) {
                      final item = balances[index];
                      final account = accountMap[item.accountId];
                      final accountName = account != null ? accountNameMap[account.accountNameId] : null;
                      final stock = stockItemMap[item.stockItemId];

                      final accDisplayName = '${account?.financialInstitution ?? '기관'} - ${accountName?.accountName ?? '계좌'}';
                      final stockName = stock?.name ?? '알 수 없는 종목';
                      final symbol = stock?.symbolCode ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stockName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    '${item.balance.toCommaString()} 원',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$accDisplayName ($symbol)',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('수량: ${item.quantity.toCommaString()} 주', style: const TextStyle(fontSize: 13)),
                                  Text('현재가: ${item.currentPrice.toCommaString()} 원', style: const TextStyle(fontSize: 13)),
                                  Text(
                                    '수익률: ${item.returnRate >= 0 ? '+' : ''}${item.returnRate.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: item.returnRate >= 0 ? Colors.red : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}