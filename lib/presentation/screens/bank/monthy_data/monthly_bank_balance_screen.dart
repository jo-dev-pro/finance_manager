import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_button.dart';
import '../../../../core/widgets/edit_delete_button.dart';
import '../../../../core/widgets/jtext.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../core/widgets/month_selector_header.dart';
import '../../../../models/monthly_data/monthly_bank_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_bank_balance_provider.dart';
import 'widgets/monthly_bank_balance_dialog.dart';

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
      appBar: AppBar(
        title: const Text('월말 잔액 관리'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 월말 잔액 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (months.contains(targetMonth)) ? targetMonth : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
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
                SizedBox(height: 16),

                Expanded(
                  child: balancesAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (err, stack) =>
                            Center(child: Text('데이터를 불러오지 못했습니다: $err')),
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            '$activeCurrentMonth에 등록된 월말 은행 데이터가 없습니다.',
                          ),
                        );
                      }

                      final accounts = accountsAsync.value ?? [];
                      final accountNames = accountNamesAsync.value ?? [];

                      final accountMap = {for (var a in accounts) a.id!: a};
                      final accountNameMap = {
                        for (var an in accountNames) an.id: an,
                      };

                      return SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final balanceItem = items[index];

                            final matchedAccount =
                                accountMap[balanceItem.accountId];
                            final institution =
                                matchedAccount?.financialInstitution ??
                                '기타 금융기관';
                            final nameObj =
                                matchedAccount != null
                                    ? accountNameMap[matchedAccount
                                        .accountNameId]
                                    : null;
                            final accountName = nameObj?.accountName ?? '일반계좌';
                            final String? logoUrl = matchedAccount?.logoUrl;
                            final String? accountNumber =
                                matchedAccount?.accountNumber;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: 1,
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
                                            logoUrl != null &&
                                                    logoUrl.isNotEmpty
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(width: 16),

                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    balanceItem.yearMonth,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            JText(
                                              '$institution${accountNumber != null && accountNumber.isNotEmpty ? ' \vert{} $accountNumber' : ''}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          JText(
                                            balanceItem.balance.toWon(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // 수정 & 삭제 버튼
                                          EditDeleteButtons(
                                            onEdit:
                                                () => _showEditDialog(
                                                  context,
                                                  balanceItem,
                                                  accountName,
                                                ),
                                            onDelete:
                                                () => _confirmDelete(
                                                  context,
                                                  ref,
                                                  balanceItem,
                                                  accountName,
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
    MonthlyBankBalance balanceItem,
    String accountName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => MonthlyBankBalanceDialog(
            yearMonth: balanceItem.yearMonth,
            editItem: balanceItem, // 💡 수정 모드 활성화
            accountNameText: accountName,
          ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MonthlyBankBalance item,
    String accountName,
  ) {
    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '$accountName의 ${item.yearMonth} 월말 데이터를 삭제하시겠습니까?',
      onDelete: () async {
        if (item.id != null) {
          try {
            await ref
                .read(
                  monthlyBankBalanceNotifierProvider(item.yearMonth).notifier,
                )
                .deleteBalance(item.id!);

            if (!context.mounted) return;
            AppSnackBar.showInfo(context, '월말 데이터가 삭제되었습니다.');
          } catch (e) {
            if (!context.mounted) return;
            AppSnackBar.showError(context, '삭제 실패: $e');
          }
        }
      },
    );
  }
}
