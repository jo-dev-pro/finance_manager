import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/pension/pension_product_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import 'widget/monthly_pension_dialog.dart';

class MonthlyPensionBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyPensionBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth =
        selectedMonth ??
        initialYearMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final balancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(targetMonth),
    );
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('연금 월말 평가액 관리')),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text('$targetMonth에 등록된 연금 월말 데이터가 없습니다.'));
          }

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final products = productsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final productMap = {for (var p in products) p.id!: p.productName};

          final sortedItems = List<MonthlyPensionBalance>.from(items)
            ..sort((a, b) {
              final accA = accountMap[a.accountId];
              final accB = accountMap[b.accountId];

              final orderA = accA?.sortOrder ?? 9999;
              final orderB = accB?.sortOrder ?? 9999;

              if (orderA != orderB) {
                return orderA.compareTo(orderB);
              }

              final nameA =
                  a.productId == '_CASH_ASSET_PRODUCT_ID_'
                      ? '계좌 공통 현금성 자산'
                      : (productMap[a.productId] ?? '');
              final nameB =
                  b.productId == '_CASH_ASSET_PRODUCT_ID_'
                      ? '계좌 공통 현금성 자산'
                      : (productMap[b.productId] ?? '');
              return nameA.compareTo(nameB);
            });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                monthlyPensionBalanceNotifierProvider(targetMonth),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final balanceItem = sortedItems[index];

                final matchedAcc = accountMap[balanceItem.accountId];
                final institution =
                    matchedAcc?.financialInstitution ?? '기타 금융기관';
                final nameObj =
                    matchedAcc != null
                        ? accountNameMap[matchedAcc.accountNameId]
                        : null;
                final accountName = nameObj?.accountName ?? '연금계좌';

                final String displayName =
                    balanceItem.productId == '_CASH_ASSET_PRODUCT_ID_'
                        ? '💵 계좌 공통 현금성 자산 (예수금)'
                        : (productMap[balanceItem.productId] ?? '알 수 없는 상품');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // 1. 좌측 정보 영역 (상품명 1줄 고정 + 글자 크기 축소)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 상단: 상품명 (1줄, 글자 크기 14로 축소하여 여유 확보)
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                
                                // 하단: [금융기관] 계좌명 + 연월 배지 조합
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '[$institution] $accountName',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        balanceItem.yearMonth,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. 우측 금액 및 수정/삭제 아이콘 영역
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                balanceItem.balance.toWon(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero, // 기본 패딩 제거
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 19,
                                      color: Colors.grey,
                                    ),
                                    onPressed:
                                        () => _showEditBottomSheet(
                                          context,
                                          ref,
                                          balanceItem,
                                          displayName,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero, // 기본 패딩 제거
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 19,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed:
                                        () => _confirmDelete(
                                          context,
                                          ref,
                                          balanceItem,
                                          displayName,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              '연금 월말 평가액 추가 입력',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () => _showAddBottomSheet(context, targetMonth),
          ),
        ),
      ),
    );
  }

  void _showEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    MonthlyPensionBalance balanceItem,
    String displayName,
  ) {
    final controller = TextEditingController(
      text: balanceItem.balance.toCommaString(),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$displayName (${balanceItem.yearMonth}) 평가액 수정',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '평가액 (원)',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return '평가액을 입력해 주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final cleanText = controller.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        final newBalance = double.tryParse(cleanText) ?? 0.0;

                        final updatedItem = balanceItem.copyWith(
                          balance: newBalance,
                        );
                        await ref
                            .read(
                              monthlyPensionBalanceNotifierProvider(
                                balanceItem.yearMonth,
                              ).notifier,
                            )
                            .saveBalance(updatedItem);

                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text('저장하기', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonthlyPensionBalance item,
    String displayName,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('삭제 확인'),
            content: Text('$displayName의 ${item.yearMonth} 월말 데이터를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (item.id != null) {
                    await ref
                        .read(
                          monthlyPensionBalanceNotifierProvider(
                            item.yearMonth,
                          ).notifier,
                        )
                        .deleteBalance(item.id!);
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('삭제', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _showAddBottomSheet(BuildContext context, String currentMonth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MonthlyPensionDialog(yearMonth: currentMonth),
    );
  }
}