import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/onpop_invoked_provider.dart';
import '../../../core/router/app_router_path.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';

class AllMenuScreen extends ConsumerWidget {
  const AllMenuScreen({super.key});

  void _backToDashboard(BuildContext context, WidgetRef ref) {
    ref.read(jOnPopInvokedProvider.notifier).reset();
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      shell.goBranch(0, initialLocation: true);
    } else {
      context.go(AppRoutePath.dashboard);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop(result);
          return;
        }

        _backToDashboard(context, ref);
      },
      child: Scaffold(
        appBar: const MainAppBar(titleText: '전체 메뉴'),
        body: MainConstrainedBox(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MenuSectionCard(
                  sectionTitle: '가이드 & 자금',
                  items: [
                    _MenuItemData(
                      icon: Icons.help_outline,
                      iconColor: Colors.indigo,
                      title: '자산 관리 가이드',
                      subtitle: '앱 사용법 및 자산 관리 기준 안내',
                      onTap: () => context.push(AppRoutePath.assetsGuide),
                    ),
                    _MenuItemData(
                      icon: Icons.monetization_on_outlined,
                      iconColor: Colors.indigo,
                      title: '투자금 관리',
                      subtitle: '투자 원금 및 자금 내역 관리',
                      onTap: () => context.push(AppRoutePath.investment),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _MenuSectionCard(
                  sectionTitle: '계좌 설정',
                  items: [
                    _MenuItemData(
                      icon: Icons.account_balance_outlined,
                      iconColor: Colors.blue.shade700,
                      title: '계좌 관리',
                      subtitle: '은행·증권·연금 계좌 등록 및 상태 관리',
                      onTap: () => context.push(AppRoutePath.account),
                    ),
                    _MenuItemData(
                      icon: Icons.badge_outlined,
                      iconColor: Colors.blue.shade700,
                      title: '계좌명 관리',
                      subtitle: '계좌 별칭 및 구분 명칭 관리',
                      onTap: () => context.push(AppRoutePath.accountName),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _MenuSectionCard(
                  sectionTitle: '주식 관리',
                  items: [
                    _MenuItemData(
                      icon: Icons.show_chart,
                      iconColor: Colors.orange.shade700,
                      title: '주식 종목명 관리',
                      subtitle: '종목코드 및 종목명 마스터 관리',
                      onTap: () => context.push(AppRoutePath.stockItem),
                    ),
                    _MenuItemData(
                      icon: Icons.pie_chart_outline,
                      iconColor: Colors.orange.shade700,
                      title: '주식 계좌별 보유종목 관리',
                      subtitle: '계좌에 편입된 보유 종목 설정',
                      onTap: () => context.push(AppRoutePath.stockHoldingItem),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _MenuSectionCard(
                  sectionTitle: '연금 관리',
                  items: [
                    _MenuItemData(
                      icon: Icons.savings_outlined,
                      iconColor: Colors.green.shade700,
                      title: '연금 상품명 관리',
                      subtitle: '연금 펀드·상품 마스터 관리',
                      onTap: () => context.push(AppRoutePath.pensionProduct),
                    ),
                    _MenuItemData(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: Colors.green.shade700,
                      title: '연금 계좌별 보유상품 관리',
                      subtitle: '연금 계좌에 보유 중인 상품 설정',
                      onTap:
                          () =>
                              context.push(AppRoutePath.pensionAccountProduct),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _MenuSectionCard extends StatelessWidget {
  final String sectionTitle;
  final List<_MenuItemData> items;

  const _MenuSectionCard({required this.sectionTitle, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 16,
                    color: Colors.grey.shade200,
                  ),
                _MenuTile(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItemData item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: item.iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.iconColor, size: 20),
      ),
      title: Text(
        item.title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        item.subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: item.onTap,
    );
  }
}
