import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pension/pension_transaction_type.dart';
import '../../../providers/pension/pension_transaction_type_provider.dart';
import 'widget/pension_transaction_type_dialog.dart';

class PensionTransactionTypeScreen extends ConsumerWidget {
  const PensionTransactionTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(pensionTransactionTypeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연금 거래구분 관리')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
      body: typesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류 발생: $err')),
        data: (types) {
          if (types.isEmpty) {
            return const Center(child: Text('등록된 거래구분이 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final type = types[index];

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
                    children: [
                      Expanded(
                        child: Text(
                          type.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: type.isActive ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 수정 & 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.grey.shade700,
                        onPressed: () => _showFormDialog(context, type: type),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                        onPressed: () => _confirmDelete(context, ref, type.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showFormDialog(BuildContext context, {PensionTransactionType? type}) {
    showDialog(
      context: context,
      builder: (_) => PensionTransactionTypeFormDialog(type: type),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String? id) {
    if (id == null) return;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('해당 거래구분을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  await ref
                      .read(pensionTransactionTypeNotifierProvider.notifier)
                      .deletePensionTransactionType(id);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }
}
