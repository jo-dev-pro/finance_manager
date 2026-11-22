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
  final Set<String> lastAccountIds;
  final Function(String accountId)? onAccountTap;

  const StockAccountGrid({
    super.key,
    required this.currentMonth,
    required this.lastMonth,
    this.lastAccountIds = const {},
    this.onAccountTap,
  });

  static const String _lastAccountName = '지니';

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

    bool isGenieAccount(String accountId) {
      if (lastAccountIds.contains(accountId)) return true;
      final matchedAcc = accountMap[accountId];
      final name =
          matchedAcc != null
              ? accountNameMap[matchedAcc.accountNameId]?.accountName.trim()
              : null;
      return name == _lastAccountName;
    }

    final rawAccountIds = accountGroups.keys.toList();
    final originalIndexMap = {
      for (var i = 0; i < rawAccountIds.length; i++) rawAccountIds[i]: i,
    };
    final accountIds = [...rawAccountIds]..sort((a, b) {
      final aIsGenie = isGenieAccount(a);
      final bIsGenie = isGenieAccount(b);
      if (aIsGenie == bIsGenie) {
        return (originalIndexMap[a] ?? 0).compareTo(originalIndexMap[b] ?? 0);
      }
      return aIsGenie ? 1 : -1;
    });

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
        // 계좌 원금(principal)은 이미 원화 기준으로 저장되므로 환율을 곱하지 않음
        final accountPrincipal = (accBalObj?.principal ?? 0.0).roundToDouble();
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