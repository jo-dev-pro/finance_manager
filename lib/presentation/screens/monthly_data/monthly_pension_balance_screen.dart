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
    final targetMonth = selectedMonth ?? initialYearMonth ?? DateFormat('yyyy-MM').format(DateTime.now());
    
    final balancesAsync = ref.watch(monthlyPensionBalanceNotifierProvider(targetMonth));
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('연금 월말 평가액 관리 ($targetMonth)')),
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

          // 💡 계좌별 sortOrder를 빠르게 조회하기 위한 맵 생성
          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final productMap = {for (var p in products) p.id!: p.productName};

          // 💡 [핵심] 계좌 정렬 순서(sortOrder) 및 상품명 기준으로 리스트 정렬
          final sortedItems = List<MonthlyPensionBalance>.from(items)..sort((a, b) {
            final accA = accountMap[a.accountId];
            final accB = accountMap[b.accountId];
            
            final orderA = accA?.sortOrder ?? 9999;
            final orderB = accB?.sortOrder ?? 9999;

            // 1차 정렬: 계좌 sortOrder 기준 오름차순
            if (orderA != orderB) {
              return orderA.compareTo(orderB);
            }

            // 2차 정렬: 같은 계좌일 경우 상품 이름 기준 오름차순
            final nameA = a.productId == '_CASH_ASSET_PRODUCT_ID_' ? '계좌 공통 현금성 자산' : (productMap[a.productId] ?? '');
            final nameB = b.productId == '_CASH_ASSET_PRODUCT_ID_' ? '계좌 공통 현금성 자산' : (productMap[b.productId] ?? '');
            return nameA.compareTo(nameB);
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(monthlyPensionBalanceNotifierProvider(targetMonth));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedItems.length,
              itemBuilder: (context, index) {
                final balanceItem = sortedItems[index];

                final matchedAcc = accountMap[balanceItem.accountId];
                final institution = matchedAcc?.financialInstitution ?? '기타 금융기관';
                final nameObj = matchedAcc != null ? accountNameMap[matchedAcc.accountNameId] : null;
                final accountName = nameObj?.accountName ?? '연금계좌';

                final String displayName = balanceItem.productId == '_CASH_ASSET_PRODUCT_ID_'
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
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
                                          fontSize: 11,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '[$institution] $accountName',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                balanceItem.balance.toWon(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                    onPressed: () => _showEditDialog(context, ref, balanceItem, displayName),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(context, ref, balanceItem, displayName),
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
            label: const Text('연금 월말 평가액 추가 입력', style: TextStyle(fontSize: 16)),
            onPressed: () => _showAddDialog(context, targetMonth),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, MonthlyPensionBalance balanceItem, String displayName) {
    final controller = TextEditingController(
      text: NumberFormat('#,###', 'ko_KR').format(balanceItem.balance),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$displayName (${balanceItem.yearMonth}) 평가액 수정'),
        content: TextField(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cleanText = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
              final newBalance = double.tryParse(cleanText) ?? 0.0;

              final updatedItem = balanceItem.copyWith(balance: newBalance);
              await ref
                  .read(monthlyPensionBalanceNotifierProvider(balanceItem.yearMonth).notifier)
                  .saveBalance(updatedItem);

              if (context.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MonthlyPensionBalance item, String displayName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                    .read(monthlyPensionBalanceNotifierProvider(item.yearMonth).notifier)
                    .deleteBalance(item.id!);
              }
              if (context.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, String currentMonth) {
    showDialog(
      context: context,
      builder: (context) => MonthlyPensionDialog(yearMonth: currentMonth),
    );
  }
}