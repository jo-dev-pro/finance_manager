import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive_extension.dart';
import '../../../../core/widgets/account_card.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';

class PensionAccountGrid extends ConsumerWidget {
  final String currentMonth;
  final String lastMonth;
  final Function(String accountId)? onAccountTap;

  const PensionAccountGrid({
    super.key,
    required this.currentMonth,
    required this.lastMonth,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 필요한 데이터를 위젯 내부에서 직접 Provider로 구독
    final balancesAsync = ref.watch(
      monthlyPensionBalanceProvider(currentMonth),
    );
    final lastBalancesAsync = ref.watch(
      monthlyPensionBalanceProvider(lastMonth),
    );
    final accountBalancesAsync = ref.watch(
      monthlyPensionAccountBalanceProvider(currentMonth),
    );
    final lastAccountBalancesAsync = ref.watch(
      monthlyPensionAccountBalanceProvider(lastMonth),
    );
    final accountsAsync = ref.watch(accountProvider);
    final accountNamesAsync = ref.watch(accountNameProvider);

    // 데이터 추출
    final balances = balancesAsync.value ?? [];
    final lastBalances = lastBalancesAsync.value ?? [];
    final accountBalances = accountBalancesAsync.value ?? [];
    final lastAccountBalances = lastAccountBalancesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];
    final accountNames = accountNamesAsync.value ?? [];

    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    // 데이터 그룹화 및 맵 생성
    final Map<String, List<MonthlyPensionBalance>> accountGroups = {};
    for (var item in balances) {
      accountGroups.putIfAbsent(item.accountId, () => []).add(item);
    }
    for (var ab in accountBalances) {
      accountGroups.putIfAbsent(ab.accountId, () => []);
    }

    final Map<String, List<MonthlyPensionBalance>> lastAccountGroups = {};
    for (var item in lastBalances) {
      lastAccountGroups.putIfAbsent(item.accountId, () => []).add(item);
    }

    if (accountGroups.isEmpty) {
      return const Center(child: Text('등록된 연금 계좌 데이터가 없습니다.'));
    }

    final accountIds = accountGroups.keys.toList();

    // 💡 월말 계좌 DB의 누적 원금 매핑[cite: 9]
    final accountPrincipalMap = {
      for (var ab in accountBalances) ab.accountId: ab.principal,
    };
    final accountCashMap = {
      for (var ab in accountBalances) ab.accountId: ab.cashBalance,
    };
    final accountWithdrawalMap = {
      for (var ab in accountBalances) ab.accountId: ab.totalWithdrawal,
    };
    final lastAccountCashMap = {
      for (var lab in lastAccountBalances) lab.accountId: lab.cashBalance,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 1 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 4,
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

        final accountWithdrawal = accountWithdrawalMap[accountId] ?? 0.0;
        final cashBalance = accountCashMap[accountId] ?? 0.0;

        // 💡 월말 계좌 DB의 원금(principal) 사용[cite: 9]
        final totalAccountPrincipal = accountPrincipalMap[accountId] ?? 0.0;
        final totalAccountBalance = productSum + cashBalance;

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
              onAccountTap!(accountId);
            }
          },
        );
      },
    );
  }
}
