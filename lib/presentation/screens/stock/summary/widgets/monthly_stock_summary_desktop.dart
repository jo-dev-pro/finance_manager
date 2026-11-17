import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/widgets/jtext.dart';
import '../../../../../core/widgets/summary_item.dart';
import '../../../../../models/account/account_name.dart';
import '../../../../../models/account/account.dart';
import '../../../../../models/monthly_data/monthly_stock_account_balance.dart';
import '../../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../../models/stock/stock_item.dart';
import '../../../../../providers/dashboard/dashboard_provider.dart';
import '../../monthly_data/monthly_stock_balance_screen.dart';
import 'monthly_stock_account_summary_list.dart';

class MonthlyStockSummaryDesktop extends ConsumerWidget {
  final List<String> months;
  final String activeCurrentMonth;
  final List<Account> stockAccounts;
  final Map<String?, AccountName?> accountNameMap;
  final Map<String, MonthlyStockAccountBalance> accountBalanceMap;
  final String? currentDropdownValue;
  final bool isSingleOverseasAccount;
  final double appliedExchangeRate;
  final double grandTotalBalance;
  final double totalPrincipal;
  final double totalProfit;
  final double totalCashBalance;
  final double totalPayout;
  final double totalCumulativeWithdrawal;
  final double summaryDiffFromLastMonth;
  final List<MonthlyStockBalance> filteredStockItems;
  final Map<String, Account> accountMap;
  final Map<String, StockItem> stockItemMap;
  final List<MonthlyStockBalance> lastItems;

  const MonthlyStockSummaryDesktop({
    super.key,
    required this.months,
    required this.activeCurrentMonth,
    required this.stockAccounts,
    required this.accountNameMap,
    required this.accountBalanceMap,
    required this.currentDropdownValue,
    required this.isSingleOverseasAccount,
    required this.appliedExchangeRate,
    required this.grandTotalBalance,
    required this.totalPrincipal,
    required this.totalProfit,
    required this.totalCashBalance,
    required this.totalPayout,
    required this.totalCumulativeWithdrawal,
    required this.summaryDiffFromLastMonth,
    required this.filteredStockItems,
    required this.accountMap,
    required this.stockItemMap,
    required this.lastItems,
  });

