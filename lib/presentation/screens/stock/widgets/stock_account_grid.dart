import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive_extension.dart';
import '../../../../core/widgets/account_card.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';

class StockAccountGrid extends ConsumerWidget {
  final String currentMonth;
  final String lastMonth;
  final Function(String accountId)? onAccountTap;

  const StockAccountGrid({
    super.key,
    required this.currentMonth,
    required this.lastMonth,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances =
        ref.watch(monthlyStockBalanceNotifierProvider(currentMonth)).value ??
            [];
    final lastBalances =
        ref.watch(monthlyStockBalanceNotifierProvider(lastMonth)).value ?? [];
    final accountBalances =
        ref
            .watch(monthlyStockAccountBalanceNotifierProvider(currentMonth))
            .value ??
        [];
    final lastAccountBalances =
        ref
            .watch(monthlyStockAccountBalanceNotifierProvider(lastMonth))
            .value ??
        [];
    final accounts = ref.watch(accountNotifierProvider).value ?? [];
    final accountNames = ref.watch(accountNameNotifierProvider).value ?? [];

    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    final Map<String, List<MonthlyStockBalance>> accountGroups = {};
    for (var item in balances) {
      accountGroups.putIfAbsent(item.accountId, () => []).add(item);
    }
    for (var ab in accountBalances) {
      accountGroups.putIfAbsent(ab.accountId, () => []);
    }

    final Map<String, List<MonthlyStockBalance>> lastAccountGroups = {};
    for (var item in lastBalances) {
      lastAccountGroups.putIfAbsent(item.accountId, () => []).add(item);
    }

    if (accountGroups.isEmpty) {
      return const Center(child: Text('등록된 주식 계좌 데이터가 없습니다.'));
    }

    final accountIds = accountGroups.keys.toList();

    final accountBalanceObjMap = {
      for (var ab in accountBalances) ab.accountId: ab,
    };
    final lastAccountBalanceObjMap = {
      for (var lab in lastAccountBalances) lab.accountId: lab,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 170,
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId] ?? [];
        final lastItems = lastAccountGroups[accountId] ?? [];

        final matchedAcc = accountMap[accountId];
        final isForeign = matchedAcc?.isForeignCurrency ?? false;

        final accBalObj = accountBalanceObjMap[accountId];
        final lastAccBalObj = lastAccountBalanceObjMap[accountId];

        final exchangeRate =
            (isForeign && (accBalObj?.exchangeRate ?? 0) > 0)
                ? accBalObj!.exchangeRate
                : 1.0;
        final lastExchangeRate =
            (isForeign && (lastAccBalObj?.exchangeRate ?? 0) > 0)
                ? lastAccBalObj!.exchangeRate
                : 1.0;

        final cashBalance =
            ((accBalObj?.cashBalance ?? 0.0) * exchangeRate).roundToDouble();
        final accountPrincipal =
            ((accBalObj?.principal ?? 0.0) * exchangeRate).roundToDouble();
        final accountWithdrawal =
            ((accBalObj?.totalWithdrawal ?? 0.0) * exchangeRate)
                .roundToDouble();

        final rawBalance = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final rawPayout = items.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPayout,
        );

        final totalAccountBalance =
            ((rawBalance * exchangeRate) + cashBalance).roundToDouble();
        final totalPayout = (rawPayout * exchangeRate).roundToDouble();

        final totalProfitOrLoss =
            (totalAccountBalance + totalPayout + accountWithdrawal) -
            accountPrincipal;
        final returnRate =
            accountPrincipal > 0
                ? (totalProfitOrLoss / accountPrincipal) * 100
                : 0.0;

        // 전월 대비 계산
        final lastRawBalance = lastItems.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final lastCashBalance =
            ((lastAccBalObj?.cashBalance ?? 0.0) * lastExchangeRate)
                .roundToDouble();
        final lastTotalAccountBalance =
            ((lastRawBalance * lastExchangeRate) + lastCashBalance)
                .roundToDouble();
        final diffFromLastMonth =
            totalAccountBalance - lastTotalAccountBalance;

        final matchedAccountName =
            matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;

        final institution = matchedAcc?.financialInstitution ?? '기타';
        final accountName = matchedAccountName?.accountName ?? accountId;

        return AccountCard(
          logoUrl: matchedAcc?.logoUrl,
          institution: institution,
          accountName: accountName,
          totalBalance: totalAccountBalance,
          totalPrincipal: accountPrincipal,
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