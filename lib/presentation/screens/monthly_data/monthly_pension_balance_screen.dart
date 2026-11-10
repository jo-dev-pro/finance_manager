import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/bottom_action_button.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/summary_item.dart';
import '../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../providers/pension/pension_product_provider.dart';
import 'widget/monthly_pension_balance_dialog.dart';
import 'widget/monthly_pension_account_summary_list.dart'; // 💡 계좌 요약 리스트 위젯 임포트

final selectedPensionAccountFilterProvider = StateProvider.autoDispose<String?>((ref) => null);

class MonthlyPensionBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyPensionBalanceScreen({super.key, this.initialYearMonth});

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

    final selectedAccountId = ref.watch(selectedPensionAccountFilterProvider);

    final balancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(targetMonth),
    );
    final accountBalancesAsync = ref.watch(
      monthlyPensionAccountBalanceNotifierProvider(targetMonth),
    );
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연금 월말 평가액 관리')),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 연금 데이터가 없습니다.'));
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
          final products = productsAsync.value ?? [];
          final accountBalances = accountBalancesAsync.value ?? [];
          final items = balancesAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final productMap = {for (var p in products) p.id!: p.productName};
          final accountBalanceMap = {for (var ab in accountBalances) ab.accountId: ab};

          final pensionAccounts = accounts
              .where((a) => a.accountType.trim() == '연금' && a.status == '활동')
              .toList();

          final filteredAccountBalances = selectedAccountId == null
              ? accountBalances
              : accountBalances.where((ab) => ab.accountId == selectedAccountId).toList();

          final filteredPensionItems = selectedAccountId == null
              ? items
              : items.where((item) => item.accountId == selectedAccountId).toList();

          double totalPensionBalance = 0;
          double totalPensionPrincipal = 0;
          double totalCashBalance = 0;

          for (var b in filteredPensionItems) {
            totalPensionBalance += b.balance;
            totalPensionPrincipal += b.principal;
          }

          for (var ab in filteredAccountBalances) {
            totalCashBalance += ab.cashBalance;
          }

          final grandTotalBalance = totalPensionBalance + totalCashBalance;
          final totalProfit = (grandTotalBalance) - totalPensionPrincipal;

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
                              value: months.contains(activeCurrentMonth) ? activeCurrentMonth : months.first,
                              isExpanded: true,
                              items: months.map((ym) {
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
                                ...pensionAccounts.map((acc) {
                                  final accId = acc.id ?? '';
                                  final nameObj = accountNameMap[acc.accountNameId];
                                  final accName = nameObj?.accountName ?? '계좌';
                                  final institution = acc.financialInstitution;
                                  return DropdownMenuItem<String?>(
                                    value: accId,
                                    child: Text(
                                      '$institution$accName',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                ref.read(selectedPensionAccountFilterProvider.notifier).state = val;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 요약 카드
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
                          SummaryItem(label: '총 자산', value: grandTotalBalance.toWon()),
                          SummaryItem(label: '총 원금', value: totalPensionPrincipal.toWon()),
                          SummaryItem(
                            label: '평가 손익',
                            value: '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
                            color: totalProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                          ),
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

                  // 💡 분리한 MonthlyPensionAccountSummaryList 위젯 호출
                  MonthlyPensionAccountSummaryList(
                    pensionAccounts: pensionAccounts,
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
                    '보유 상품별 월말 내역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (filteredPensionItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('$activeCurrentMonth에 등록된 연금 월말 데이터가 없습니다.')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPensionItems.length,
                      itemBuilder: (context, index) {
                        final balanceItem = filteredPensionItems[index];

                        final matchedAcc = accountMap[balanceItem.accountId];
                        final institution =
                            matchedAcc?.financialInstitution ?? '기타 금융기관';
                        final nameObj =
                            matchedAcc != null
                                ? accountNameMap[matchedAcc.accountNameId]
                                : null;
                        final accountName = nameObj?.accountName ?? '연금계좌';

                        final bool isCashAsset =
                            balanceItem.productId ==
                            '_CASH_ASSET_PRODUCT_ID_';
                        final String displayName =
                            isCashAsset
                                ? '💵 계좌 공통 현금성 자산 (예수금)'
                                : (productMap[balanceItem.productId] ??
                                    '알 수 없는 상품');

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
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '[$institution]$accountName',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (!isCashAsset && balanceItem.purchaseDate != null && balanceItem.purchaseDate!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '최초 매수일: ${balanceItem.purchaseDate}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.indigo.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        balanceItem.balance.toWon(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      EditDeleteButtons(
                                        onEdit: () => _showEditDialog(context, ref, balanceItem, displayName),
                                        onDelete: () => _confirmDelete(context, ref, balanceItem, displayName),
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
        label: '연금 월말 평가액 추가 입력',
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
      builder:
          (context) => MonthlyPensionBalanceDialog(yearMonth: currentMonth),
    );
  }

  void _showAccountEditBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String accountId,
    String accountDisplayName,
    String yearMonth,
    MonthlyPensionAccountBalance? currentAccountBalance,
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
                              monthlyPensionAccountBalanceNotifierProvider(prevYearMonth),
                            ).value ?? [];
                        final prevData = prevAccountBalances.firstWhereOrNull(
                          (b) => b.accountId == accountId,
                        );
                        final prevTotalWith = prevData?.totalWithdrawal ?? 0.0;
                        final finalTotalWith = prevTotalWith + monthlyWithVal;

                        final updatedAccountBalance = MonthlyPensionAccountBalance(
                          yearMonth: yearMonth,
                          accountId: accountId,
                          cashBalance: cashVal,
                          monthlyWithdrawal: monthlyWithVal,
                          totalWithdrawal: finalTotalWith,
                        );

                        await ref
                            .read(monthlyPensionAccountBalanceNotifierProvider(yearMonth).notifier)
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

  void _showEditDialog(
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
}