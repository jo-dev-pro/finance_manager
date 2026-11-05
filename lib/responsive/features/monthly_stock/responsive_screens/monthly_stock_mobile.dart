import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class MonthlyStockMobileScreen extends ConsumerWidget {
  final String? initialYearMonth;

  const MonthlyStockMobileScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final targetMonth = selectedMonth ??
        initialYearMonth ??
        DateFormat('yyyy-MM').format(DateTime.now());

    final balancesAsync = ref.watch(monthlyStockBalanceNotifierProvider(targetMonth));
    final accountBalancesAsync = ref.watch(monthlyStockAccountBalanceNotifierProvider(targetMonth));
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('주식 월말 내역 관리 (조회 전용)')),
      body: balancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러오지 못했습니다: $err')),
        data: (items) {
          final accounts = accountsAsync.value ?? [];
          final accountNames = accountNamesAsync.value ?? [];
          final stockItems = stockItemsAsync.value ?? [];
          final accountBalances = accountBalancesAsync.value ?? [];

          final accountMap = {for (var a in accounts) a.id!: a};
          final accountNameMap = {for (var an in accountNames) an.id: an};
          final stockItemMap = {for (var s in stockItems) s.id!: s};
          final accountBalanceMap = {for (var ab in accountBalances) ab.accountId: ab};

          double totalStockBalance = 0;
          double totalPrincipal = 0;
          double totalCashBalance = 0;

          for (var b in items) {
            totalStockBalance += b.balance;
            totalPrincipal += b.principal;
          }
          for (var ab in accountBalances) {
            totalCashBalance += ab.cashBalance;
          }

          final grandTotalBalance = totalStockBalance + totalCashBalance;
          final totalProfit = grandTotalBalance - totalPrincipal;

          final stockAccounts = accounts
              .where((a) => a.accountType.trim() == '증권' && a.status == '활동')
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(monthlyStockBalanceNotifierProvider(targetMonth));
              ref.invalidate(monthlyStockAccountBalanceNotifierProvider(targetMonth));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.indigo.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('총 자산 (주식+현금)', grandTotalBalance.toWon()),
                          _buildSummaryItem('투자 원금', totalPrincipal.toWon()),
                          _buildSummaryItem(
                            '평가 손익',
                            '${totalProfit >= 0 ? '+' : ''}${totalProfit.toWon()}',
                            color: totalProfit >= 0 ? Colors.red.shade700 : Colors.blue.shade700,
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
                  if (stockAccounts.isEmpty)
                    const Text('등록된 증권 계좌가 없습니다.', style: TextStyle(color: Colors.grey))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stockAccounts.length,
                      itemBuilder: (context, index) {
                        final acc = stockAccounts[index];
                        final accId = acc.id ?? '';
                        final nameObj = accountNameMap[acc.accountNameId];
                        final accName = nameObj?.accountName ?? '계좌';
                        final institution = acc.financialInstitution;

                        final accBalanceData = accountBalanceMap[accId];
                        final cash = accBalanceData?.cashBalance ?? 0.0;
                        final monthlyWith = accBalanceData?.monthlyWithdrawal ?? 0.0;
                        final totalWith = accBalanceData?.totalWithdrawal ?? 0.0;

                        return Card(
                          elevation: 1.0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$institution - $accName',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '현금성 잔액: ${cash.toWon()} | 당월 인출: ${monthlyWith.toWon()} (누적: ${totalWith.toWon()})',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    '보유 종목별 월말 내역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('$targetMonth에 등록된 주식 종목 월말 데이터가 없습니다.')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final account = accountMap[item.accountId];
                        final accountName = account != null ? accountNameMap[account.accountNameId] : null;
                        final stock = stockItemMap[item.stockItemId];

                        final institution = account?.financialInstitution ?? '기타 증권사';
                        final accName = accountName?.accountName ?? '주식계좌';
                        final stockName = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stockName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '[$institution] $accName${stockCode.isNotEmpty ? ' • $stockCode' : ''}',
                                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 모바일에서는 수정/삭제 버튼 배제 (조회 전용)
                                  Text(
                                    item.balance.toWon(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildSummaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? Colors.black87),
        ),
      ],
    );
  }
}