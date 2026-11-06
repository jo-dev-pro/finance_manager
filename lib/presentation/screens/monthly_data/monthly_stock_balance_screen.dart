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

// 선택된 계좌 필터링을 위한 로컬 프로바이더
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
          final accountNameMap = {for (var an in accountNames) an?.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};
          final accountBalanceMap = {for (var ab in accountBalances) ab.accountId: ab};

          // 활성화된 증권 계좌 목록 추출
          final stockAccounts = accounts
              .where((a) => a.accountType.trim() == '증권' && a.status == '활동')
              .toList();

          // 선택된 계좌에 따른 필터링 적용
          final filteredAccountBalances = selectedAccountId == null
              ? accountBalances
              : accountBalances.where((ab) => ab.accountId == selectedAccountId).toList();

          final filteredStockItems = selectedAccountId == null
              ? items
              : items.where((item) => item.accountId == selectedAccountId).toList();

          // 총 합계 계산
          double totalStockBalance = 0;
          double totalPrincipal = 0;
          double totalCashBalance = 0;

          for (var b in filteredStockItems) {
            totalStockBalance += b.balance;
            totalPrincipal += b.principal;
          }
          for (var ab in filteredAccountBalances) {
            totalCashBalance += ab.cashBalance;
          }

          final grandTotalBalance = totalStockBalance + totalCashBalance;
          final totalProfit = grandTotalBalance - totalPrincipal;

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
                  // 💡 상단 컨트롤 바: 좌측 기준년월 콤보박스 / 우측 계좌선택 콤보박스
                  Row(
                    children: [
                      // 1. 좌측: 기준년월 선택 콤보박스
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
                                  ref.read(selectedYearMonthProvider.notifier).state = val;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 2. 우측: 계좌 선택 콤보박스
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

                  // 전체 요약 카드
                  Card(
                    elevation: 0,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.indigo.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('총 자산 (주식+현금)', grandTotalBalance.toWon()),
                          _buildSummaryItem('투자 원금', totalPrincipal.toWon()),
                          _buildSummaryItem(
                            '평가 손익',
                            '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
                            color: totalProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 계좌별 현금 및 자금 요약 제목
                  const Text(
                    '계좌별 현금 및 자금 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // 계좌별 요약 리스트
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

                  // 종목별 내역 리스트
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
                                              '현재가: ${item.currentPrice.toWon()}',
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
                                        item.balance.toWon(),
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

  // 계좌별 요약 리스트 렌더링 헬퍼 메서드
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

        final accBalanceData = accountBalanceMap[accId];
        final cash = accBalanceData?.cashBalance ?? 0.0;
        final monthlyWith = accBalanceData?.monthlyWithdrawal ?? 0.0;
        final totalWith = accBalanceData?.totalWithdrawal ?? 0.0;

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
                      Text(
                        '$institution - $accName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '현금성 잔액: ${cash.toWon()} | 당월 인출: ${monthlyWith.toWon()} (누적: ${totalWith.toWon()})',
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
                      suffixText: '원',
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
                      suffixText: '원',
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
  ) {
    final qtyController = TextEditingController(
      text: item.quantity > 0 ? item.quantity.toString() : '',
    );
    final priceController = TextEditingController(
      text: item.currentPrice > 0 ? item.currentPrice.toCommaString() : '',
    );
    
    // 입력 항목: 당월 투자금, 당월 배당금(기타수입 등), 당월 매도액
    final monthlyPrincipalController = TextEditingController();
    final monthlyPayoutController = TextEditingController();
    final monthlyWithdrawalController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    // 전월 누적 데이터 조회 (디스플레이용)
    final prevYearMonth = _getPreviousYearMonth(item.yearMonth);
    final prevItems = ref.read(monthlyStockBalanceNotifierProvider(prevYearMonth)).value ?? [];
    final prevItem = prevItems.firstWhereOrNull(
      (b) => b.accountId == item.accountId && b.stockItemId == item.stockItemId,
    );

    final displayPrincipal = item.principal; // 누적 투자금
    final displayPayout = item.totalPayout; // 누적 배당금
    final displayWithdrawal = item.totalWithdrawal; // 누적 매도액

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
                          '$stockName (${item.yearMonth}) 수정',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const SizedBox(height: 8),

                  // 💡 누적 데이터 디스플레이 영역 (읽기 전용)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 누적 현황 (자동계산)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('누적 투자금: ${displayPrincipal.toWon()}', style: const TextStyle(fontSize: 12)),
                            Text('누적 배당금: ${displayPayout.toWon()}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('누적 매도액: ${displayWithdrawal.toWon()}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 수량 및 현재가
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: qtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: '보유 수량',
                            suffixText: '주',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '수량 입력' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: '주당 현재가',
                            suffixText: '원',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? '현재가 입력' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 입력 항목 1: 당월 투자금
                  TextFormField(
                    controller: monthlyPrincipalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '당월 투자금',
                      hintText: '0',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 입력 항목 2: 당월 배당금(기타수입 등)
                  TextFormField(
                    controller: monthlyPayoutController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '당월 배당금(기타수입 등)',
                      hintText: '0',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 입력 항목 3: 당월 매도액
                  TextFormField(
                    controller: monthlyWithdrawalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: '당월 매도액',
                      hintText: '0',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;

                        final qty = double.tryParse(qtyController.text.replaceAll(',', '').trim()) ?? 0.0;
                        final price = double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9.]'), '').trim()) ?? 0.0;
                        
                        final monthlyPrincipal = double.tryParse(monthlyPrincipalController.text.replaceAll(',', '').trim()) ?? 0.0;
                        final monthlyPayout = double.tryParse(monthlyPayoutController.text.replaceAll(',', '').trim()) ?? 0.0;
                        final monthlyWithdrawal = double.tryParse(monthlyWithdrawalController.text.replaceAll(',', '').trim()) ?? 0.0;

                        // 전원 누적값 기준 산출
                        final prevPrincipal = prevItem?.principal ?? item.principal - item.monthlyPrincipal;
                        final prevPayout = prevItem?.totalPayout ?? item.totalPayout - item.monthlyPayout;
                        final prevWithdrawal = prevItem?.totalWithdrawal ?? item.totalWithdrawal - item.monthlyWithdrawal;

                        final newPrincipal = prevPrincipal + monthlyPrincipal;
                        final newPayout = prevPayout + monthlyPayout;
                        final newWithdrawal = prevWithdrawal + monthlyWithdrawal;

                        final updatedItem = item.copyWith(
                          quantity: qty,
                          currentPrice: price,
                          balance: qty * price,
                          principal: newPrincipal,
                          monthlyPrincipal: monthlyPrincipal,
                          totalPayout: newPayout,
                          monthlyPayout: monthlyPayout,
                          totalWithdrawal: newWithdrawal,
                          monthlyWithdrawal: monthlyWithdrawal,
                        );

                        await ref
                            .read(monthlyStockBalanceNotifierProvider(item.yearMonth).notifier)
                            .saveBalance(updatedItem);

                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      child: const Text('종목 정보 저장', style: TextStyle(fontSize: 16)),
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
      builder: (dialogContext) => AlertDialog(
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
                    .read(monthlyStockBalanceNotifierProvider(item.yearMonth).notifier)
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