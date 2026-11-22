import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive_extension.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../models/pension/pension_holding_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import 'widgets/pension_holding_product_dialog.dart';

class PensionHoldingProductScreen extends ConsumerStatefulWidget {
  const PensionHoldingProductScreen({super.key});

  @override
  ConsumerState<PensionHoldingProductScreen> createState() =>
      _PensionHoldingProductScreenState();
}

class _PensionHoldingProductScreenState
    extends ConsumerState<PensionHoldingProductScreen> {
  // 선택된 계좌 ID (null일 경우 '전체 계좌 보기')
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final accountProductsAsync = ref.watch(
      pensionHoldingProductNotifierProvider,
    );
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '계좌별 연금 보유상품 관리',
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showDialog(context),
            label: const Text('등록'),
          ),
        ],
      ),

      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('계좌를 불러오지 못했습니다: $err')),
        data: (accounts) {
          final accountNames = accountNamesAsync.value ?? [];
          final accountNameMap = {for (var an in accountNames) an.id: an};

          // 💡 accountType이 '연금' 또는 'IRP'인 활동 계좌만 정확히 필터링
          final pensionAccounts =
              accounts.where((a) {
                  final type = a.accountType.trim().toUpperCase();
                  return (type.contains('연금') || type.contains('IRP')) &&
                      a.status == '활동';
                }).toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                child: Text(
                                  '계좌 보기',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              ...pensionAccounts.map((acc) {
                                final nameObj =
                                    accountNameMap[acc.accountNameId];
                                final displayName =
                                    nameObj?.accountName ?? '연금계좌';
                                return DropdownMenuItem<String?>(
                                  value: acc.id,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          acc.logoUrl!,
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        displayName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
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
                ),
                SizedBox(height: 16),

                // 💡 2. 선택된 연금계좌의 상품 목록 영역
                Expanded(
                  child: accountProductsAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (e, st) =>
                            Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
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

                      final accountNameMap = {
                        for (var an in accountNames) an.id: an,
                      };
                      final accountMap = {
                        for (var acc in accounts) acc.id!: acc,
                      };
                      final productMap = {
                        for (var prod in products) prod.id!: prod.productName,
                      };

                      // 선택한 연금 계좌가 있다면 필터링 적용
                      final filteredAccountProducts =
                          _selectedAccountId == null
                              ? accountProducts
                              : accountProducts
                                  .where(
                                    (item) =>
                                        item.accountId == _selectedAccountId,
                                  )
                                  .toList();

                      if (filteredAccountProducts.isEmpty) {
                        return const Center(
                          child: Text(
                            '선택한 연금계좌에 등록된 보유 상품이 없습니다.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        );
                      }

                      final sortedAccountProducts = [
                        ...filteredAccountProducts,
                      ];
                      sortedAccountProducts.sort((a, b) {
                        final accA = accountMap[a.accountId];
                        final accB = accountMap[b.accountId];
                        final orderA = accA?.sortOrder ?? 999;
                        final orderB = accB?.sortOrder ?? 999;
                        return orderA.compareTo(orderB);
                      });

                      return ListView.builder(
                        itemCount: sortedAccountProducts.length,
                        itemBuilder: (context, index) {
                          final item = sortedAccountProducts[index];

                          final matchedAcc = accountMap[item.accountId];
                          final logoUrl = matchedAcc?.logoUrl;
                          final nameObj =
                              matchedAcc != null
                                  ? accountNameMap[matchedAcc.accountNameId]
                                  : null;
                          final accountName = nameObj?.accountName ?? '연금계좌';

                          final productName =
                              productMap[item.productId] ?? '알 수 없는 상품';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 로고 계좌명
                                          Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  logoUrl!,
                                                  width: 25,
                                                  height: 25,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                accountName,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      item.isActive
                                                          ? Colors.green.shade50
                                                          : Colors
                                                              .grey
                                                              .shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color:
                                                        item.isActive
                                                            ? Colors
                                                                .green
                                                                .shade200
                                                            : Colors
                                                                .grey
                                                                .shade300,
                                                  ),
                                                ),
                                                child: Text(
                                                  item.isActive ? '활동중' : '비활동',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        item.isActive
                                                            ? Colors
                                                                .green
                                                                .shade700
                                                            : Colors
                                                                .grey
                                                                .shade600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

                                          const SizedBox(height: 4),
                                          Text(
                                            '최초 매수일: ${item.initialPurchaseDate ?? '미입력'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),

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
                                ],
                              ),
                            ),
                          );
                        },
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

  void _showDialog(BuildContext context, {PensionHoldingProduct? item}) {
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
    if (item.id == null) return;

    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '계좌별 연금 보유상품 정보를 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await ref
              .read(pensionHoldingProductNotifierProvider.notifier)
              .deletePensionHoldingProduct(item.id!);

          if (!context.mounted) return;
          AppSnackBar.showInfo(context, '보유상품 내역이 삭제되었습니다.');
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(context, '삭제 실패: $e');
        }
      },
    );
  }
}
