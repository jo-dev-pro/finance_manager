// responsive_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    // initialLocation: true로 설정하여 탭 클릭 시 항상 최상위(대표) 화면으로 이동
    navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    // 공통 테마 색상 정의 (웹 NavigationRail과 완벽히 동일하게 일치)
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final indicatorBgColor = primaryColor.withValues(alpha: 0.2);

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

    if (isMobile) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBarTheme(
          // 모바일 NavigationBar의 색상 및 라벨 스타일을 웹(NavigationRail)과 일치시킴
          data: NavigationBarThemeData(
            indicatorColor: indicatorBgColor,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: primaryColor, size: 24);
              }
              return IconThemeData(
                color: unselectedColor.withValues(alpha: 0.7),
                size: 22,
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: unselectedColor,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: destinations,
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: isTablet ? 120 : 150,
            labelType: NavigationRailLabelType.all,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            indicatorColor: indicatorBgColor,
            leading: Image.asset(
              'assets/logos/finance.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
            selectedIconTheme: IconThemeData(
              color: primaryColor,
              size: 24,
            ),
            unselectedIconTheme: IconThemeData(
              color: unselectedColor.withValues(alpha: 0.7),
              size: 22,
            ),
            selectedLabelTextStyle: TextStyle(
              fontSize: isTablet ? 11 : 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            unselectedLabelTextStyle: TextStyle(
              fontSize: isTablet ? 11 : 13,
              fontWeight: FontWeight.normal,
              color: unselectedColor,
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