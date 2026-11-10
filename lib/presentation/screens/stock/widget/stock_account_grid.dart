import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/account_card.dart';
import '../../../../models/account/account.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';

class StockAccountGrid extends StatelessWidget {
  final List<String> accountIds;
  final Map<String, List<MonthlyStockBalance>> accountGroups;
  final Map<String, double> accountExchangeRateMap;
  final Map<String, double> accountCashMap;
  final List<Account> accounts;
  final List<dynamic> accountNames;
  final Map<String, String> stockMap;

  const StockAccountGrid({
    super.key,
    required this.accountIds,
    required this.accountGroups,
    required this.accountExchangeRateMap,
    required this.accountCashMap,
    required this.accounts,
    required this.accountNames,
    required this.stockMap,
  });

  @override
  Widget build(BuildContext context) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 170,
      ),
      itemCount: accountIds.length,
      itemBuilder: (context, index) {
        final accountId = accountIds[index];
        final items = accountGroups[accountId]!;

        final exchangeRate = accountExchangeRateMap[accountId] ?? 1.0;
        
        // 💡 계좌별 현금성 잔액(예수금) 환율 적용 및 반올림
        final cashBalance = ((accountCashMap[accountId] ?? 0.0) * exchangeRate).roundToDouble();

        final rawBalance = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final rawPrincipal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.principal,
        );
        final rawPayout = items.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPayout,
        );
        final rawWithdrawal = items.fold<double>(
          0.0,
          (sum, item) => sum + item.totalWithdrawal,
        );

        // 💡 총 평가액, 원금, 배당, 인출액에 환율 적용 및 정수형 반올림(.roundToDouble()) 처리
        final totalBalance = ((rawBalance * exchangeRate) + cashBalance).roundToDouble();
        final totalPrincipal = ((rawPrincipal * exchangeRate) + cashBalance).roundToDouble();
        final totalPayout = (rawPayout * exchangeRate).roundToDouble();
        final totalWithdrawal = (rawWithdrawal * exchangeRate).roundToDouble();

        final totalProfitOrLoss =
            (totalBalance + totalPayout + totalWithdrawal) - totalPrincipal;
        final returnRate =
            totalPrincipal > 0
                ? (totalProfitOrLoss / totalPrincipal) * 100
                : 0.0;

        final matchedAcc = accountMap[accountId];
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
          totalBalance: totalBalance,
          totalPrincipal: totalPrincipal,
          totalProfitOrLoss: totalProfitOrLoss,
          returnRate: returnRate,
          totalWithdrawal: totalWithdrawal,
          itemCount: items.length,
          onTap: () {
            _showStockDetailBottomSheet(
              context,
              institution: institution,
              accountName: accountName,
              items: items,
              cashBalance: cashBalance,
              exchangeRate: exchangeRate,
              stockMap: stockMap,
            );
          },
        );
      },
    );
  }

  void _showStockDetailBottomSheet(
    BuildContext context, {
    required String institution,
    required String accountName,
    required List<MonthlyStockBalance> items,
    required double cashBalance,
    required double exchangeRate,
    required Map<String, String> stockMap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          height: screenHeight * 0.85,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '[$institution] $accountName 보유 종목',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    if (cashBalance > 0)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE0F2F1),
                          child: Icon(Icons.attach_money, color: Colors.teal),
                        ),
                        title: const Text(
                          '계좌 공통 현금성 자산 (예수금)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '잔액: ${cashBalance.round().toWon()}',
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ...items.map((item) {
                      final stockName = stockMap[item.stockItemId] ?? '주식 종목';
                      // 💡 바텀 시트 종목별 평가액 및 원금도 정수형 반올림 처리
                      final itemBalance = (item.balance * exchangeRate).roundToDouble();
                      final itemPrincipal = (item.principal * exchangeRate).roundToDouble();
                      final itemCurrentPrice = (item.currentPrice * exchangeRate).roundToDouble();

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        title: Text(
                          stockName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '평가액: ${itemBalance.round().toWon()}   |   원금: ${itemPrincipal.round().toWon()}\n수량: ${item.quantity.toCommaString()}주   |   단가: ${itemCurrentPrice.round().toWon()}\n수익률: ${item.returnRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}