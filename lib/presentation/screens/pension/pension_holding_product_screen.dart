import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../models/pension/pension_holding_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import 'widget/pension_holding_product_dialog.dart';

class PensionHoldingProductScreen extends ConsumerWidget {
  const PensionHoldingProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountProductsAsync = ref.watch(pensionHoldingProductNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌별 연금상품 관리'),
      ),
      body: accountProductsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('오류 발생: $err')),
        data: (accountProducts) {
          if (accountProducts.isEmpty) {
            return const Center(
              child: Text(
                '등록된 계좌별 연금상품이 없습니다.\n하단의 + 버튼을 눌러 추가해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final products = productsAsync.value ?? [];

          final accountNameMap = {for (var an in accountNames) an.id: an};
          final accountMap = {for (var acc in accounts) acc.id!: acc};
          final productMap = {for (var prod in products) prod.id!: prod.productName};

          // 💡 계좌의 sortOrder를 반영하여 보유 상품 목록 정렬
          final sortedAccountProducts = [...accountProducts];
          sortedAccountProducts.sort((a, b) {
            final accA = accountMap[a.accountId];
            final accB = accountMap[b.accountId];
            final orderA = accA?.sortOrder ?? 999;
            final orderB = accB?.sortOrder ?? 999;
            return orderA.compareTo(orderB);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedAccountProducts.length,
            itemBuilder: (context, index) {
              final item = sortedAccountProducts[index];
              
              final matchedAcc = accountMap[item.accountId];
              final institution = matchedAcc?.financialInstitution ?? '기타 금융기관';
              final nameObj = matchedAcc != null ? accountNameMap[matchedAcc.accountNameId] : null;
              final accountName = nameObj?.accountName ?? '연금계좌';
              
              final productName = productMap[item.productId] ?? '알 수 없는 상품';

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[$institution] $accountName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '원금: ${item.principal.toWon()}',
                                  style: const TextStyle(fontSize: 13, color: Colors.indigo, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '매수일: ${item.purchaseDate ?? '미입력'}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.grey.shade700,
                        onPressed: () => _showEditDialog(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                        onPressed: () => _confirmDelete(context, ref, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('상품 매칭 등록'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const PensionHoldingProductDialog(),
    );
  }

  void _showEditDialog(BuildContext context, PensionHoldingProduct item) {
    showDialog(
      context: context,
      builder: (_) => PensionHoldingProductDialog(initialData: item),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PensionHoldingProduct item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('해당 계좌의 상품 매칭 정보를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (item.id != null) {
                await ref
                    .read(pensionHoldingProductNotifierProvider.notifier)
                    .deletePensionHoldingProduct(item.id!);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}