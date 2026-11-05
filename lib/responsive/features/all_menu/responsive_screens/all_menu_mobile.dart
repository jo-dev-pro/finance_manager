// lib/responsive/features/all_menu/responsive_screens/all_menu_mobile.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router_path.dart';

class AllMenuMobileScreen extends StatelessWidget {
  const AllMenuMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전체 메뉴')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 1. 가이드 섹션
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.indigo),
              title: const Text('자산 관리 가이드'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutePath.assetsGuide),
            ),
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

            const Divider(height: 32),

            // 2. 주요 조회/관리 메뉴 섹션 (모바일 조회 전용 원칙 준수)
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

            // 💡 참고: (Batch) 업로드 및 마이그레이션 기능들은 
            // 데이터 무결성을 위해 데스크톱 전용 메뉴로 남겨두었습니다.
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}