import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_transaction_type.dart';
import '../../providers/stock_item_provider.dart';
import '../../providers/stock_transaction_type_provider.dart';
import '../widgets/stock_transaction_type_dialog.dart';

class StockTransactionTypeScreen extends ConsumerWidget {
  const StockTransactionTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockTransactionTypeState = ref.watch(stockTransactionTypeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('거래구분 관리'),
      ),
      body: stockTransactionTypeState.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                '등록된 내용이 없습니다.\n하단의 + 버튼을 눌러 추가해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.typeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    item.type,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // subtitle: Text('코드: ${item.symbolCode}${item.memo != null ? ' • ${item.memo}' : ''}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showEditDialog(context, item);
                      } else if (val == 'delete') {
                        _confirmDelete(context, ref, item);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('수정')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제', style: TextStyle(color: Colors.red)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const StockTransactionTypeDialog(),
    );
  }

  void _showEditDialog(BuildContext context, StockTransactionType item) {
    showDialog(
      context: context,
      builder: (_) => StockTransactionTypeDialog(initialData: item),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, StockTransactionType item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                ref.read(stockItemNotifierProvider.notifier).deleteStockItem(item.id!);
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