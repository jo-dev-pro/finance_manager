import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/account/account_name.dart';
import '../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../core/utils/number_formatter.dart';

class MonthlyPensionAccountSummaryList extends ConsumerWidget {
  final List<dynamic> pensionAccounts;
  final Map<String?, AccountName?> accountNameMap;
  final Map<String, MonthlyPensionAccountBalance> accountBalanceMap;
  final String? selectedAccountId;
  final String targetMonth;
  final void Function(
    String accountId,
    String accountDisplayName,
    MonthlyPensionAccountBalance? currentBalance,
  ) onEditPressed;
 
  const MonthlyPensionAccountSummaryList({
    super.key,
    required this.pensionAccounts,
    required this.accountNameMap,
    required this.accountBalanceMap,
    required this.selectedAccountId,
    required this.targetMonth,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pensionAccounts.isEmpty) {
      return const Text('등록된 연금 계좌가 없습니다.', style: TextStyle(color: Colors.grey));
    }

    final displayAccounts = selectedAccountId == null
        ? pensionAccounts
        : pensionAccounts.where((a) => a.id == selectedAccountId).toList();

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
                        '$institution -$accName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '현금성 잔액: ${cash.toWon()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 8),
                          Text('|', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                          const SizedBox(width: 8),
                          Text(
                            '당월 인출: ${monthlyWith.toWon()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(누적: ${totalWith.toWon()})',
                            style: TextStyle(fontSize: 11, color: Colors.indigo.shade600, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.indigo),
                  onPressed: () => onEditPressed(
                    accId,
                    '$institution$accName',
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
}