// lib/presentation/responsive/screens/desktop_scaffold_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopScaffoldLayout extends StatelessWidget {
  const DesktopScaffoldLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final indicatorBgColor = primaryColor.withValues(alpha: 0.2);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: 150,
            labelType: NavigationRailLabelType.all,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            indicatorColor: indicatorBgColor,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Image.asset('assets/logos/finance.png', width: 100, height: 100, fit: BoxFit.cover),
            ),
            selectedIconTheme: IconThemeData(color: primaryColor, size: 24),
            unselectedIconTheme: IconThemeData(color: unselectedColor.withValues(alpha: 0.7), size: 22),
            selectedLabelTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
            unselectedLabelTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: unselectedColor),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('대시보드')),
              NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('은행')),
              NavigationRailDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: Text('증권')),
              NavigationRailDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: Text('연금')),
              NavigationRailDestination(icon: Icon(Icons.menu_outlined), selectedIcon: Icon(Icons.menu), label: Text('전체')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}