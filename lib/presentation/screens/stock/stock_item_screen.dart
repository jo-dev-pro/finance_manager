import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../models/stock/stock_item.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widgets/stock_item_dialog.dart';

class StockItemScreen extends ConsumerWidget {
  const StockItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockItemsState = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '종목명 관리',
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showDialog(context),
            label: const Text('등록'),
          ),
        ],
      ),

      body: stockItemsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
        data: (items) {
          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Expanded(
                  child:
                      items.isEmpty
                          ? const Center(
                            child: Text(
                              '등록된 종목명이 없습니다.\n상단의 등록 버튼을 눌러 추가해 보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // 💡 시장 구분 뱃지 (yahooName 반영)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          item.yahooName ?? 'KR',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                              
                                      // 💡 종목 정보 (itemName, stockCode, otherName 반영)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.itemName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '코드: ${item.stockCode}${item.otherName.isNotEmpty ? ' • ${item.otherName}' : ''}',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                              
                                      // 수정 & 삭제 버튼
                                      EditDeleteButtons(
                                        onEdit:
                                            () => _showDialog(
                                              context,
                                              item: item,
                                            ),
                                        onDelete:
                                            () => _confirmDelete(
                                              context,
                                              ref,
                                              item,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDialog(BuildContext context, {StockItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StockItemDialog(initialData: item),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, StockItem item) {
    if (item.id == null) return;

    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '\'${item.itemName}\' 종목을 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await ref
              .read(stockItemNotifierProvider.notifier)
              .deleteStockItem(item.id!);

          if (!context.mounted) return;
          AppSnackBar.showInfo(context, '종목이 삭제되었습니다.');
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(context, '삭제 실패: $e');
        }
      },
    );
  }
}
