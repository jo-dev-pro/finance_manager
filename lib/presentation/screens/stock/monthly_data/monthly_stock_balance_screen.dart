import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/bottom_action_button.dart';
import '../../../../core/widgets/edit_delete_button.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../core/widgets/summary_item.dart'; // 💡 공통 SummaryItem 위젯 임포트
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../models/monthly_data/monthly_stock_account_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';
import 'widgets/monthly_stock_balance_dialog.dart';
import 'widgets/monthly_stock_account_summary_list.dart'; // 💡 주식 계좌 요약 리스트 위젯 임포트

final selectedAccountFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

class MonthlyStockBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyStockBalanceScreen({super.key, this.initialYearMonth});

  String _getPreviousYearMonth(String ym) {
    try {
      final parts = ym.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      DateTime lastMonthDate = DateTime(year, month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return ym;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth =
        selectedMonth ??
        initialYearMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final selectedAccountId = ref.watch(selectedAccountFilterProvider);

    final balancesAsync = ref.watch(
      monthlyStockBalanceNotifierProvider(targetMonth),
    );
    final accountBalancesAsync = ref.watch(
      monthlyStockAccountBalanceNotifierProvider(targetMonth),
    );
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주식 월말 내역 관리'),
        scrolledUnderElevation: 0,
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
          final accountBalances = accountBalancesAsync.value ?? [];
          final items = balancesAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};
          final accountBalanceMap = {
            for (var ab in accountBalances) ab.accountId: ab,
          };

          final stockAccounts =
              accounts
                  .where(
                    (a) => a.accountType.trim() == '증권' && a.status == '활동',
                  )
                  .toList();

          final filteredAccountBalances =
              selectedAccountId == null
                  ? accountBalances
                  : accountBalances
                      .where((ab) => ab.accountId == selectedAccountId)
                      .toList();

          final filteredStockItems =
              selectedAccountId == null
                  ? items
                  : items
                      .where((item) => item.accountId == selectedAccountId)
                      .toList();

          double totalKrwStockBalance = 0;
          double totalKrwPrincipal = 0;
          double totalKrwCashBalance = 0;

          double totalUsdStockBalance = 0;
          double totalUsdPrincipal = 0;
          double totalUsdCashBalance = 0;

          double currentMonthExchangeRate = 1.0;

          for (var b in filteredStockItems) {
            final acc = accountMap[b.accountId];
            final isOverseas = acc?.isForeignCurrency ?? false;

            if (isOverseas) {
              totalUsdStockBalance += b.balance;
              totalUsdPrincipal += b.principal;
            } else {
              totalKrwStockBalance += b.balance;
              totalKrwPrincipal += b.principal;
            }
          }

          for (var ab in filteredAccountBalances) {
            final acc = accountMap[ab.accountId];
            final isOverseas = acc?.isForeignCurrency ?? false;

            if (isOverseas) {
              totalUsdCashBalance += ab.cashBalance;
              if (ab.exchangeRate > 1.0) {
                currentMonthExchangeRate = ab.exchangeRate;
              }
            } else {
              totalKrwCashBalance += ab.cashBalance;
            }
          }

          final grandTotalKrw = totalKrwStockBalance + totalKrwCashBalance;
          final totalKrwProfit = grandTotalKrw - totalKrwPrincipal;

          final grandTotalUsd = totalUsdStockBalance + totalUsdCashBalance;
          final usdValuationInKrw = grandTotalUsd * currentMonthExchangeRate;
          final totalUsdProfit = grandTotalUsd - totalUsdPrincipal;

          final selectedAcc =
              selectedAccountId != null ? accountMap[selectedAccountId] : null;
          final isSelectedAccountOverseas =
              selectedAcc?.isForeignCurrency ?? false;

          return MainConstrainedBox(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 기준년월 & 계좌선택 콤보박스 (가로 Row 배치)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value:
                                  months.contains(activeCurrentMonth)
                                      ? activeCurrentMonth
                                      : months.first,
                              isExpanded: true,
                              items:
                                  months.map((ym) {
                                    return DropdownMenuItem(
                                      value: ym,
                                      child: Text(
                                        ym,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                      .read(selectedYearMonthProvider.notifier)
                                      .select(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: selectedAccountId,
                              isExpanded: true,
                              hint: const Text('전체 계좌'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    '전체 계좌',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                ...stockAccounts.map((acc) {
                                  final accId = acc.id ?? '';
                                  final nameObj =
                                      accountNameMap[acc.accountNameId];
                                  final accName = nameObj?.accountName ?? '계좌';
                                  final institution = acc.financialInstitution;
                                  return DropdownMenuItem<String?>(
                                    value: accId,
                                    child: Text(
                                      '$institution $accName',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                ref
                                    .read(
                                      selectedAccountFilterProvider.notifier,
                                    )
                                    .state = val;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 요약 카드 (SummaryItem 공통 위젯 적용)
                  Card(
                    elevation: 0,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.indigo.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (selectedAccountId != null) ...[
                            if (isSelectedAccountOverseas) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '적용 환율: ${currentMonthExchangeRate.toCommaString()}원/\$',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade800,
                                    ),
                                  ),
                                  Text(
                                    '원화 환산: ${usdValuationInKrw.toWon()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SummaryItem(
                                    label: '총 자산 (달러)',
                                    value: grandTotalUsd.toUSD(),
                                  ),
                                  SummaryItem(
                                    label: '달러 원금',
                                    value: totalUsdPrincipal.toUSD(),
                                  ),
                                  SummaryItem(
                                    label: '달러 손익',
                                    value:
                                        '${totalUsdProfit >= 0 ? '+' : ''}${totalUsdProfit.toUSD()}',
                                    color:
                                        totalUsdProfit >= 0
                                            ? Colors.red.shade700
                                            : Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SummaryItem(
                                    label: '총 자산 (원화)',
                                    value: grandTotalKrw.toWon(),
                                  ),
                                  SummaryItem(
                                    label: '원화 원금',
                                    value: totalKrwPrincipal.toWon(),
                                  ),
                                  SummaryItem(
                                    label: '원화 손익',
                                    value:
                                        '${totalKrwProfit >= 0 ? '+' : ''}${totalKrwProfit.toWon()}',
                                    color:
                                        totalKrwProfit >= 0
                                            ? Colors.red.shade700
                                            : Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SummaryItem(
                                  label: '총 자산 (원화)',
                                  value: grandTotalKrw.toWon(),
                                ),
                                SummaryItem(
                                  label: '원화 원금',
                                  value: totalKrwPrincipal.toWon(),
                                ),
                                SummaryItem(
                                  label: '원화 손익',
                                  value:
                                      '${totalKrwProfit >= 0 ? '+' : ''}${totalKrwProfit.toWon()}',
                                  color:
                                      totalKrwProfit >= 0
                                          ? Colors.red.shade700
                                          : Colors.blue.shade700,
                                ),
                              ],
                            ),
                            if (grandTotalUsd > 0 || totalUsdPrincipal > 0) ...[
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'USD 환율: ${currentMonthExchangeRate.toCommaString()}원/\$',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade800,
                                    ),
                                  ),
                                  Text(
                                    '달러 자산 원화 환산: ${usdValuationInKrw.toWon()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SummaryItem(
                                    label: '총 자산 (달러)',
                                    value: grandTotalUsd.toUSD(),
                                  ),
                                  SummaryItem(
                                    label: '달러 원금',
                                    value: totalUsdPrincipal.toUSD(),
                                  ),
                                  SummaryItem(
                                    label: '달러 손익',
                                    value:
                                        '${totalUsdProfit >= 0 ? '+' : ''}${totalUsdProfit.toUSD()}',
                                    color:
                                        totalUsdProfit >= 0
                                            ? Colors.red.shade700
                                            : Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    '계좌별 현금 및 자금 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 💡 분리한 MonthlyStockAccountSummaryList 위젯 호출
                  MonthlyStockAccountSummaryList(
                    stockAccounts: stockAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    selectedAccountId: selectedAccountId,
                    targetMonth: activeCurrentMonth,
                    onEditPressed: (accId, displayName, currentBal) {
                      _showAccountEditBottomSheet(
                        context,
                        ref,
                        accId,
                        displayName,
                        activeCurrentMonth,
                        currentBal,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '보유 종목별 월말 내역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (filteredStockItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          '$activeCurrentMonth에 등록된 주식 종목 월말 데이터가 없습니다.',
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStockItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredStockItems[index];
                        final account = accountMap[item.accountId];
                        final accountName =
                            account != null
                                ? accountNameMap[account.accountNameId]
                                : null;
                        final stock = stockItemMap[item.stockItemId];

                        final institution =
                            account?.financialInstitution ?? '기타 증권사';
                        final accName = accountName?.accountName ?? '주식계좌';

                        final isOverseasAccount =
                            account?.isForeignCurrency ?? false;

                        final stockNameOnly = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode ?? '';
                        final stockDisplayName =
                            stockCode.isNotEmpty
                                ? '$stockNameOnly ($stockCode)'
                                : stockNameOnly;

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stockDisplayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '[$institution] $accName',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Text(
                                              '수량: ${item.quantity.toCommaString()}주',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '현재가: ${isOverseasAccount ? item.currentPrice.toUSD() : item.currentPrice.toWon()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
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
                                            () => _showEditBottomSheet(
                                              context,
                                              ref,
                                              item,
                                              stockDisplayName,
                                            ),
                                        onDelete:
                                            () => _confirmDelete(
                                              context,
                                              ref,
                                              item,
                                              stockDisplayName,
                                            ),
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
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomActionButton(
        label: '주식 월말 평가액 일괄 입력',
        onPressed: () => _showAddBottomSheet(context, targetMonth),
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
      builder: (_) => MonthlyStockBalanceDialog(yearMonth: currentMonth),
    );
  }

  void _showAccountEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String accountId,
    String accountDisplayName,
    String yearMonth,
    MonthlyStockAccountBalance? currentAccountBalance,
  ) {
    final cashController = TextEditingController(
      text:
          (currentAccountBalance != null &&
                  currentAccountBalance.cashBalance > 0)
              ? currentAccountBalance.cashBalance.toCommaString()
              : '',
    );
    final monthlyWithdrawalController = TextEditingController(
      text:
          (currentAccountBalance != null &&
                  currentAccountBalance.monthlyWithdrawal > 0)
              ? currentAccountBalance.monthlyWithdrawal.toCommaString()
              : '',
    );
    final exchangeRateController = TextEditingController(
      text:
          (currentAccountBalance != null &&
                  currentAccountBalance.exchangeRate > 1.0)
              ? currentAccountBalance.exchangeRate.toStringAsFixed(2)
              : '',
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
                      Expanded(
                        child: Text(
                          '[$accountDisplayName] ($yearMonth) 계좌 자금 수정',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    controller: cashController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '계좌 현금성 잔액 (예수금)',
                      suffixText: '원/달러',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: exchangeRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '월말 환율 (원/\$)',
                      hintText: '1350.0',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: monthlyWithdrawalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '당월 인출액',
                      suffixText: '원/달러',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final cashVal =
                            double.tryParse(
                              cashController.text.replaceAll(',', '').trim(),
                            ) ??
                            0.0;
                        final monthlyWithVal =
                            double.tryParse(
                              monthlyWithdrawalController.text
                                  .replaceAll(',', '')
                                  .trim(),
                            ) ??
                            0.0;
                        final exchangeRateVal =
                            double.tryParse(
                              exchangeRateController.text.trim(),
                            ) ??
                            1.0;

                        final prevYearMonth = _getPreviousYearMonth(yearMonth);
                        final prevAccountBalances =
                            ref
                                .read(
                                  monthlyStockAccountBalanceNotifierProvider(
                                    prevYearMonth,
                                  ),
                                )
                                .value ??
                            [];
                        final prevData = prevAccountBalances.firstWhereOrNull(
                          (b) => b.accountId == accountId,
                        );
                        final prevTotalWith = prevData?.totalWithdrawal ?? 0.0;
                        final finalTotalWith = prevTotalWith + monthlyWithVal;

                        final updatedAccountBalance =
                            MonthlyStockAccountBalance(
                              yearMonth: yearMonth,
                              accountId: accountId,
                              cashBalance: cashVal,
                              exchangeRate: exchangeRateVal,
                              monthlyWithdrawal: monthlyWithVal,
                              totalWithdrawal: finalTotalWith,
                              accountName: currentAccountBalance?.accountName,
                            );

                        await ref
                            .read(
                              monthlyStockAccountBalanceNotifierProvider(
                                yearMonth,
                              ).notifier,
                            )
                            .saveBalance(updatedAccountBalance);

                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        '계좌 정보 저장',
                        style: TextStyle(fontSize: 16),
                      ),
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

  void _showEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    MonthlyStockBalance item,
    String stockName,
  ) {
    final quantityController = TextEditingController(
      text: item.quantity.toCommaString(),
    );
    final priceController = TextEditingController(
      text: item.currentPrice.toCommaString(),
    );
    final principalController = TextEditingController(
      text: item.principal.toCommaString(),
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
                      Expanded(
                        child: Text(
                          '$stockName (${item.yearMonth}) 내역 수정',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '보유 수량',
                      suffixText: '주',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? '수량을 입력해주세요.'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '현재가',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? '현재가를 입력해주세요.'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: principalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '투자 원금',
                      suffixText: '원/달러',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? '원금을 입력해주세요.'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false))
                          return;

                        final qty =
                            double.tryParse(
                              quantityController.text
                                  .replaceAll(',', '')
                                  .trim(),
                            ) ??
                            0.0;
                        final price =
                            double.tryParse(
                              priceController.text.replaceAll(',', '').trim(),
                            ) ??
                            0.0;
                        final principal =
                            double.tryParse(
                              principalController.text
                                  .replaceAll(',', '')
                                  .trim(),
                            ) ??
                            0.0;
                        final balance = qty * price;

                        final updatedItem = item.copyWith(
                          quantity: qty,
                          currentPrice: price,
                          principal: principal,
                          balance: balance,
                        );

                        await ref
                            .read(
                              monthlyStockBalanceNotifierProvider(
                                item.yearMonth,
                              ).notifier,
                            )
                            .saveBalance(updatedItem);

                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        '수정 내용 저장',
                        style: TextStyle(fontSize: 16),
                      ),
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
                          monthlyStockBalanceNotifierProvider(
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
}
