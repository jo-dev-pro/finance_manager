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
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../monthly_data/monthly_pension_balance_screen.dart';
import 'widgets/monthly_pension_summary_mobile.dart';
import 'widgets/monthly_pension_summary_desktop.dart';

class MonthlyPensionSummaryScreen extends ConsumerWidget {
  final Object? extra;

  const MonthlyPensionSummaryScreen({super.key, this.extra});

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
      final currentFilter = ref.read(selectedPensionAccountFilterProvider);
      if (currentFilter == null) {
        Future.microtask(() {
          ref.read(selectedPensionAccountFilterProvider.notifier).state =
              initialAccountId;
        });
      }
    }

    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth =
        selectedMonth ??
        initialMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final selectedAccountId = ref.watch(selectedPensionAccountFilterProvider);

    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연금 월말평가')),
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

          final lastMonth = _getLastYearMonth(activeCurrentMonth);

          final items =
              ref
                  .watch(
                    monthlyPensionBalanceNotifierProvider(activeCurrentMonth),
                  )
                  .value ??
              [];
          final lastItems =
              ref
                  .watch(monthlyPensionBalanceNotifierProvider(lastMonth))
                  .value ??
              [];

          final accountBalances =
              ref
                  .watch(
                    monthlyPensionAccountBalanceNotifierProvider(
                      activeCurrentMonth,
                    ),
                  )
                  .value ??
              [];
          final lastAccountBalances =
              ref
                  .watch(
                    monthlyPensionAccountBalanceNotifierProvider(lastMonth),
                  )
                  .value ??
              [];

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final products = productsAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final productMap = {for (var p in products) p.id!: p.productName};
          final accountBalanceMap = {
            for (var ab in accountBalances) ab.accountId: ab,
          };

          final pensionAccounts =
              accounts
                  .where(
                    (a) => a.accountType.trim() == '연금' && a.status == '활동',
                  )
                  .toList();

          final isValidAccountId =
              selectedAccountId == null ||
              pensionAccounts.any((acc) => acc.id == selectedAccountId);
          final currentDropdownValue =
              isValidAccountId ? selectedAccountId : null;

          final filteredAccountBalances =
              currentDropdownValue == null
                  ? accountBalances
                  : accountBalances
                      .where((ab) => ab.accountId == currentDropdownValue)
                      .toList();

          final filteredPensionItems =
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

          final lastFilteredPensionItems =
              currentDropdownValue == null
                  ? lastItems
                  : lastItems
                      .where((item) => item.accountId == currentDropdownValue)
                      .toList();

          double totalPensionBalance = 0;
          double totalPensionPrincipal = 0;
          double totalCashBalance = 0;
          double totalMonthlyWithdrawal = 0;
          double totalCumulativeWithdrawal = 0;

          for (var b in filteredPensionItems) {
            totalPensionBalance += b.balance;
          }

          for (var ab in filteredAccountBalances) {
            totalCashBalance += ab.cashBalance;
            totalMonthlyWithdrawal += ab.monthlyWithdrawal;
            totalCumulativeWithdrawal += ab.totalWithdrawal;
            totalPensionPrincipal += ab.principal;
          }

          final grandTotalBalance = totalPensionBalance + totalCashBalance;
          final totalProfit =
              (grandTotalBalance + totalCumulativeWithdrawal) -
              totalPensionPrincipal;

          final lastTotalPensionBalance = lastFilteredPensionItems.fold<double>(
            0.0,
            (sum, item) => sum + item.balance,
          );
          final lastTotalCashBalance = lastFilteredAccountBalances.fold<double>(
            0.0,
            (sum, ab) => sum + ab.cashBalance,
          );
          final lastGrandTotalBalance =
              lastTotalPensionBalance + lastTotalCashBalance;
          final summaryDiffFromLastMonth =
              grandTotalBalance - lastGrandTotalBalance;

          return MainConstrainedBox(
            child: context.isMobile
                ? MonthlyPensionSummaryMobile(
                    months: months,
                    activeCurrentMonth: activeCurrentMonth,
                    pensionAccounts: pensionAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    currentDropdownValue: currentDropdownValue,
                    grandTotalBalance: grandTotalBalance,
                    totalPensionPrincipal: totalPensionPrincipal,
                    totalProfit: totalProfit,
                    totalCashBalance: totalCashBalance,
                    totalMonthlyWithdrawal: totalMonthlyWithdrawal,
                    totalCumulativeWithdrawal: totalCumulativeWithdrawal,
                    summaryDiffFromLastMonth: summaryDiffFromLastMonth,
                    filteredPensionItems: filteredPensionItems,
                    accountMap: accountMap,
                    productMap: productMap,
                    lastItems: lastItems,
                  )
                : MonthlyPensionSummaryDesktop(
                    months: months,
                    activeCurrentMonth: activeCurrentMonth,
                    pensionAccounts: pensionAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    currentDropdownValue: currentDropdownValue,
                    grandTotalBalance: grandTotalBalance,
                    totalPensionPrincipal: totalPensionPrincipal,
                    totalProfit: totalProfit,
                    totalCashBalance: totalCashBalance,
                    totalMonthlyWithdrawal: totalMonthlyWithdrawal,
                    totalCumulativeWithdrawal: totalCumulativeWithdrawal,
                    summaryDiffFromLastMonth: summaryDiffFromLastMonth,
                    filteredPensionItems: filteredPensionItems,
                    accountMap: accountMap,
                    productMap: productMap,
                    lastItems: lastItems,
                  ),
          );
        },
      ),
    );
  }
}