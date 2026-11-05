import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../providers/bank/bank_provider.dart';
import '../../../../../providers/dashboard/dashboard_provider.dart';

/// 1. 상단 월 선택 헤더
Widget buildMonthSelectorHeader(
  BuildContext context,
  WidgetRef ref,
  List<String> months,
  String currentMonth,
) {
  final currentIndex = months.indexOf(currentMonth);

  return Container(
    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentIndex < months.length - 1
              ? () {
                  ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex + 1]);
                }
              : null,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: months.contains(currentMonth) ? currentMonth : months.first,
            icon: const Icon(Icons.arrow_drop_down),
            items: months.map((String month) {
              return DropdownMenuItem<String>(
                value: month,
                child: Text(
                  month,
                  style: const TextStyle(color: Colors.black87),
                ),
              );
            }).toList(),
            onChanged: (String? newMonth) {
              if (newMonth != null) {
                ref.read(selectedYearMonthProvider.notifier).select(newMonth);
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentIndex > 0
              ? () {
                  ref.read(selectedYearMonthProvider.notifier).select(months[currentIndex - 1]);
                }
              : null,
        ),
      ],
    ),
  );
}

/// 2. 은행 전체 자산 요약 카드
Widget buildTotalBankAssetCard(double totalCurrentBalance, double totalDiffFromLastMonth) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.indigo.shade600,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '은행 계좌 전체 금액',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          totalCurrentBalance.toWon(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '전월 대비',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            totalDiffFromLastMonth.toSignedPriceText(
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
  );
}

/// 3. 개별 은행 계좌 타일 카드
Widget buildBankTile(BankAccountItem item) {
  final account = item.account;
  final diff = item.diffFromLastMonth;

  return Card(
    elevation: 2,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 로고 아바타
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: account.logoUrl != null && account.logoUrl!.isNotEmpty
                ? NetworkImage(account.logoUrl!)
                : null,
            child: account.logoUrl == null || account.logoUrl!.isEmpty
                ? Icon(Icons.account_balance, color: Colors.blue.shade700)
                : null,
          ),
          const SizedBox(width: 12),

          // 텍스트 영역 (계좌명, 금융기관 | 계좌번호)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${account.financialInstitution}${account.accountNumber != null && account.accountNumber!.isNotEmpty ? ' | ${account.accountNumber}' : ''}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 금액 및 전월 대비 영역 (오른쪽 고정)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.currentBalance.toWon(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '전월대비 ',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  diff.toSignedPriceText(
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}