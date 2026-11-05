// lib/presentation/responsive/screens/mobile_scaffold_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileScaffoldLayout extends StatelessWidget {
  const MobileScaffoldLayout({super.key, required this.navigationShell});

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
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: indicatorBgColor,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: primaryColor, size: 24);
            }
            return IconThemeData(color: unselectedColor.withValues(alpha: 0.7), size: 22);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor);
            }
            return TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: unselectedColor);
          }),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: '대시보드'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: '은행'),
            NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: '증권'),
            NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: '연금'),
            NavigationDestination(icon: Icon(Icons.menu_outlined), selectedIcon: Icon(Icons.menu), label: '전체'),
          ],
        ),
      ),
    );
  }
}