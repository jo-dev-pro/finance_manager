import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // 화면 크기 구간 정의
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: '대시보드',
      ),
      NavigationDestination(
        icon: Icon(Icons.account_balance_wallet_outlined),
        selectedIcon: Icon(Icons.account_balance_wallet),
        label: '은행',
      ),
      NavigationDestination(
        icon: Icon(Icons.show_chart_outlined),
        selectedIcon: Icon(Icons.show_chart),
        label: '증권',
      ),
      NavigationDestination(
        icon: Icon(Icons.savings_outlined),
        selectedIcon: Icon(Icons.savings),
        label: '연금',
      ),
      NavigationDestination(
        icon: Icon(Icons.menu_outlined),
        selectedIcon: Icon(Icons.menu),
        label: '전체',
      ),
    ];

    // 1. 모바일 뷰 (< 600px)
    if (isMobile) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: destinations,
        ),
      );
    }

    // 2. 태블릿 및 데스크톱 뷰 (≥ 600px)
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: isTablet ? 110 : 130, // 태블릿에서 축소 시 최소 너비
            labelType: NavigationRailLabelType.all, // 데스크톱: extended 모드로 자동 처리
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            // 상단 헤더 (태블릿/데스크톱 구분)
            leading: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 8.0,
              ),
              child: isTablet
                  // 태블릿: 심플한 로고 아이콘만 표시
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    )
                  // 데스크톱: 로고 아이콘 + 텍스트 표시
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Theme.of(context).colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Finance Hub',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                      ],
                    ),
            ),

            // 스타일 설정
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 22,
            ),
            selectedLabelTextStyle: TextStyle(
              fontSize: isTablet ? 11 : 14, // 태블릿에서는 글자 크기 축소
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            unselectedLabelTextStyle: TextStyle(
              fontSize: isTablet ? 11 : 13,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),

            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
