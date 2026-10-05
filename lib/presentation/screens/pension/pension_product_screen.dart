import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/pension/pension_product.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/pension/pension_product_provider.dart';
import 'widget/pension_product_dialog.dart';

class PensionProductScreen extends ConsumerWidget {
  const PensionProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(pensionProductNotifierProvider);
    final accountState = ref.watch(accountNotifierProvider);
    final accountNameState = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연금상품 관리')),
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

          return accountState.when(
            data: (accounts) {
              final accountNames = accountNameState.value ?? [];
              final accountMap = {for (var acc in accounts) acc.id: acc};
              final accountNameMap = {for (var an in accountNames) an.id: an};

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  final isActive =
                      item.status == '활동' || item.status == 'ACTIVE';

                  // accountId로 계좌를 찾은 후 accountNameId로 계좌명 조회
                  final matchedAccount = accountMap[item.accountId];
                  final matchedAccountName = matchedAccount != null
                      ? accountNameMap[matchedAccount.accountNameId]
                      : null;

                  final displayName = matchedAccountName?.accountName ?? '알 수 없는 계좌';
                  final institution = matchedAccount?.financialInstitution ?? '';
                  final accountDisplay = institution.isNotEmpty
                      ? '$institution - $displayName'
                      : displayName;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.shade50
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.shade200
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          isActive ? '운용중' : '중단',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.green.shade800
                                : Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('계좌: $accountDisplay'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditDialog(context, item);
                          } else if (val == 'delete') {
                            _confirmDelete(context, ref, item);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('수정'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('계좌 정보를 불러오는 중 오류 발생: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('오류 발생: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('상품 추가'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const PensionProductDialog());
  }

  void _showEditDialog(BuildContext context, PensionProduct product) {
    showDialog(
      context: context,
      builder: (_) => PensionProductDialog(initialData: product),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PensionProduct product,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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