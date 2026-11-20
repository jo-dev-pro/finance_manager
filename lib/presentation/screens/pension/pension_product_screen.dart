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
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('연금상품 등록'),
          ),
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

          return MainConstrainedBox(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];

                return Padding(
                  padding: const EdgeInsets.all(16),
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
                     EditDeleteButtons(
                      onEdit: () => _showDialog(context, product: item),
                      onDelete: () => _confirmDelete(context, ref, item),
                    ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('오류 발생: $e')),
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
