import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_extension.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';
import 'widgets/monthly_stock_summary_desktop.dart';
import 'widgets/monthly_stock_summary_mobile.dart';

final selectedStockAccountFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

class MonthlyStockSummaryScreen extends ConsumerWidget {
  final Object? extra;

  const MonthlyStockSummaryScreen({super.key, this.extra});

  String _getLastYearMonth(String currentYearMonth) {
    try {
      final parts = currentYearMonth.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      DateTime lastMonthDate = DateTime(year, month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return currentYearMonth;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? initialMonth;
    String? initialAccountId;

    if (extra is Map<String, dynamic>) {
      initialMonth = (extra as Map<String, dynamic>)['yearMonth'] as String?;
      initialAccountId =
          (extra as Map<String, dynamic>)['accountId'] as String?;
    } else if (extra is String) {
      initialMonth = extra as String;
    }

    if (initialAccountId != null) {
      final currentFilter = ref.read(selectedStockAccountFilterProvider);
      if (currentFilter == null) {
        Future.microtask(() {
          ref.read(selectedStockAccountFilterProvider.notifier).state =
              initialAccountId;
        });
      }
    }

    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final selectedAccountId = ref.watch(selectedStockAccountFilterProvider);

    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주식 월말평가')),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 주식 데이터가 없습니다.'));
          }

          final activeCurrentMonth =
              (selectedMonth != null && months.contains(selectedMonth))
                  ? selectedMonth
                  : (initialMonth != null && months.contains(initialMonth))
                  ? initialMonth
                  : months.first;

          if (selectedMonth == null || !months.contains(selectedMonth)) {
            Future.microtask(() {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .select(activeCurrentMonth);
            });
          }

          final lastMonth = _getLastYearMonth(activeCurrentMonth);

          final items =
              ref
                  .watch(
                    monthlyStockBalanceNotifierProvider(activeCurrentMonth),
                  )
                  .value ??
              [];
          final lastItems =
              ref.watch(monthlyStockBalanceNotifierProvider(lastMonth)).value ??
              [];

