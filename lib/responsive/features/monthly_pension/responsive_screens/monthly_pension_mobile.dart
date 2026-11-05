import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';

class MonthlyPensionMobileScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyPensionMobileScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth = selectedMonth ?? initialYearMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('연금 월말 평가액 관리 (조회 전용)')),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 연금 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (targetMonth != null && months.contains(targetMonth))
                  ? targetMonth
                  : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref.read(selectedYearMonthProvider.notifier).select(activeCurrentMonth);
            });
          }

          final balancesAsync = ref.watch(
            monthlyPensionBalanceNotifierProvider(activeCurrentMonth),
          );
          final accountsAsync = ref.watch(accountNotifierProvider);
          final accountNamesAsync = ref.watch(accountNameNotifierProvider);
          final productsAsync = ref.watch(pensionProductNotifierProvider);

          return Column(
            children: [
              _buildMonthSelectorHeader(context, ref, months, activeCurrentMonth),
              Expanded(
                child: balancesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(child: Text('$activeCurrentMonth에 등록된 연금 월말 데이터가 없습니다.'));
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

                        if (orderA != orderB) return orderA.compareTo(orderB);

                        final nameA = a.productId == '_CASH_ASSET_PRODUCT_ID_' ? '계좌 공통 현금성 자산' : (productMap[a.productId] ?? '');
                        final nameB = b.productId == '_CASH_ASSET_PRODUCT_ID_' ? '계좌 공통 현금성 자산' : (productMap[b.productId] ?? '');
                        return nameA.compareTo(nameB);
                      });

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(monthlyPensionBalanceNotifierProvider(activeCurrentMonth));
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

                          final bool isCashAsset = balanceItem.productId == '_CASH_ASSET_PRODUCT_ID_';
                          final String displayName = isCashAsset
                              ? '💵 계좌 공통 현금성 자산 (예수금)'
                              : (productMap[balanceItem.productId] ?? '알 수 없는 상품');

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 1.5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  balanceItem.yearMonth,
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '[$institution] $accountName',
                                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                          ),
                                          if (!isCashAsset) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '최초 매수일: ${balanceItem.purchaseDate ?? '미입력'}',
                                              style: TextStyle(fontSize: 14, color: Colors.indigo.shade600, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // 모바일에서는 수정/삭제 버튼 배제 (조회 전용)
                                    Text(
                                      balanceItem.balance.toWon(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelectorHeader(BuildContext context, WidgetRef ref, List<String> months, String currentMonth) {
    final currentIndex = months.indexOf(currentMonth);
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentIndex >= 0 && currentIndex < months.length - 1)
                ? () => ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex + 1])
                : null,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: months.contains(currentMonth) ? currentMonth : months.first,
              items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) {
                if (val != null) ref.read(selectedYearMonthProvider.notifier).select(val);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentIndex > 0
                ? () => ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex - 1])
                : null,
          ),
        ],
      ),
    );
  }
}