import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/widgets/bottom_action_button.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../models/monthly_data/monthly_bank_balance.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_bank_balance_provider.dart';
import 'widget/monthly_bank_balance_dialog.dart';

class MonthlyBankBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyBankBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    
    final targetMonth =
        selectedMonth ??
        initialYearMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('월말 잔액 관리')),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 월말 잔액 데이터가 없습니다.'));
          }

          final activeCurrentMonth = (targetMonth != null && months.contains(targetMonth))
              ? targetMonth
              : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref.read(selectedYearMonthProvider.notifier).select(activeCurrentMonth);
            });
          }

          final balancesAsync = ref.watch(
            monthlyBankBalanceNotifierProvider(activeCurrentMonth),
          );
          final accountsAsync = ref.watch(accountNotifierProvider);
          final accountNamesAsync = ref.watch(accountNameNotifierProvider);

          return MainConstrainedBox(
            child: Column(
              children: [
                 MonthSelectorHeader(
                  months: months,
                  currentMonth: activeCurrentMonth,
                ),

                Expanded(
                  child: balancesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(child: Text('$activeCurrentMonth에 등록된 월말 은행 데이터가 없습니다.'));
                      }
            
                      final accounts = accountsAsync.value ?? [];
                      final accountNames = accountNamesAsync.value ?? [];
            
                      final accountMap = {for (var a in accounts) a.id!: a};
                      final accountNameMap = {for (var an in accountNames) an.id: an};
            
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final balanceItem = items[index];
            
                            final matchedAccount = accountMap[balanceItem.accountId];
                            final institution = matchedAccount?.financialInstitution ?? '기타 금융기관';
                            final nameObj = matchedAccount != null
                                ? accountNameMap[matchedAccount.accountNameId]
                                : null;
                            final accountName = nameObj?.accountName ?? '일반계좌';
                            final String? logoUrl = matchedAccount?.logoUrl;
                            final String? accountNumber = matchedAccount?.accountNumber;
            
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
                                      CircleAvatar(
                                        backgroundColor: Colors.grey.shade100,
                                        backgroundImage:
                                            logoUrl != null && logoUrl.isNotEmpty
                                                ? NetworkImage(logoUrl)
                                                : null,
                                        child:
                                            (logoUrl == null || logoUrl.isEmpty)
                                                ? Icon(
                                                  Icons.account_balance,
                                                  color: Colors.blue.shade700,
                                                )
                                                : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  accountName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(width: 16),

                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    balanceItem.yearMonth,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey.shade600,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$institution${accountNumber != null && accountNumber.isNotEmpty ? ' \vert{} $accountNumber' : ''}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
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
                                          const SizedBox(height: 8),
                                          
                                          // 수정 & 삭제 버튼
                                          EditDeleteButtons(
                                            onEdit: () => _showEditDialog(context, ref, balanceItem, accountName),
                                            onDelete: () => _confirmDelete(context, ref, balanceItem, accountName),
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
                ),
              ],
            ),
          );
        },
      ),
       bottomNavigationBar: BottomActionButton(
        label: '은행 월말 잔액 일괄 입력',
        onPressed: () => _showAddBottomSheet(context, targetMonth),
      ),
      // bottomNavigationBar: SafeArea(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: ElevatedButton.icon(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: Colors.indigo.shade600,
      //         foregroundColor: Colors.white,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //       ),
      //       icon: const Icon(Icons.add),
      //       label: const Text('월말 잔액 추가 입력', style: TextStyle(fontSize: 16)),
      //       onPressed: () {
      //         final currentSelected = ref.read(selectedYearMonthProvider) ?? 
      //             initialYearMonth ?? 
      //             DateFormat('yyyy-MM').format(DateTime.now());
      //         _showAddBottomSheet(context, currentSelected);
      //       },
      //     ),
      //   ),
      // ),
    );
  }

  void _showAddBottomSheet(BuildContext context, String currentMonth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MonthlyBankBalanceDialog(yearMonth: currentMonth),
    );
  }
  
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MonthlyBankBalance balanceItem,
    String accountName,
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
                        '$accountName (${balanceItem.yearMonth}) 금액 수정',
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
                      labelText: '금액 (원)',
                      suffixText: '원',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return '금액을 입력해 주세요.';
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
                              monthlyBankBalanceNotifierProvider(
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
    MonthlyBankBalance item,
    String accountName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('$accountName의 ${item.yearMonth} 월말 데이터를 삭제하시겠습니까?'),
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
                      monthlyBankBalanceNotifierProvider(
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