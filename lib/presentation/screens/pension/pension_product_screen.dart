import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../models/pension/pension_product.dart';
import '../../../providers/pension/pension_product_provider.dart';
import 'widgets/pension_product_dialog.dart';

class PensionProductScreen extends ConsumerWidget {
  const PensionProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '연금상품 관리',
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showDialog(context),
            label: const Text('등록'),
          ),
        ],
      ),

      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
        data: (products) {
          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child:
                      products.isEmpty
                          ? const Center(
                            child: Text(
                              '등록된 연금상품이 없습니다.\n상단의 등록 버튼을 눌러 추가해 보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final item = products[index];

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
                                      EditDeleteButtons(
                                        onEdit:
                                            () => _showDialog(
                                              context,
                                              product: item,
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

  void _showDialog(BuildContext context, {PensionProduct? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    if (product.id == null) return;

    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '\'${product.productName}\' 연금상품을 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await ref
              .read(pensionProductNotifierProvider.notifier)
              .deletePensionProduct(product.id!);

          if (!context.mounted) return;
          AppSnackBar.showInfo(context, '연금상품이 삭제되었습니다.');
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(context, '삭제 실패: $e');
        }
      },
    );
  }
}
