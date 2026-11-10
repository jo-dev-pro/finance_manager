import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/account_card.dart';
import '../../../../models/account/account.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';

class PensionAccountGrid extends StatelessWidget {
  final List<String> accountIds;
  final Map<String, List<MonthlyPensionBalance>> accountGroups;
  final Map<String, double> accountCashMap;
  final Map<String, double> accountWithdrawalMap;
  final Map<String, List<MonthlyPensionBalance>> lastAccountGroups;
  final Map<String, double> lastAccountCashMap;
  final List<Account> accounts;
  final List<dynamic> accountNames;
  final List<dynamic> products;

  // static const String kCashAssetProductId = '_CASH_ASSET_PRODUCT_ID_';

  const PensionAccountGrid({
    super.key,
    required this.accountIds,
    required this.accountGroups,
    required this.accountCashMap,
    required this.accountWithdrawalMap,
    required this.lastAccountGroups,
    required this.lastAccountCashMap,
    required this.accounts,
    required this.accountNames,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final accountMap = {for (var a in accounts) a.id!: a};

    final Map<String, String> productMap = {
      for (var p in products) p.id.toString(): p.productName.toString(),
    };

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
        final items = accountGroups[accountId] ?? [];
        final lastItems = lastAccountGroups[accountId] ?? [];

        final productSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final productPrincipalSum = items.fold<double>(
          0.0,
          (sum, item) => sum + item.principal,
        );

        final accountWithdrawal = accountWithdrawalMap[accountId] ?? 0.0;
        final cashBalance = accountCashMap[accountId] ?? 0.0;

        final totalAccountBalance = productSum + cashBalance;
        final totalAccountPrincipal = productPrincipalSum + cashBalance;

        final totalProfitOrLoss =
            (totalAccountBalance + accountWithdrawal) - totalAccountPrincipal;

        final returnRate =
            totalAccountPrincipal > 0
                ? (totalProfitOrLoss / totalAccountPrincipal) * 100
                : 0.0;

        final lastProductSum = lastItems.fold<double>(
          0.0,
          (sum, item) => sum + item.balance,
        );
        final lastCashBalance = lastAccountCashMap[accountId] ?? 0.0;
        final lastTotalAccountBalance = lastProductSum + lastCashBalance;
        final diffFromLastMonth = totalAccountBalance - lastTotalAccountBalance;

        final matchedAcc = accountMap[accountId];
        final matchedAccountName =
            matchedAcc != null
                ? accountNameMap[matchedAcc.accountNameId]
                : null;
        final accountName = matchedAccountName?.accountName ?? accountId;

        return AccountCard(
          logoUrl: matchedAcc?.logoUrl,
          institution: '',
          accountName: accountName,
          totalBalance: totalAccountBalance,
          totalPrincipal: totalAccountPrincipal,
          totalProfitOrLoss: totalProfitOrLoss,
          returnRate: returnRate,
          totalWithdrawal: accountWithdrawal,
          diffFromLastMonth: diffFromLastMonth,
          itemCount: items.length,
          onTap: () {
            _showProductDetailBottomSheet(
              context,
              account: matchedAcc,
              accountName: accountName,
              products: items,
              cashBalance: cashBalance,
              productMap: productMap,
            );
          },
        );
      },
    );
  }

  void _showProductDetailBottomSheet(
    BuildContext context, {
    required Account? account,
    required String accountName,
    required List<MonthlyPensionBalance> products,
    required double cashBalance,
    required Map<String, String> productMap,
  }) {
    final logoUrl = account?.logoUrl;

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
                    child: Row(
                      children: [
                        if (logoUrl != null && logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              logoUrl,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.account_balance,
                                    size: 22,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.account_balance,
                            size: 22,
                            color: Colors.indigo,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$accountName 보유 자산 상세',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                          '현금성 자산',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '잔액: ${cashBalance.toWon()}',
                          style: TextStyle(
                            color: Colors.teal.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ...products.map((item) {
                      final productName = (productMap[item.productId] ?? '연금 상품');

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        title: Text(
                          productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '평가액: ${item.balance.toWon()}   |   원금: ${item.principal.toWon()}\n수익률: ${item.returnRate.toStringAsFixed(1)}%   (연환산: ${item.annualizedReturnRate.toStringAsFixed(1)}%)',
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