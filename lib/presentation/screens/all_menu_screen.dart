// all_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/raw_upload/bank_monthly_upload.dart';
import '../../core/raw_upload/pension_monthly_upload.dart';
import '../../core/migrate/firestore_db_migrate.dart';
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
              leading: const Icon(Icons.help_outline, color: Colors.indigo),
              title: const Text('연금 자산 관리 가이드'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.pensionGuide),
            ),

            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.indigo),
              title: const Text('주식 자산 관리 가이드'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.stockGuide),
            ),

            ListTile(
              leading: const Icon(
                Icons.monetization_on_outlined,
                color: Colors.indigo,
              ),
              title: const Text('투자금 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.investment),
            ),

            ListTile(
              leading: const Icon(
                Icons.account_balance_outlined,
                color: Colors.indigo,
              ),
              title: const Text('계좌 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.account),
            ),

            ListTile(
              leading: const Icon(
                Icons.account_balance_outlined,
                color: Colors.indigo,
              ),
              title: const Text('계좌명 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.accountName),
            ),

            ListTile(
              leading: const Icon(
                Icons.show_chart_outlined,
                color: Colors.indigo,
              ),
              title: const Text('주식 종목명 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.stockItem),
            ),

            ListTile(
              leading: const Icon(
                Icons.show_chart_outlined,
                color: Colors.indigo,
              ),
              title: const Text('주식 보유종목 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.stockHoldingItem),
            ),

            // ListTile(
            //   leading: const Icon(
            //     Icons.swap_horiz_outlined,
            //     color: Colors.indigo,
            //   ),
            //   title: const Text('주식 거래구분 관리'),
            //   trailing: const Icon(Icons.chevron_right),
            //   onTap: () => context.push(AppRoutePath.stockTransactionType),
            // ),
            ListTile(
              leading: const Icon(Icons.savings_outlined, color: Colors.indigo),
              title: const Text('연금 상품명 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.pensionProduct),
            ),

            ListTile(
              leading: const Icon(Icons.savings_outlined, color: Colors.indigo),
              title: const Text('연금 계좌별 상품 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.pensionAccountProduct),
            ),

            ListTile(
              leading: const Icon(Icons.savings_outlined, color: Colors.indigo),
              title: const Text('(Batch)은행 월말자료 업로드'),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BankMonthlyUploadScreen(),
                    ),
                  ),
            ),

            ListTile(
              leading: const Icon(Icons.savings_outlined, color: Colors.indigo),
              title: const Text('(Batch)연금 월말자료 업로드'),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PensionMonthlyUploadScreen(),
                    ),
                  ),
            ),

            ListTile(
              leading: const Icon(Icons.savings_outlined, color: Colors.indigo),
              title: const Text('Firestore DB 마이그레이션'),
              trailing: const Icon(Icons.chevron_right),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FirestoreDBMigrateScreen(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
