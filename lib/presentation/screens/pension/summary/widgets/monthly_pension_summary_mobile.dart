import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/widgets/jtext.dart';
import '../../../../../core/widgets/summary_item.dart';
import '../../../../../models/account/account_name.dart';
import '../../../../../models/account/account.dart';
import '../../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../../providers/dashboard/dashboard_provider.dart';
import '../../monthly_data/monthly_pension_balance_screen.dart';
import 'monthly_pension_account_summary_list.dart';

class MonthlyPensionSummaryMobile extends ConsumerWidget {
  final List<String> months;
  final String activeCurrentMonth;
  final List<Account> pensionAccounts;
  final Map<String?, AccountName?> accountNameMap;
  final Map<String, MonthlyPensionAccountBalance> accountBalanceMap;
  final String? currentDropdownValue;
  final double grandTotalBalance;
  final double totalPensionPrincipal;
  final double totalProfit;
  final double totalCashBalance;
  final double totalMonthlyWithdrawal;
  final double totalCumulativeWithdrawal;
  final double summaryDiffFromLastMonth;
  final List<MonthlyPensionBalance> filteredPensionItems;
  final Map<String, Account> accountMap;
  final Map<String, String> productMap;
  final List<MonthlyPensionBalance> lastItems;

  const MonthlyPensionSummaryMobile({
    super.key,
    required this.months,
    required this.activeCurrentMonth,
    required this.pensionAccounts,
    required this.accountNameMap,
    required this.accountBalanceMap,
    required this.currentDropdownValue,
    required this.grandTotalBalance,
    required this.totalPensionPrincipal,
    required this.totalProfit,
    required this.totalCashBalance,
    required this.totalMonthlyWithdrawal,
    required this.totalCumulativeWithdrawal,
    required this.summaryDiffFromLastMonth,
    required this.filteredPensionItems,
    required this.accountMap,
    required this.productMap,
    required this.lastItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      value: months.contains(activeCurrentMonth)
                          ? activeCurrentMonth
                          : months.first,
                      isExpanded: true,
                      items: months.map((ym) {
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
                        ref
                            .read(
                              selectedPensionAccountFilterProvider.notifier,
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryItem(
                  label: '총 자산',
                  value: grandTotalBalance.toWon(),
                ),
                SummaryItem(
                  label: '총 원금',
                  value: totalPensionPrincipal.toWon(),
                ),
                SummaryItem(
                  label: '총 손익',
                  value:
                      '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
                  color: totalProfit >= 0
                      ? Colors.red.shade300
                      : Colors.blue.shade300,
                ),
                const SizedBox(height: 14),

                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 14),

                SummaryItem(
                  label: '현금잔액',
                  value: totalCashBalance.toWon(),
                ),
                SummaryItem(
                  label: '당월 인출',
                  value: totalMonthlyWithdrawal.toWon(),
                ),
                SummaryItem(
                  label: '누적 인출',
                  value: totalCumulativeWithdrawal.toWon(),
                ),
                const SizedBox(height: 14),

                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 10),

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
                final nameObj = matchedAcc != null
                    ? accountNameMap[matchedAcc.accountNameId]
                    : null;
                final accountName = nameObj?.accountName ?? '연금계좌';
                final String displayName =
                    productMap[balanceItem.productId] ?? '알 수 없는 상품';
                final lastBalanceItem = lastItems.firstWhereOrNull(
                  (item) =>
                      item.accountId == balanceItem.accountId &&
                      item.productId == balanceItem.productId,
                );
                final lastBalance = lastBalanceItem?.balance ?? 0.0;
                final diffFromLastMonth = balanceItem.balance - lastBalance;
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
                              JText(
                                '평가액: ${balanceItem.balance.toWon()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              JText(
                                '원금: ${balanceItem.principal.toWon()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                                JText(
                                  '당월 매도: ${monthlySale.toWon()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                JText(
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
                                    withParentheses: false,
                                  ),
                                  const SizedBox(width: 6),
                                  JText(
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
    );
  }
}