import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/pension/pension_product.dart';
import '../../../providers/pension/pension_product_provider.dart';
import 'widget/pension_product_dialog.dart';

class PensionProductScreen extends ConsumerWidget {
  const PensionProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연금상품 관리'),
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
      body: productsState.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                '등록된 연금상품이 없습니다.\n하단의 + 버튼을 눌러 추가해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 수정 & 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.grey.shade700,
                         padding: EdgeInsets.zero, // 기본 패딩 제거
                                      constraints:
                                          const BoxConstraints(), // 최소 48x48 제약 제거
                        onPressed: () => _showEditDialog(context, item),
                      ),
                      const SizedBox(width: 8),

                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                         padding: EdgeInsets.zero, // 기본 패딩 제거
                                      constraints:
                                          const BoxConstraints(), // 최소 48x48 제약 제거
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
      isScrollControlled: true, // 키보드가 올라올 때 밀려 올라가도록 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PensionProductDialog(),
    );
  }

  void _showEditDialog(BuildContext context, PensionProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 밀려 올라가도록 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PensionProductDialog(initialData: product),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PensionProduct product,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('삭제 확인'),
            content: Text('\'${product.productName}\' 상품을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  if (product.id != null) {
                    ref
                        .read(pensionProductNotifierProvider.notifier)
                        .deletePensionProduct(product.id!);
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
