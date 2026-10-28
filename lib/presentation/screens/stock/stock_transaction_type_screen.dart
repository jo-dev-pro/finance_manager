import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/stock/stock_transaction_type.dart';
import '../../../providers/stock/stock_item_provider.dart';
import '../../../providers/stock/stock_transaction_type_provider.dart';
import 'widget/stock_transaction_type_dialog.dart';

class StockTransactionTypeScreen extends ConsumerWidget {
  const StockTransactionTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockTransactionTypeState = ref.watch(
      stockTransactionTypeNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 거래구분 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 25),
            color: Colors.grey.shade700,
            padding: EdgeInsets.zero, // 기본 패딩 제거
            constraints: const BoxConstraints(), // 최소 48x48 제약 제거
            onPressed: () => _showAddDialog(context),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: stockTransactionTypeState.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                '등록된 내용이 없습니다.\n하단의 + 버튼을 눌러 추가해 보세요.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isAmountSign = item.amountSign == 'PLUS';
              final isQuantitySign = item.quantitySign == 'PLUS';
 
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 필요한 만큼만 공간 차지
                    children: [
                      // 💡 금액 부호 표시 뱃지 (+ / -)
                      Column(
                        children: [
                          Container(
                            width: 95,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isAmountSign
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isAmountSign
                                        ? Colors.red.shade200
                                        : Colors.blue.shade200,
                              ),
                            ),
                            child: Text(
                              '금액 ${item.amountSign}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isAmountSign
                                        ? Colors.red.shade700
                                        : Colors.blue.shade700,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),

                          Container(
                            width: 95,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isQuantitySign
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isQuantitySign
                                        ? Colors.red.shade200
                                        : Colors.blue.shade200,
                              ),
                            ),
                            child: Text(
                              '수량 ${item.quantitySign}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isQuantitySign
                                        ? Colors.red.shade700
                                        : Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          item.typeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 수정 & 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.grey.shade700,
                        padding: EdgeInsets.zero, // 기본 패딩 제거
                        constraints: const BoxConstraints(), // 최소 48x48 제약 제거
                        onPressed: () => _showEditDialog(context, item),
                      ),
                      const SizedBox(width: 8),

                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                        padding: EdgeInsets.zero, // 기본 패딩 제거
                        constraints: const BoxConstraints(), // 최소 48x48 제약 제거
                        onPressed: () => _confirmDelete(context, ref, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('오류 발생: $e')),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 시트가 밀려 올라오도록 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StockTransactionTypeDialog(),
    );
  }

  void _showEditDialog(BuildContext context, StockTransactionType item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 시트가 밀려 올라오도록 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StockTransactionTypeDialog(initialData: item),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StockTransactionType item,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('삭제 확인'),
            content: Text('\'${item.typeName}\' 거래구분을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (item.id != null) {
                    ref
                        .read(stockItemNotifierProvider.notifier)
                        .deleteStockItem(item.id!);
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
