import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../monthly_data/monthly_pension_balance_screen.dart';
import 'widgets/monthly_pension_account_summary_list.dart';

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

          // 당월 및 전월 데이터 구독
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

          // 당월 필터링 데이터
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

          // 전월 필터링 데이터 (상단 요약 카드 전월 대비 계산용)
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

          // 당월 집계
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

          // 전월 총 자산 집계 및 전월 대비 계산
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 연월 및 계좌 드롭다운 필터
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value:
                                  months.contains(activeCurrentMonth)
                                      ? activeCurrentMonth
                                      : months.first,
                              isExpanded: true,
                              items:
                                  months.map((ym) {
                                    return DropdownMenuItem(
                                      value: ym,
                                      child: Text(
                                        ym,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                      .read(selectedYearMonthProvider.notifier)
                                      .select(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: currentDropdownValue,
                              isExpanded: true,
                              hint: const Text('전체 계좌'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    '전체 계좌',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                ...pensionAccounts.map((account) {
                                  final accId = account.id ?? '';
                                  final nameObj =
                                      accountNameMap[account.accountNameId];
                                  final accName = nameObj?.accountName ?? '계좌';
                                  final institution =
                                      account.financialInstitution;
                                  return DropdownMenuItem<String?>(
                                    value: accId,
                                    child: Text(
                                      '$institution$accName',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                ref
                                    .read(
                                      selectedPensionAccountFilterProvider
                                          .notifier,
                                    )
                                    .state = val;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. 상단 요약 카드 (SummaryCard 디자인 통일 + 전월 대비 추가)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWhiteSummaryItem(
                              label: '총 자산',
                              value: grandTotalBalance.toWon(),
                            ),
                            _buildWhiteSummaryItem(
                              label: '총 원금',
                              value: totalPensionPrincipal.toWon(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '총 손익',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                totalProfit.toSignedPriceText(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  positiveColor: const Color(0xFFFF8A80),
                                  negativeColor: const Color(0xFF82B1FF),
                                  zeroColor: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWhiteSummaryItem(
                              label: '현금성 잔액(예수금)',
                              value: totalCashBalance.toWon(),
                            ),
                            _buildWhiteSummaryItem(
                              label: '당월 인출액',
                              value: totalMonthlyWithdrawal.toWon(),
                            ),
                            _buildWhiteSummaryItem(
                              label: '누적 인출액',
                              value: totalCumulativeWithdrawal.toWon(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              '전월 대비: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            summaryDiffFromLastMonth.toSignedPriceText(
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              positiveColor: const Color(0xFFFF8A80),
                              negativeColor: const Color(0xFF82B1FF),
                              zeroColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '계좌별 현금 및 자금 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  MonthlyPensionAccountSummaryList(
                    pensionAccounts: pensionAccounts,
                    accountNameMap: accountNameMap,
                    accountBalanceMap: accountBalanceMap,
                    selectedAccountId: currentDropdownValue,
                    targetMonth: activeCurrentMonth,
                    onEditPressed: null,
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '보유 상품별 월말 내역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (filteredPensionItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          '$activeCurrentMonth에 등록된 연금 월말 데이터가 없습니다.',
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPensionItems.length,
                      itemBuilder: (context, index) {
                        final balanceItem = filteredPensionItems[index];

                        final matchedAcc = accountMap[balanceItem.accountId];
                        final institution =
                            matchedAcc?.financialInstitution ?? '기타 금융기관';
                        final nameObj =
                            matchedAcc != null
                                ? accountNameMap[matchedAcc.accountNameId]
                                : null;
                        final accountName = nameObj?.accountName ?? '연금계좌';

                        final String displayName =
                            productMap[balanceItem.productId] ??
                            '알 수 없는 상품';

                        // 전월 동일 계좌/상품 평가액 조회 및 전월 대비 계산
                        final lastBalanceItem = lastItems.firstWhereOrNull(
                          (item) =>
                              item.accountId == balanceItem.accountId &&
                              item.productId == balanceItem.productId,
                        );
                        final lastBalance = lastBalanceItem?.balance ?? 0.0;
                        final diffFromLastMonth =
                            balanceItem.balance - lastBalance;

                        final double returnRate = balanceItem.returnRate;
                        final double monthlySale = balanceItem.monthlySale;
                        final double totalSale = balanceItem.totalSale;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '[$institution]$accountName',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (balanceItem.purchaseDate != null &&
                                          balanceItem.purchaseDate!.isNotEmpty)
                                        Text(
                                          '매수일: ${balanceItem.purchaseDate}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.indigo.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '평가액: ${balanceItem.balance.toWon()}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '원금: ${balanceItem.principal.toWon()}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // 당월/누적 매도액 영역
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '당월 매도: ${monthlySale.toWon()}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.teal.shade700,
                                          ),
                                        ),
                                        Text(
                                          '누적 매도: ${totalSale.toWon()}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.teal.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Divider(
                                    height: 16,
                                    color: Colors.black12,
                                  ),

                                  // 수익률 및 전월 대비 영역
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '수익률: ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          returnRate.toSignedPercentText(
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            positiveColor: Colors.red.shade700,
                                            negativeColor: Colors.blue.shade700,
                                            withParentheses: false,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(연환산: ${balanceItem.annualizedReturnRate.toSignedPercent()})',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '전월 대비: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          diffFromLastMonth.toSignedPriceText(
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            positiveColor: Colors.red.shade700,
                                            negativeColor: Colors.blue.shade700,
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
    );
  }

  Widget _buildWhiteSummaryItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}