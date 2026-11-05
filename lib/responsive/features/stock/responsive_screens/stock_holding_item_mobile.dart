import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/stock/stock_holding_item_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class StockHoldingItemMobileScreen extends ConsumerStatefulWidget {
  const StockHoldingItemMobileScreen({super.key});

  @override
  ConsumerState<StockHoldingItemMobileScreen> createState() =>
      _StockHoldingItemMobileScreenState();
}

class _StockHoldingItemMobileScreenState
    extends ConsumerState<StockHoldingItemMobileScreen> {
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final holdingItemsState = ref.watch(stockHoldingItemNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계좌별 보유 주식 관리 (모바일 - 조회 전용)'),
      ),
      body: Column(
        children: [
          accountsAsync.when(
            data: (accounts) {
              final accountNames = accountNamesAsync.value ?? [];
              final accountNameMap = {for (var an in accountNames) an.id: an};

              final targetAccounts = accounts
                  .where((a) {
                    final type = a.accountType.trim().toUpperCase();
                    return (type.contains('증권') || type.contains('주식')) &&
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
                      '증권계좌 필터: ',
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
                              child: Text('전체 증권계좌 보기',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            ...targetAccounts.map((acc) {
                              final nameObj = accountNameMap[acc.accountNameId];
                              final displayName =
                                  '[${acc.financialInstitution}] ${nameObj?.accountName ?? '주식계좌'}';
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
            child: holdingItemsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      '등록된 보유 주식 내역이 없습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final accounts = accountsAsync.value ?? [];
                final accountNames = accountNamesAsync.value ?? [];
                final stockItems = stockItemsAsync.value ?? [];

                final accountMap = {for (var a in accounts) a.id!: a};
                final accountNameMap = {for (var an in accountNames) an.id: an};
                final stockMap = {for (var s in stockItems) s.id!: s};

                final filteredItems = _selectedAccountId == null
                    ? items
                    : items
                        .where((item) => item.accountId == _selectedAccountId)
                        .toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      '선택한 증권계좌에 등록된 보유 종목이 없습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  );
                }

                final sortedItems = [...filteredItems];
                sortedItems.sort((a, b) {
                  final accA = accountMap[a.accountId];
                  final accB = accountMap[b.accountId];
                  final orderA = accA?.sortOrder ?? 999;
                  final orderB = accB?.sortOrder ?? 999;
                  return orderA.compareTo(orderB);
                });

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(stockHoldingItemNotifierProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      final item = sortedItems[index];

                      final matchedAcc = accountMap[item.accountId];
                      final institution = matchedAcc?.financialInstitution ?? '기타 증권사';
                      final nameObj = matchedAcc != null
                          ? accountNameMap[matchedAcc.accountNameId]
                          : null;
                      final accountName = nameObj?.accountName ?? '주식계좌';

                      final matchedStock = stockMap[item.stockItemId];
                      final stockName = matchedStock?.itemName ?? '알 수 없는 종목';
                      final stockSymbol = matchedStock?.stockCode ?? '';
                      final market = matchedStock?.yahooName ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
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
                                          if (market.isNotEmpty) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                market,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          Expanded(
                                            child: Text(
                                              stockName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
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
                                              item.isActive ? '보유중' : '매도완료',
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
                                      const SizedBox(height: 6),
                                      Text(
                                        '[$institution] $accountName${stockSymbol.isNotEmpty ? ' • $stockSymbol' : ''}${item.initialPurchaseDate != null ? ' • 최초매수: ${item.initialPurchaseDate}' : ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}