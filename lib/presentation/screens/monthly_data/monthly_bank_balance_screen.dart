import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../models/monthly_data/monthly_bank_balance.dart';
import '../../../providers/monthly_data/monthly_bank_balance_provider.dart';
import 'widget/monthly_bank_dialog.dart';

class MonthlyBankBalanceScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyBankBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBalancesAsync = ref.watch(allMonthlyBankBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('월말 잔액 관리')),
      body: allBalancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('등록된 월말 잔액 데이터가 없습니다.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allMonthlyBankBalancesProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final wrapper = items[index];
                      final balanceItem = wrapper.balanceItem;
                      final String? logoUrl = wrapper.account?.logoUrl;

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
                                  child: (logoUrl == null || logoUrl.isEmpty)
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
                                            wrapper.accountNameDisplay,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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
                                                fontSize: 11,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${wrapper.financialInstitution}${wrapper.account?.accountNumber != null && wrapper.account!.accountNumber!.isNotEmpty ? ' | ${wrapper.account!.accountNumber}' : ''}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      balanceItem.balance.toWon(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () => _showEditDialog(
                                            context,
                                            ref,
                                            wrapper,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => _confirmDelete(
                                            context,
                                            ref,
                                            balanceItem,
                                            wrapper.accountNameDisplay,
                                          ),
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
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('월말 잔액 추가 입력', style: TextStyle(fontSize: 16)),
            onPressed: () => _showAddDialog(context),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    MonthlyBankBalanceWithAccount wrapper,
  ) {
    final balanceItem = wrapper.balanceItem;
    final controller = TextEditingController(
      text: NumberFormat('#,###', 'ko_KR').format(balanceItem.balance),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${wrapper.accountNameDisplay} (${balanceItem.yearMonth}) 금액 수정',
        ),
        content: TextField(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final cleanText = controller.text.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );
              final newBalance = double.tryParse(cleanText) ?? 0.0;

              final updatedItem = balanceItem.copyWith(balance: newBalance);
              await ref
                  .read(
                    monthlyBankBalanceNotifierProvider(
                      balanceItem.yearMonth,
                    ).notifier,
                  )
                  .saveBalance(updatedItem);

              if (context.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('저장'),
          ),
        ],
      ),
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
              if (context.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final now = DateFormat('yyyy-MM').format(DateTime.now());
    showDialog(
      context: context,
      builder: (context) => MonthlyBankDialog(yearMonth: initialYearMonth ?? now),
    );
  }
}