import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widget/monthly_stock_dialog.dart';

class MonthlyStockBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyStockBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 연금 화면과 동일하게 전역 selectedYearMonthProvider 연동
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth =
        selectedMonth ??
        initialYearMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final balancesAsync = ref.watch(
      monthlyStockBalanceNotifierProvider(targetMonth),
    );
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('주식 월말 내역 관리')),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text('$targetMonth에 등록된 주식 월말 데이터가 없습니다.'));
          }

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};

          // 총 합계 계산
          double totalBalance = 0;
          double totalPrincipal = 0;
          for (var b in items) {
            totalBalance += b.balance;
            totalPrincipal += b.principal;
          }
          final totalProfit = totalBalance - totalPrincipal;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                monthlyStockBalanceNotifierProvider(targetMonth),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💡 상단 요약 바 카드
                  Card(
                    elevation: 0,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.indigo.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                              '총 평가액', totalBalance.toWon()),
                          _buildSummaryItem(
                              '투자 원금', totalPrincipal.toWon()),
                          _buildSummaryItem(
                            '평가 손익',
                            '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
                            color: totalProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 💡 월말 내역 리스트 (카드 형태 구조 통일)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final account = accountMap[item.accountId];
                      final accountName = account != null
                          ? accountNameMap[account.accountNameId]
                          : null;
                      final stock = stockItemMap[item.stockItemId];

                      final institution = account?.financialInstitution ?? '기타 증권사';
                      final accName = accountName?.accountName ?? '주식계좌';
                      
                      // 💡 모델 변경사항(itemName, stockCode) 반영
                      final stockName = stock?.itemName ?? '알 수 없는 종목';
                      final stockCode = stock?.stockCode ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // 1. 좌측 정보 영역 (종목명 1줄 고정 + 오버플로우 방지)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 상단: 종목명 (1줄)
                                      Text(
                                        stockName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // 하단: [증권사] 계좌명 + 연월 배지 조합
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '[$institution] $accName${stockCode.isNotEmpty ? ' • $stockCode' : ''}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.yearMonth,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 2. 우측 금액 및 수정/삭제 아이콘 영역
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      item.balance.toWon(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 19,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () => _showEditDialog(
                                            context,
                                            ref,
                                            item,
                                            stockName,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 19,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => _confirmDelete(
                                            context,
                                            ref,
                                            item,
                                            stockName,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              '주식 월말 평가액 추가 입력',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () => _showAddDialog(context, targetMonth),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, String currentMonth) {
    showDialog(
      context: context,
      builder: (_) => MonthlyStockBalanceDialog(yearMonth: currentMonth),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MonthlyStockBalance item,
    String stockName,
  ) {
    showDialog(
      context: context,
      builder: (_) => MonthlyStockBalanceDialog(
        yearMonth: item.yearMonth,
        initialData: item,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonthlyStockBalance item,
    String stockName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('$stockName의 ${item.yearMonth} 월말 데이터를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (item.id != null) {
                await ref
                    .read(
                      monthlyStockBalanceNotifierProvider(
                        item.yearMonth,
                      ).notifier,
                    )
                    .deleteBalance(item.id!);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}