// all_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/migrate/firestore_db_migrate.dart';
import '../../core/router/app_router_path.dart';
import '../../core/widgets/main_constrainedbox.dart';

class AllMenuScreen extends StatelessWidget {
  const AllMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 메뉴')),
      body: MainConstrainedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 32),
        
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.indigo),
                title: const Text('자산 관리 가이드'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutePath.assetsGuide),
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
                title: const Text('주식 계좌별 보유종목 관리'),
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
                title: const Text('연금 계좌별 보유상품 관리'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutePath.pensionAccountProduct),
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
      ),
    );
  }
}
