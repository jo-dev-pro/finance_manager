// all_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/bank_manthly_upload.dart';
import '../../core/router/app_router_path.dart';

class AllMenuScreen extends StatelessWidget {
  const AllMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 메뉴')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.monetization_on_outlined),
              title: const Text('투자금 관리'),
              onTap: () => context.push(AppRoutePath.investment),
            ),

            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('계좌 관리'),
              onTap: () => context.push(AppRoutePath.account),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('계좌명 관리'),
              onTap: () => context.push(AppRoutePath.accountName),
            ),

            ListTile(
              leading: const Icon(Icons.show_chart_outlined),
              title: const Text('주식 종목명 관리'),
              onTap: () => context.push(AppRoutePath.stockItem),
            ),

            ListTile(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: const Text('주식 거래구분 관리'),
              onTap: () => context.push(AppRoutePath.stockTransactionType),
            ),
            ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: const Text('연금 상품명 관리'),
              onTap: () => context.push(AppRoutePath.pensionProduct),
            ),
                        ListTile(
              leading: const Icon(Icons.swap_horiz_outlined),
              title: const Text('연금 거래구분 관리'),
              onTap: () => context.push(AppRoutePath.pensionTransactionType),
            ),
            ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: const Text('(Batch)은행 월말자료 업로드'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankMonthlyUploadScreen(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
