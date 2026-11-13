// responsive_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/onpop_invoked_provider.dart';

class ResponsiveScaffold extends ConsumerWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    if (navigationShell.currentIndex == index) {
      // 💡 만약 이미 현재 머물고 있는 탭을 다시 누른 경우,
      // 해당 탭의 스택을 완전히 비우고 최상위(initialLocation)로 강제 이동시킵니다.
      navigationShell.goBranch(index, initialLocation: true);

      // 만약 GoRouter 버전이나 설정에 따라 스택 내부의 서브 라우트까지
      // 확실하게 pop 시키고 싶다면 아래처럼 라우터를 직접 활용할 수도 있습니다.
      // context.go(AppRoutePath.getByIndex(index)); // 각 탭의 경로에 맞게 처리
    } else {
      // 다른 탭으로 이동할 때
      navigationShell.goBranch(index, initialLocation: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

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

    Widget scaffoldContent;

    if (isMobile) {
      scaffoldContent = Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBarTheme(
          // 모바일 NavigationBar의 색상 및 라벨 스타일을 웹(NavigationRail)과 일치시킴
          data: NavigationBarThemeData(
            backgroundColor: const Color(0xFFFAFAFA),
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
    } else {
      scaffoldContent = Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: const Color(0xFFFAFAFA),
              minWidth: isTablet ? 120 : 150,
              labelType: NavigationRailLabelType.all,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              indicatorColor: indicatorBgColor,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8), // 원하는 둥글기 정도
                child: Container(
                  width: 120,
                  height: 120,
                  color: const Color(0xFFFAFAFA), // 배경색
                  child: Image.asset(
                    'assets/logos/finance.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              selectedIconTheme: IconThemeData(color: primaryColor, size: 24),
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
              destinations:
                  destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1, color: Colors.grey),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // 2. 최상위 루트 셸에 PopScope를 적용하여 앱 전체 탭에서 공통으로 종료 체크 수행
    return PopScope(
      canPop: false, // 항상 false로 고정하여 시스템 기본 뒤로가기 동작을 차단
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(jOnPopInvokedProvider.notifier).handlePopInvoked(context);
      },
      child: scaffoldContent,
    );
  }
}
