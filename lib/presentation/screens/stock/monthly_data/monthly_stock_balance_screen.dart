import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_extension.dart';
import '../../../../core/widgets/edit_delete_button.dart';
import '../../../../core/widgets/jtext.dart';
import '../../../../core/widgets/main_appbar.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../core/widgets/month_account_selector_header.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';
import '../../../../providers/stock/stock_provider.dart';
import 'widgets/monthly_stock_balance_dialog.dart';

class MonthlyStockBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyStockBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth =
        selectedMonth ??
        initialYearMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final selectedAccountId = ref.watch(selectedStockAccountFilterProvider);

    final balancesAsync = ref.watch(monthlyStockBalanceProvider(targetMonth));
    final accountsAsync = ref.watch(accountProvider);
    final accountNamesAsync = ref.watch(accountNameProvider);
    final stockItemsAsync = ref.watch(stockItemProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '월말주식',
        actions: [
          context.isMobile
              ? IconButton(
                onPressed: () => _showDialog(context, yearMonth: targetMonth),
                icon: const Icon(Icons.playlist_add),
                color: context.primaryColor,
              )
              : ElevatedButton.icon(
                onPressed: () => _showDialog(context, yearMonth: targetMonth),
                icon: const Icon(Icons.playlist_add),
                label: const Text('월말입력'),
              ),
        ],
      ),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 주식 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];
          final items = balancesAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};

          final stockAccounts =
              accounts
                  .where(
                    (a) => a.accountType.trim() == '증권' && a.status == '활동',
                  )
                  .toList();

          final isValidAccountId =
              selectedAccountId == null ||
              stockAccounts.any((acc) => acc.id == selectedAccountId);
          final currentDropdownValue =
              isValidAccountId ? selectedAccountId : null;

          final accountFilterItems =
              stockAccounts.map((acc) {
                final accId = acc.id ?? '';
                final nameObj = accountNameMap[acc.accountNameId];
                final accName = nameObj?.accountName ?? '계좌';
                return MonthAccountSelectorItem(
                  value: accId,
                  label: accName,
                  logoUrl: acc.logoUrl,
                );
              }).toList();

          final filteredItems =
              currentDropdownValue == null
                  ? items
                  : items
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          return MainConstrainedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthAccountSelectorHeader(
                    months: months,
                    currentMonth: activeCurrentMonth,
                    onMonthChanged:
                        (val) => ref
                            .read(selectedYearMonthProvider.notifier)
                            .select(val),
                    selectedAccountValue: currentDropdownValue,
                    accountItems: accountFilterItems,
                    onAccountChanged:
                        (val) => ref
                            .read(selectedStockAccountFilterProvider.notifier)
                            .setFilter(val),
                  ),

                  const SizedBox(height: 12),
                  const SectionTitle('등록된 월말 입력 내역'),

                  if (filteredItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          '$activeCurrentMonth에 조건에 해당하는 월말 데이터가 없습니다.',
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final matchedAcc = accountMap[item.accountId];
                        final nameObj =
                            matchedAcc != null
                                ? accountNameMap[matchedAcc.accountNameId]
                                : null;
                        final accountName = nameObj?.accountName ?? '주식계좌';

                        final isOverseasAccount =
                            matchedAcc?.isForeignCurrency ?? false;

                        final stock = stockItemMap[item.stockItemId];
                        final stockNameOnly = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode ?? '';
                        final displayName =
                            stockCode.isNotEmpty
                                ? '$stockNameOnly ($stockCode)'
                                : stockNameOnly;
                        final logoUrl = matchedAcc?.logoUrl;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (logoUrl != null &&
                                              logoUrl.isNotEmpty) ...[
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipOval(
                                                child: Image.network(
                                                  logoUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.account_balance,
                                                        size: 15,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Flexible(
                                            child: Text(
                                              accountName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      JText(
                                        '수량: ${item.quantity.toCommaString()}주 · 현재가: ${isOverseasAccount ? item.currentPrice.toUSD() : item.currentPrice.toWon()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 1,
                                        overflow: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    JText(
                                      isOverseasAccount
                                          ? item.balance.toUSD()
                                          : item.balance.toWon(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    EditDeleteButtons(
                                      onEdit:
                                          () => _showDialog(
                                            context,
                                            yearMonth: item.yearMonth,
                                            editItem: item,
                                          ),
                                      onDelete:
                                          () => _confirmDelete(
                                            context,
                                            ref,
                                            item,
                                            displayName,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDialog(
    BuildContext context, {
    required String yearMonth,
    MonthlyStockBalance? editItem,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => MonthlyStockBalanceDialog(
            yearMonth: yearMonth,
            editItem: editItem,
          ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonthlyStockBalance item,
    String stockName,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('삭제 확인'),
            content: Text('$stockName의 ${item.yearMonth} 월말 데이터를 삭제하시겠습니까?'),
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
                          monthlyStockBalanceProvider(item.yearMonth).notifier,
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
}
