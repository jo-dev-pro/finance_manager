import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../models/monthly_data/monthly_stock_account_balance.dart';
import '../../../models/account/account_name.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';
import 'widget/monthly_stock_balance_dialog.dart';

final selectedAccountFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

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
      appBar: AppBar(title: const Text('주식 월말 내역 관리')),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (items) {
          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];
          final accountBalances = accountBalancesAsync.value ?? [];
          final availableMonths = availableMonthsAsync.value ?? [targetMonth];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};
          final accountBalanceMap = {for (var ab in accountBalances) ab.accountId: ab};

          final stockAccounts = accounts
              .where((a) => a.accountType.trim() == '증권' && a.status == '활동')
              .toList();

          final filteredAccountBalances = selectedAccountId == null
              ? accountBalances
              : accountBalances.where((ab) => ab.accountId == selectedAccountId).toList();

          final filteredStockItems = selectedAccountId == null
              ? items
              : items.where((item) => item.accountId == selectedAccountId).toList();

          double totalKrwStockBalance = 0;
          double totalKrwPrincipal = 0;
          double totalKrwCashBalance = 0;

          double totalUsdStockBalance = 0;
          double totalUsdPrincipal = 0;
          double totalUsdCashBalance = 0;
          
          double currentMonthExchangeRate = 1.0;

          for (var b in filteredStockItems) {
            final acc = accountMap[b.accountId];
            // 💡 모델의 isForeignCurrency 필드로 정확히 판별[cite: 8]
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

          final selectedAcc = selectedAccountId != null ? accountMap[selectedAccountId] : null;
          final isSelectedAccountOverseas = selectedAcc?.isForeignCurrency ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(monthlyStockBalanceNotifierProvider(targetMonth));
              ref.invalidate(monthlyStockAccountBalanceNotifierProvider(targetMonth));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              value: availableMonths.contains(targetMonth) ? targetMonth : availableMonths.first,
                              isExpanded: true,
                              items: availableMonths.map((ym) {
                                return DropdownMenuItem(
                                  value: ym,
                                  child: Text(ym, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(selectedYearMonthProvider.notifier).select(val);
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
                                  child: Text('전체 계좌', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                ...stockAccounts.map((acc) {
                                  final accId = acc.id ?? '';
                                  final nameObj = accountNameMap[acc.accountNameId];
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
                                ref.read(selectedAccountFilterProvider.notifier).state = val;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '적용 환율: ${currentMonthExchangeRate.toCommaString()}원/\$',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                                  ),
                                  Text(
                                    '원화 환산: ${usdValuationInKrw.toWon()}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryItem('총 자산 (달러)', grandTotalUsd.toUSD()),
                                  _buildSummaryItem('달러 원금', totalUsdPrincipal.toUSD()),
                                  _buildSummaryItem(
                                    '달러 손익',
                                    '${totalUsdProfit >= 0 ? '+' : ''}${totalUsdProfit.toUSD()}',
                                    color: totalUsdProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryItem('총 자산 (원화)', grandTotalKrw.toWon()),
                                  _buildSummaryItem('원화 원금', totalKrwPrincipal.toWon()),
                                  _buildSummaryItem(
                                    '원화 손익',
                                    '${totalKrwProfit >= 0 ? '+' : ''}${totalKrwProfit.toWon()}',
                                    color: totalKrwProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem('총 자산 (원화)', grandTotalKrw.toWon()),
                                _buildSummaryItem('원화 원금', totalKrwPrincipal.toWon()),
                                _buildSummaryItem(
                                  '원화 손익',
                                  '${totalKrwProfit >= 0 ? '+' : ''}${totalKrwProfit.toWon()}',
                                  color: totalKrwProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                                ),
                              ],
                            ),
                            if (grandTotalUsd > 0 || totalUsdPrincipal > 0) ...[
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'USD 환율: ${currentMonthExchangeRate.toCommaString()}원/\$',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                                  ),
                                  Text(
                                    '달러 자산 원화 환산: ${usdValuationInKrw.toWon()}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSummaryItem('총 자산 (달러)', grandTotalUsd.toUSD()),
                                  _buildSummaryItem('달러 원금', totalUsdPrincipal.toUSD()),
                                  _buildSummaryItem(
                                    '달러 손익',
                                    '${totalUsdProfit >= 0 ? '+' : ''}${totalUsdProfit.toUSD()}',
                                    color: totalUsdProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
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
                  
                  _buildAccountSummaryList(
                    context,
                    ref,
                    stockAccounts,
                    accountNameMap,
                    accountBalanceMap,
                    selectedAccountId,
                    targetMonth,
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
                      child: Center(child: Text('$targetMonth에 등록된 주식 종목 월말 데이터가 없습니다.')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStockItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredStockItems[index];
                        final account = accountMap[item.accountId];
                        final accountName = account != null
                            ? accountNameMap[account.accountNameId]
                            : null;
                        final stock = stockItemMap[item.stockItemId];

                        final institution = account?.financialInstitution ?? '기타 증권사';
                        final accName = accountName?.accountName ?? '주식계좌';
                        
                        final isOverseasAccount = account?.isForeignCurrency ?? false;

                        final stockNameOnly = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode ?? '';
                        final stockDisplayName = stockCode.isNotEmpty 
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '현재가: ${isOverseasAccount ? item.currentPrice.toUSD() : item.currentPrice.toWon()}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                                        isOverseasAccount ? item.balance.toUSD() : item.balance.toWon(),
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
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.edit, size: 19, color: Colors.grey),
                                            onPressed: () => _showEditBottomSheet(context, ref, item, stockDisplayName),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(Icons.delete, size: 19, color: Colors.redAccent),
                                            onPressed: () => _confirmDelete(context, ref, item, stockDisplayName),
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
                ],
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              '주식 월말 평가액 일괄 입력',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () => _showAddBottomSheet(context, targetMonth),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSummaryList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> stockAccounts,
    Map<String?, AccountName?> accountNameMap,
    Map<String, MonthlyStockAccountBalance> accountBalanceMap,
    String? selectedAccountId,
    String targetMonth,
  ) {
    if (stockAccounts.isEmpty) {
      return const Text('등록된 증권 계좌가 없습니다.', style: TextStyle(color: Colors.grey));
    }

    final displayAccounts = selectedAccountId == null
        ? stockAccounts
        : stockAccounts.where((a) => a.id == selectedAccountId).toList();

    if (displayAccounts.isEmpty) {
      return const Text('해당 계좌 정보가 없습니다.', style: TextStyle(color: Colors.grey));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayAccounts.length,
      itemBuilder: (context, index) {
        final acc = displayAccounts[index];
        final accId = acc.id ?? '';
        final nameObj = accountNameMap[acc.accountNameId];
        final accName = nameObj?.accountName ?? '계좌';
        final institution = acc.financialInstitution;

        final isOverseasAccount = acc.isForeignCurrency;

        final accBalanceData = accountBalanceMap[accId];
        final cash = accBalanceData?.cashBalance ?? 0.0;
        final monthlyWith = accBalanceData?.monthlyWithdrawal ?? 0.0;
        final totalWith = accBalanceData?.totalWithdrawal ?? 0.0;
        final exchangeRate = accBalanceData?.exchangeRate ?? 1.0;

        final cashStr = isOverseasAccount ? cash.toUSD() : cash.toWon();
        final monthlyWithStr = isOverseasAccount ? monthlyWith.toUSD() : monthlyWith.toWon();
        final totalWithStr = isOverseasAccount ? totalWith.toUSD() : totalWith.toWon();

        return Card(
          elevation: 1.0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$institution - $accName',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (isOverseasAccount && exchangeRate > 1.0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(환율: ${exchangeRate.toCommaString()})',
                              style: TextStyle(fontSize: 11, color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '현금성 잔액: $cashStr | 당월 인출: $monthlyWithStr (누적: $totalWithStr)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.indigo),
                  onPressed: () => _showAccountEditBottomSheet(
                    context,
                    ref,
                    accId,
                    '$institution $accName',
                    targetMonth,
                    accBalanceData,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
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
      text: (currentAccountBalance != null && currentAccountBalance.cashBalance > 0)
          ? currentAccountBalance.cashBalance.toCommaString()
          : '',
    );
    final monthlyWithdrawalController = TextEditingController(
      text: (currentAccountBalance != null && currentAccountBalance.monthlyWithdrawal > 0)
          ? currentAccountBalance.monthlyWithdrawal.toCommaString()
          : '',
    );
    final exchangeRateController = TextEditingController(
      text: (currentAccountBalance != null && currentAccountBalance.exchangeRate > 1.0)
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        final cashVal = double.tryParse(cashController.text.replaceAll(',', '').trim()) ?? 0.0;
                        final monthlyWithVal = double.tryParse(monthlyWithdrawalController.text.replaceAll(',', '').trim()) ?? 0.0;
                        final exchangeRateVal = double.tryParse(exchangeRateController.text.trim()) ?? 1.0;

                        final prevYearMonth = _getPreviousYearMonth(yearMonth);
                        final prevAccountBalances = ref.read(
                              monthlyStockAccountBalanceNotifierProvider(prevYearMonth),
                            ).value ?? [];
                        final prevData = prevAccountBalances.firstWhereOrNull(
                          (b) => b.accountId == accountId,
                        );
                        final prevTotalWith = prevData?.totalWithdrawal ?? 0.0;
                        final finalTotalWith = prevTotalWith + monthlyWithVal;

                        final updatedAccountBalance = MonthlyStockAccountBalance(
                          yearMonth: yearMonth,
                          accountId: accountId,
                          cashBalance: cashVal,
                          exchangeRate: exchangeRateVal,
                          monthlyWithdrawal: monthlyWithVal,
                          totalWithdrawal: finalTotalWith,
                          accountName: currentAccountBalance?.accountName,
                        );

                        await ref
                            .read(monthlyStockAccountBalanceNotifierProvider(yearMonth).notifier)
                            .saveBalance(updatedAccountBalance);

                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text('계좌 정보 저장', style: TextStyle(fontSize: 16)),
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
  ) {}

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonthlyStockBalance item,
    String stockName,
  ) {}
}