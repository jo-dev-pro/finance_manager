import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../core/widgets/summary_item.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../monthly_data/monthly_pension_balance_screen.dart';
import 'widgets/monthly_pension_account_summary_list.dart';

class MonthlyPensionSummaryScreen extends ConsumerWidget {
  final Object? extra;

  const MonthlyPensionSummaryScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? initialMonth;
    String? initialAccountId;

    if (extra is Map<String, dynamic>) {
      initialMonth = (extra as Map<String, dynamic>)['yearMonth'] as String?;
      initialAccountId = (extra as Map<String, dynamic>)['accountId'] as String?;
    } else if (extra is String) {
      initialMonth = extra as String;
    }

    if (initialAccountId != null) {
      final currentFilter = ref.read(selectedPensionAccountFilterProvider);
      if (currentFilter == null) {
        Future.microtask(() {
          ref.read(selectedPensionAccountFilterProvider.notifier).state = initialAccountId;
        });
      }
    }

    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth =
        selectedMonth ??
        initialMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final selectedAccountId = ref.watch(selectedPensionAccountFilterProvider);

    final balancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(targetMonth),
    );
    final accountBalancesAsync = ref.watch(
      monthlyPensionAccountBalanceNotifierProvider(targetMonth),
    );
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('연금 월말평가'),
      ),
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

          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final products = productsAsync.value ?? [];
          final accountBalances = accountBalancesAsync.value ?? [];
          final items = balancesAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final productMap = {for (var p in products) p.id!: p.productName};
          final accountBalanceMap = {for (var ab in accountBalances) ab.accountId: ab};

          final pensionAccounts = accounts
              .where((a) => a.accountType.trim() == '연금' && a.status == '활동')
              .toList();

          final isValidAccountId = selectedAccountId == null ||
              pensionAccounts.any((acc) => acc.id == selectedAccountId);
          final currentDropdownValue = isValidAccountId ? selectedAccountId : null;

          final filteredAccountBalances = currentDropdownValue == null
              ? accountBalances
              : accountBalances.where((ab) => ab.accountId == currentDropdownValue).toList();

          final filteredPensionItems = currentDropdownValue == null
              ? items
              : items.where((item) => item.accountId == currentDropdownValue).toList();

          double totalPensionBalance = 0;
          double totalPensionPrincipal = 0;
          double totalCashBalance = 0;
          double totalMonthlyWithdrawal = 0;
          double totalCumulativeWithdrawal = 0;
          double totalCumulativePayout = 0; // 누적 연금 수령액 합산용

          for (var b in filteredPensionItems) {
            totalPensionBalance += b.balance;
            totalPensionPrincipal += b.principal;
            totalCumulativePayout += b.totalPayout; // 모델의 totalPayout 합산[cite: 8]
          }

          for (var ab in filteredAccountBalances) {
            totalCashBalance += ab.cashBalance;
            totalMonthlyWithdrawal += ab.monthlyWithdrawal; // 계좌별 당월 인출[cite: 7]
            totalCumulativeWithdrawal += ab.totalWithdrawal;     // 계좌별 누적 인출[cite: 7]
          }

          final grandTotalBalance = totalPensionBalance + totalCashBalance;
          // [총 손익] = (총 자산 + 누적 연금 수령액 + 누적 인출액) - 총 원금
          final totalProfit = (grandTotalBalance + totalCumulativePayout + totalCumulativeWithdrawal) - totalPensionPrincipal;

          return MainConstrainedBox(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 드롭다운 영역
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
                              value: months.contains(activeCurrentMonth) ? activeCurrentMonth : months.first,
                              isExpanded: true,
                              items: months.map((ym) {
                                return DropdownMenuItem(
                                  value: ym,
                                  child: Text(ym, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref.read(selectedYearMonthProvider.notifier).select(val);
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
                                  child: Text('전체 계좌', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                ...pensionAccounts.map((account) {
                                  final accId = account.id ?? '';
                                  final nameObj = accountNameMap[account.accountNameId];
                                  final accName = nameObj?.accountName ?? '계좌';
                                  final institution = account.financialInstitution;
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
                                ref.read(selectedPensionAccountFilterProvider.notifier).state = val;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 💡 최상단 요약 카드 (총자산, 총원금, 총손익 / 현금성잔액, 당월인출액, 누적인출액)
                  Card(
                    elevation: 0,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.indigo.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SummaryItem(label: '총 자산', value: grandTotalBalance.toWon()),
                              SummaryItem(label: '총 원금', value: totalPensionPrincipal.toWon()),
                              SummaryItem(
                                label: '총 손익',
                                value: '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
                                color: totalProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SummaryItem(label: '현금성 잔액(예수금)', value: totalCashBalance.toWon()),
                              SummaryItem(label: '당월 인출액', value: totalMonthlyWithdrawal.toWon()),
                              SummaryItem(label: '누적 인출액', value: totalCumulativeWithdrawal.toWon()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    '계좌별 현금 및 자금 요약',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 계좌별 현금 및 자금 요약 리스트
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
                      child: Center(child: Text('$activeCurrentMonth에 등록된 연금 월말 데이터가 없습니다.')),
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

                        final bool isCashAsset =
                            balanceItem.productId ==
                            '_CASH_ASSET_PRODUCT_ID_';
                        final String displayName =
                            isCashAsset
                                ? '💵 계좌 공통 현금성 자산 (예수금)'
                                : (productMap[balanceItem.productId] ??
                                    '알 수 없는 상품');

                        final isProfit = balanceItem.returnRate >= 0;
                        final returnColor = isProfit ? Colors.red.shade700 : Colors.blue.shade700;

                        // 💡 상품별 연금 지급 필드 정확히 연동 (monthlyPayout, totalPayout)[cite: 8]
                        final double monthlyPensionPayment = balanceItem.monthlyPayout;
                        final double cumulativePensionPayment = balanceItem.totalPayout;

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
                                  // 첫 줄: 상품명만 단독 표시
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // 소속 계좌 및 최초 매수일
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      if (!isCashAsset && balanceItem.purchaseDate != null && balanceItem.purchaseDate!.isNotEmpty)
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

                                  // 평가액 및 원금
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '평가액: ${balanceItem.balance.toWon()}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        '원금: ${balanceItem.principal.toWon()}',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // 수익률 및 연환산 수익률
                                  if (!isCashAsset) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '수익률: ${isProfit ? '+' : ''}${balanceItem.returnRate.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: returnColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '(연환산: ${balanceItem.annualizedReturnRate.toStringAsFixed(1)}%)',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  // 💡 당월 연금지급 및 누적 연금지급 표시 영역
                                  const Divider(height: 12, color: Colors.black12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '당월 연금지급: ${monthlyPensionPayment.toWon()}',
                                        style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
                                      ),
                                      Text(
                                        '누적 연금지급: ${cumulativePensionPayment.toWon()}',
                                        style: TextStyle(fontSize: 12, color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
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
}