  String formatCurrency(double val) {
    return isSingleOverseasAccount ? val.toUSD() : val.round().toWon();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 연월 및 계좌 선택 드롭다운
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
              const SizedBox(width: 16),
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
                        ...stockAccounts.map((account) {
                          final accId = account.id ?? '';
                          final nameObj = accountNameMap[account.accountNameId];
                          final accName = nameObj?.accountName ?? '계좌';
                          final institution = account.financialInstitution;
                          return DropdownMenuItem<String?>(
                            value: accId,
                            child: Text(
                              '$institution $accName',
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
                              selectedStockAccountFilterProvider.notifier,
                            )
                            .state = val;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 상단 요약 카드 (데스크톱 가로형 배치)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                if (isSingleOverseasAccount && appliedExchangeRate > 1.0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '적용 환율: ${appliedExchangeRate.toCommaString()}원/\$',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      JText(
                        '원화 환산: ${(grandTotalBalance * appliedExchangeRate).round().toWon()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Center(
                        child: SummaryItem(
                          label: '총 자산',
                          value: formatCurrency(grandTotalBalance),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SummaryItem(
                          label: '총 원금',
                          value: formatCurrency(totalPrincipal),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
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
                            isSingleOverseasAccount
                                ? JText(
                                  '${totalProfit > 0 ? '+' : ''}${totalProfit.toUSD()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: totalProfit > 0
                                        ? const Color(0xFFFF8A80)
                                        : totalProfit < 0
                                        ? const Color(0xFF82B1FF)
                                        : Colors.white,
                                  ),
                                )
                                : totalProfit.round().toSignedPriceText(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Center(
                        child: SummaryItem(
                          label: '현금성 잔액(예수금)',
                          value: formatCurrency(totalCashBalance),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SummaryItem(
                          label: '누적 배당금',
                          value: formatCurrency(totalPayout),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SummaryItem(
                          label: '누적 인출액',
                          value: formatCurrency(totalCumulativeWithdrawal),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      '전월 대비: ',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    isSingleOverseasAccount
                        ? JText(
                          '${summaryDiffFromLastMonth > 0 ? '+' : ''}${summaryDiffFromLastMonth.toUSD()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: summaryDiffFromLastMonth > 0
                                ? const Color(0xFFFF8A80)
                                : summaryDiffFromLastMonth < 0
                                ? const Color(0xFF82B1FF)
                                : Colors.white,
                          ),
                        )
                        : summaryDiffFromLastMonth
                            .round()
                            .toSignedPriceText(
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            '계좌별 현금 및 자금 요약',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          MonthlyStockAccountSummaryList(
            stockAccounts: stockAccounts,
            accountNameMap: accountNameMap,
            accountBalanceMap: accountBalanceMap,
            selectedAccountId: currentDropdownValue,
            targetMonth: activeCurrentMonth,
            onEditPressed: null,
          ),

          const SizedBox(height: 24),
          const Text(
            '보유 종목별 월말 내역',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (filteredStockItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  '$activeCurrentMonth에 등록된 주식 월말 데이터가 없습니다.',
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStockItems.length,
              itemBuilder: (context, index) {
                final balanceItem = filteredStockItems[index];

                final matchedAcc = accountMap[balanceItem.accountId];
                final institution =
                    matchedAcc?.financialInstitution ?? '기타 금융기관';
                final nameObj =
                    matchedAcc != null
                        ? accountNameMap[matchedAcc.accountNameId]
                        : null;
                final accountName = nameObj?.accountName ?? '주식계좌';
                final isOverseas = matchedAcc?.isForeignCurrency ?? false;

                final stock = stockItemMap[balanceItem.stockItemId];
                final stockName = stock?.itemName ?? '알 수 없는 종목';
                final stockCode = stock?.stockCode ?? '';
                final displayName =
                    stockCode.isNotEmpty
                        ? '$stockName ($stockCode)'
                        : stockName;

                final lastBalanceItem = lastItems.firstWhereOrNull(
                  (item) =>
                      item.accountId == balanceItem.accountId &&
                      item.stockItemId == balanceItem.stockItemId,
                );
                final lastBalance = lastBalanceItem?.balance ?? 0.0;
                final diffFromLastMonth = balanceItem.balance - lastBalance;

                String fmtItemMoney(double val) =>
                    isOverseas ? val.toUSD() : val.round().toWon();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '[$institution] $accountName',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (balanceItem.purchaseDate != null &&
                                  balanceItem.purchaseDate!.isNotEmpty)
                                Text(
                                  '매수일: ${balanceItem.purchaseDate}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.indigo.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              JText(
                                '평가액: ${fmtItemMoney(balanceItem.balance)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              JText(
                                '원금: ${fmtItemMoney(balanceItem.principal)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '총 손익',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              isOverseas
                                  ? JText(
                                    '${balanceItem.profitOrLoss > 0 ? '+' : ''}${balanceItem.profitOrLoss.toUSD()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: balanceItem.profitOrLoss >= 0
                                          ? Colors.red.shade700
                                          : Colors.blue.shade700,
                                    ),
                                  )
                                  : balanceItem.profitOrLoss
                                      .round()
                                      .toSignedPriceText(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              JText(
                                '수량: ${balanceItem.quantity.toCommaString()}주  |  현재가: ${fmtItemMoney(balanceItem.currentPrice)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              JText(
                                '평단가: ${fmtItemMoney(balanceItem.averagePurchasePrice)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                JText(
                                  '누적 배당: ${fmtItemMoney(balanceItem.totalPayout)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                JText(
                                  '누적 매도: ${fmtItemMoney(balanceItem.totalWithdrawal)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.teal.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 20, color: Colors.black12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '수익률: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  balanceItem.returnRate.toSignedPercentText(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    withParentheses: false,
                                  ),
                                  const SizedBox(width: 8),
                                  JText(
                                    '(연환산: ${balanceItem.annualizedReturnRate.toSignedPercent()})',
                                    style: TextStyle(
                                      fontSize: 13,
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
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  isOverseas
                                      ? JText(
                                        '${diffFromLastMonth > 0 ? '+' : ''}${diffFromLastMonth.toUSD()}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: diffFromLastMonth > 0
                                              ? Colors.red.shade700
                                              : diffFromLastMonth < 0
                                              ? Colors.blue.shade700
                                              : Colors.grey,
                                        ),
                                      )
                                      : diffFromLastMonth
                                          .round()
                                          .toSignedPriceText(
                                            style: const TextStyle(
                                              fontSize: 13,
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