          final accountBalances =
              ref
                  .watch(
                    monthlyStockAccountBalanceNotifierProvider(
                      activeCurrentMonth,
                    ),
                  )
                  .value ??
              [];
          final lastAccountBalances =
              ref
                  .watch(monthlyStockAccountBalanceNotifierProvider(lastMonth))
                  .value ??
              [];

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};
          final accountBalanceMap = {
            for (var ab in accountBalances) ab.accountId: ab,
          };

          final stockAccounts =
              accounts
                  .where(
                    (a) => a.accountType.trim() == '증권' && a.status == '활동',
                  )
                  .toList();

          final isValidAccountId =
              selectedAccountId == null ||
              stockAccounts.any((acc) => acc.id == selectedAccountId);
          final currentDropdownValue =
              isValidAccountId ? selectedAccountId : null;

          final selectedAcc =
              currentDropdownValue != null
                  ? accountMap[currentDropdownValue]
                  : null;
          final isSingleOverseasAccount =
              selectedAcc?.isForeignCurrency ?? false;

          // 필터링된 당월/전월 데이터
          final filteredAccountBalances =
              currentDropdownValue == null
                  ? accountBalances
                  : accountBalances
                      .where((ab) => ab.accountId == currentDropdownValue)
                      .toList();

          final filteredStockItems =
              currentDropdownValue == null
                  ? items
                  : items
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          final lastFilteredAccountBalances =
              currentDropdownValue == null
                  ? lastAccountBalances
                  : lastAccountBalances
                      .where((ab) => ab.accountId == currentDropdownValue)
                      .toList();

          final lastFilteredStockItems =
              currentDropdownValue == null
                  ? lastItems
                  : lastItems
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          // 당월/전월 환율 맵 (단일 해외계좌 필터 시에는 원래 달러 단위 유지를 위해 1.0 적용)
          final exchangeRateMap = {
            for (var ab in accountBalances)
              ab.accountId:
                  (!isSingleOverseasAccount &&
                          (accountMap[ab.accountId]?.isForeignCurrency ??
                              false) &&
                          ab.exchangeRate > 0)
                      ? ab.exchangeRate
                      : 1.0,
          };
          final lastExchangeRateMap = {
            for (var lab in lastAccountBalances)
              lab.accountId:
                  (!isSingleOverseasAccount &&
                          (accountMap[lab.accountId]?.isForeignCurrency ??
                              false) &&
                          lab.exchangeRate > 0)
                      ? lab.exchangeRate
                      : 1.0,
          };

          double totalStockBalance = 0;
          double totalPrincipal = 0;
          double totalCashBalance = 0;
          double totalPayout = 0;
          double totalCumulativeWithdrawal = 0;
          double appliedExchangeRate = 1.0;

          for (var item in filteredStockItems) {
            final rate = exchangeRateMap[item.accountId] ?? 1.0;
            totalStockBalance += item.balance * rate;
            totalPayout += item.totalPayout * rate;
            totalCumulativeWithdrawal += item.totalWithdrawal * rate;
          }

          for (var ab in filteredAccountBalances) {
            final rate = exchangeRateMap[ab.accountId] ?? 1.0;
            totalCashBalance += ab.cashBalance * rate;
            totalPrincipal += ab.principal * rate;
            totalCumulativeWithdrawal += ab.totalWithdrawal * rate;
            if (ab.exchangeRate > 1.0) {
              appliedExchangeRate = ab.exchangeRate;
            }
          }

          final grandTotalBalance = totalStockBalance + totalCashBalance;
          final totalProfit =
              (grandTotalBalance + totalPayout + totalCumulativeWithdrawal) -
              totalPrincipal;

          // 전월 총 자산 집계
          final lastTotalStockBalance = lastFilteredStockItems.fold<double>(
            0.0,
            (sum, item) =>
                sum +
                (item.balance * (lastExchangeRateMap[item.accountId] ?? 1.0)),
          );
          final lastTotalCashBalance = lastFilteredAccountBalances.fold<double>(
            0.0,
            (sum, ab) =>
                sum +
                (ab.cashBalance * (lastExchangeRateMap[ab.accountId] ?? 1.0)),
          );
          final lastGrandTotalBalance =
              lastTotalStockBalance + lastTotalCashBalance;
          final summaryDiffFromLastMonth =
              grandTotalBalance - lastGrandTotalBalance;

          String formatCurrency(double val) {
            return isSingleOverseasAccount ? val.toUSD() : val.round().toWon();
          }

         return MainConstrainedBox(
            child: context.isMobile
                ? MonthlyStockSummaryMobile(
                    months: months,
                    activeCurrentMonth: activeCurrentMonth,
                    stockAccounts: stockAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    currentDropdownValue: currentDropdownValue,
                    isSingleOverseasAccount: isSingleOverseasAccount,
                    appliedExchangeRate: appliedExchangeRate,
                    grandTotalBalance: grandTotalBalance,
                    totalPrincipal: totalPrincipal,
                    totalProfit: totalProfit,
                    totalCashBalance: totalCashBalance,
                    totalPayout: totalPayout,
                    totalCumulativeWithdrawal: totalCumulativeWithdrawal,
                    summaryDiffFromLastMonth: summaryDiffFromLastMonth,
                    filteredStockItems: filteredStockItems,
                    accountMap: accountMap,
                    stockItemMap: stockItemMap,
                    lastItems: lastItems,
                  )
                : MonthlyStockSummaryDesktop(
                    months: months,
                    activeCurrentMonth: activeCurrentMonth,
                    stockAccounts: stockAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    currentDropdownValue: currentDropdownValue,
                    isSingleOverseasAccount: isSingleOverseasAccount,
                    appliedExchangeRate: appliedExchangeRate,
                    grandTotalBalance: grandTotalBalance,
                    totalPrincipal: totalPrincipal,
                    totalProfit: totalProfit,
                    totalCashBalance: totalCashBalance,
                    totalPayout: totalPayout,
                    totalCumulativeWithdrawal: totalCumulativeWithdrawal,
                    summaryDiffFromLastMonth: summaryDiffFromLastMonth,
                    filteredStockItems: filteredStockItems,
                    accountMap: accountMap,
                    stockItemMap: stockItemMap,
                    lastItems: lastItems,
                  ),
          );
        },
      ),
    );
  }
}
