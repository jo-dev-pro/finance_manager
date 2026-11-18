import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/responsive_extension.dart';
import '../../../../core/widgets/account_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/summary_card.dart';
import '../../../../providers/bank/bank_provider.dart';

class BuildBankData extends StatelessWidget {
  final List<BankAccountItem> rawItems;

  const BuildBankData({super.key, required this.rawItems});

  @override
  Widget build(BuildContext context) {
    final items = rawItems.where((item) {
      final type = item.account.accountType.toUpperCase();
      return type == '은행';
    }).toList();

    final double totalCurrentBalance = items.fold(
      0,
      (sum, i) => sum + i.currentBalance,
    );
    final double totalDiffFromLastMonth = items.fold(
      0,
      (sum, i) => sum + i.diffFromLastMonth,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCard(
            title: '은행 계좌 전체 금액',
            mainAmountText: totalCurrentBalance.toWon(),
            // 💡 어두운 카드 배경이므로 isDarkCard: true 적용하여 가인성 확보
            diffFromLastMonthWidget: totalDiffFromLastMonth.toSignedPriceText(
              isDarkCard: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SectionTitle('계좌 목록', topSpacing: 24, bottomSpacing: 12),
      
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('등록된 은행 계좌/자산 내역이 없습니다.'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 130,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _buildBankTile(items[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildBankTile(BankAccountItem item) {
    final account = item.account;
    final diff = item.diffFromLastMonth;
    final logoUrl = account.logoUrl;
    final institutionText = '${account.financialInstitution}${account.accountNumber != null && account.accountNumber!.isNotEmpty ? ' | ${account.accountNumber}' : ''}';

    return AccountCard(
      logoUrl: logoUrl,
      institution: institutionText,
      accountName: item.productName,
      totalBalance: item.currentBalance,
      diffFromLastMonth: diff,
    );
  }
}