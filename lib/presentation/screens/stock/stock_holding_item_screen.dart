import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive_extension.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../models/stock/stock_holding_item.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/stock/stock_holding_item_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widgets/stock_holding_item_dialog.dart';

class StockHoldingItemScreen extends ConsumerStatefulWidget {
  const StockHoldingItemScreen({super.key});

  @override
  ConsumerState<StockHoldingItemScreen> createState() =>
      _StockHoldingItemScreenState();
}

class _StockHoldingItemScreenState
    extends ConsumerState<StockHoldingItemScreen> {
  // 💡 선택된 증권 계좌 ID (null일 경우 '전체 증권계좌 보기')
  String? _selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final holdingItemsState = ref.watch(stockHoldingItemNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '계좌별 보유 주식 관리',
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

          // 💡 계좌 타입이 '증권' 또는 '주식'인 활동 계좌만 필터링
          final targetAccounts =
              accounts.where((a) {
                  final type = a.accountType.trim().toUpperCase();
                  return (type.contains('증권') || type.contains('주식')) &&
                      a.status == '활동';
                }).toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // 계좌 필터
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                child: Text(
                                  '계좌 보기',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              ...targetAccounts.map((acc) {
                                final nameObj =
                                    accountNameMap[acc.accountNameId];
                                final displayName =
                                    nameObj?.accountName ?? '주식계좌';
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

                // 💡 2. 선택된 증권계좌의 보유 종목 목록 영역
                Expanded(
                  child: holdingItemsState.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (e, st) =>
                            Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다:\n$e')),
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            '등록된 보유 주식 내역이 없습니다.\n우측 상단의 + 버튼을 눌러 추가해 보세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      final accounts = accountsAsync.value ?? [];
                      final accountNames = accountNamesAsync.value ?? [];
                      final stockItems = stockItemsAsync.value ?? [];

                      final accountMap = {for (var a in accounts) a.id!: a};
                      final accountNameMap = {
                        for (var an in accountNames) an.id: an,
                      };
                      final stockMap = {for (var s in stockItems) s.id!: s};

                      // 💡 선택한 증권 계좌가 있다면 필터링 적용
                      final filteredItems =
                          _selectedAccountId == null
                              ? items
                              : items
                                  .where(
                                    (item) =>
                                        item.accountId == _selectedAccountId,
                                  )
                                  .toList();

                      if (filteredItems.isEmpty) {
                        return const Center(
                          child: Text(
                            '선택한 증권계좌에 등록된 보유 종목이 없습니다.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        );
                      }

                      // 계좌 정렬 순서 반영
                      final sortedItems = [...filteredItems];
                      sortedItems.sort((a, b) {
                        final accA = accountMap[a.accountId];
                        final accB = accountMap[b.accountId];
                        final orderA = accA?.sortOrder ?? 999;
                        final orderB = accB?.sortOrder ?? 999;
                        return orderA.compareTo(orderB);
                      });

                      return ListView.builder(
                        itemCount: sortedItems.length,
                        itemBuilder: (context, index) {
                          final item = sortedItems[index];

                          final matchedAcc = accountMap[item.accountId];
                          final logoUrl = matchedAcc?.logoUrl;
                          final nameObj =
                              matchedAcc != null
                                  ? accountNameMap[matchedAcc.accountNameId]
                                  : null;
                          final accountName = nameObj?.accountName ?? '주식계좌';

                          final matchedStock = stockMap[item.stockItemId];
                          final stockName =
                              matchedStock?.itemName ?? '알 수 없는 종목';
                          final stockSymbol = matchedStock?.stockCode ?? '';
                          final market = matchedStock?.yahooName ?? '';

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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
                                      // 종목명
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
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
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
                                              Text(
                                                stockSymbol.isNotEmpty
                                                    ? ' • $stockSymbol'
                                                    : '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(width: 8),

                                              // 활동여부
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
                                                  item.isActive
                                                      ? '보유중'
                                                      : '매도완료',
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

                                          Text(
                                            item.initialPurchaseDate != null
                                                ? ' • 최초매수: ${item.initialPurchaseDate}'
                                                : '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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

  void _showDialog(BuildContext context, {StockHoldingItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StockHoldingItemDialog(initialData: item),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StockHoldingItem item,
  ) {
    if (item.id == null) return;

    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '보유 주식 내역을 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await ref
              .read(stockHoldingItemNotifierProvider.notifier)
              .deleteStockHoldingItem(item.id!);

          if (!context.mounted) return;
          AppSnackBar.showInfo(context, '보유 주식 내역이 삭제되었습니다.');
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(context, '삭제 실패: $e');
        }
      },
    );
  }
}
