import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/pension/pension_holding_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../../../scaffold/widgets/common_desktop_container.dart';
import 'widgets/pension_holding_product_dialog.dart';

class PensionHoldingProductDesktopScreen extends ConsumerStatefulWidget {
  const PensionHoldingProductDesktopScreen({super.key});

  @override
  ConsumerState<PensionHoldingProductDesktopScreen> createState() =>
      _PensionHoldingProductDesktopScreenState();
}

class _PensionHoldingProductDesktopScreenState
    extends ConsumerState<PensionHoldingProductDesktopScreen> {
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final accountProductsAsync = ref.watch(pensionHoldingProductNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌별 연금 보유상품 관리 (데스크톱)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 25),
            color: Colors.grey.shade700,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showAddDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: DesktopContainer(
        child: Column(
          children: [
            accountsAsync.when(
              data: (accounts) {
                final accountNames = accountNamesAsync.value ?? [];
                final accountNameMap = {for (var an in accountNames) an.id: an};

                final pensionAccounts = accounts
                    .where((a) {
                      final type = a.accountType.trim().toUpperCase();
                      return (type.contains('연금') || type.contains('IRP')) &&
                          a.status == '활동';
                    })
                    .toList()
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  child: Row(
                    children: [
                      const Text(
                        '연금계좌 필터: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedAccountId,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('전체 연금계좌 보기',
                                    style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              ...pensionAccounts.map((acc) {
                                final nameObj = accountNameMap[acc.accountNameId];
                                final displayName =
                                    '[${acc.financialInstitution}] ${nameObj?.accountName ?? '연금계좌'}';
                                return DropdownMenuItem<String?>(
                                  value: acc.id,
                                  child: Text(displayName, overflow: TextOverflow.ellipsis),
                                );
                              }),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedAccountId = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            Expanded(
              child: accountProductsAsync.when(
                data: (accountProducts) {
                  if (accountProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        '등록된 계좌별 연금상품이 없습니다.\n상단의 + 버튼을 눌러 추가해 보세요.',
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
                  final productMap = {
                    for (var prod in products) prod.id!: prod.productName,
                  };

                  final filteredAccountProducts = _selectedAccountId == null
                      ? accountProducts
                      : accountProducts
                          .where((item) => item.accountId == _selectedAccountId)
                          .toList();

                  if (filteredAccountProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        '선택한 연금계좌에 등록된 보유 상품이 없습니다.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    );
                  }

                  final sortedAccountProducts = [...filteredAccountProducts];
                  sortedAccountProducts.sort((a, b) {
                    final accA = accountMap[a.accountId];
                    final accB = accountMap[b.accountId];
                    final orderA = accA?.sortOrder ?? 999;
                    final orderB = accB?.sortOrder ?? 999;
                    return orderA.compareTo(orderB);
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: sortedAccountProducts.length,
                    itemBuilder: (context, index) {
                      final item = sortedAccountProducts[index];

                      final matchedAcc = accountMap[item.accountId];
                      final institution = matchedAcc?.financialInstitution ?? '기타 금융기관';
                      final nameObj = matchedAcc != null
                          ? accountNameMap[matchedAcc.accountNameId]
                          : null;
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '[$institution] $accountName',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item.isActive
                                                ? Colors.green.shade50
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: item.isActive
                                                  ? Colors.green.shade200
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            item.isActive ? '활동중' : '비활동',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: item.isActive
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                    Text(
                                      '최초 매수일: ${item.initialPurchaseDate ?? '미입력'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                color: Colors.grey.shade700,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _showEditDialog(context, item),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                color: Colors.red.shade400,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
                error: (err, _) => Center(child: Text('오류 발생: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PensionHoldingProductDialog(),
    );
  }

  void _showEditDialog(BuildContext context, PensionHoldingProduct item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PensionHoldingProductDialog(initialData: item),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PensionHoldingProduct item,
  ) {
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