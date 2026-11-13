import 'package:flutter/material.dart';

import '../../../../core/widgets/account_card.dart';
import '../../../../models/account/account.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';

class PensionAccountGrid extends StatelessWidget {
  final List<String> accountIds;
  final Map<String, List<MonthlyPensionBalance>> accountGroups;
  final Map<String, double> accountCashMap;
  final Map<String, double> accountWithdrawalMap;
  final Map<String, List<MonthlyPensionBalance>> lastAccountGroups;
  final Map<String, double> lastAccountCashMap;
  final List<Account> accounts;
  final List<dynamic> accountNames;
  final List<dynamic> products;
  final Function(String accountId)? onAccountTap;

  const PensionAccountGrid({
    super.key,
    required this.accountIds,
    required this.accountGroups,
    required this.accountCashMap,
    required this.accountWithdrawalMap,
    required this.lastAccountGroups,
    required this.lastAccountCashMap,
    required this.accounts,
    required this.accountNames,
    required this.products,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 170,
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId] ?? [];
        final lastItems = lastAccountGroups[accountId] ?? [];

        final productSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final productPrincipalSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.principal,
        );

        final accountWithdrawal = accountWithdrawalMap[accountId] ?? 0.0;
        final cashBalance = accountCashMap[accountId] ?? 0.0;

        final totalAccountBalance = productSum + cashBalance;
        final totalAccountPrincipal = productPrincipalSum + cashBalance;

        final totalProfitOrLoss =
            (totalAccountBalance + accountWithdrawal) - totalAccountPrincipal;

        final returnRate =
            totalAccountPrincipal > 0
                ? (totalProfitOrLoss / totalAccountPrincipal) * 100
                : 0.0;

        final lastProductSum = lastItems.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final lastCashBalance = lastAccountCashMap[accountId] ?? 0.0;
        final lastTotalAccountBalance = lastProductSum + lastCashBalance;
        final diffFromLastMonth = totalAccountBalance - lastTotalAccountBalance;

        final matchedAcc = accountMap[accountId];
        final matchedAccountName =
            matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;
        final accountName = matchedAccountName?.accountName ?? accountId;

        return AccountCard(
          logoUrl: matchedAcc?.logoUrl,
          institution: '',
          accountName: accountName,
          totalBalance: totalAccountBalance,
          totalPrincipal: totalAccountPrincipal,
          totalProfitOrLoss: totalProfitOrLoss,
          returnRate: returnRate,
          totalWithdrawal: accountWithdrawal,
          diffFromLastMonth: diffFromLastMonth,
          itemCount: items.length,
          onTap: () {
            if (onAccountTap != null) {
              onAccountTap!(accountId); // 해당 계좌 ID를 전달하여 summary 화면으로 이동
            }
          },
        );
      },
    );
  }
}