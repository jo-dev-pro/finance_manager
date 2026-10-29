import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../models/stock/stock_holding_item.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/stock/stock_holding_item_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widget/stock_holding_item_dialog.dart';

class StockHoldingItemScreen extends ConsumerWidget {
  const StockHoldingItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingItemsState = ref.watch(stockHoldingItemNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌별 보유 주식 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 25),
            color: Colors.grey.shade700,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showAddBottomSheet(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: holdingItemsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                '등록된 보유 주식 내역이 없습니다.\n우측 상단의 + 버튼을 눌러 추가해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockMap = {for (var s in stockItems) s.id!: s};

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(stockHoldingItemNotifierProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                final matchedAcc = accountMap[item.accountId];
                final institution = matchedAcc?.financialInstitution ?? '기타 증권사';
                final nameObj = matchedAcc != null ? accountNameMap[matchedAcc.accountNameId] : null;
                final accountName = nameObj?.accountName ?? '주식계좌';

                final matchedStock = stockMap[item.stockItemId];
                // 💡 수정된 StockItem 모델 필드명(itemName, stockCode, yahooName) 반영
                final stockName = matchedStock?.itemName ?? '알 수 없는 종목';
                final stockSymbol = matchedStock?.stockCode ?? '';
                final market = matchedStock?.yahooName ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (market.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          market,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        stockName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '[$institution] $accountName${stockSymbol.isNotEmpty ? ' • $stockSymbol' : ''}${item.purchaseDate != null ? ' • ${item.purchaseDate}' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.principal.toWon(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 19,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => _showEditBottomSheet(context, item),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 19,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _confirmDelete(context, ref, item, stockName),
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
          );
        },
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const StockHoldingItemDialog(),
    );
  }

  void _showEditBottomSheet(BuildContext context, StockHoldingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StockHoldingItemDialog(initialData: item),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, StockHoldingItem item, String stockName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('\'$stockName\' 보유 주식 내역을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (item.id != null) {
                ref.read(stockHoldingItemNotifierProvider.notifier).deleteStockHoldingItem(item.id!);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}