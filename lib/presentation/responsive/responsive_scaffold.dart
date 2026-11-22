import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/onpop_invoked_provider.dart';
import '../../core/utils/responsive_extension.dart';

class ResponsiveScaffold extends ConsumerStatefulWidget {
  const ResponsiveScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends ConsumerState<ResponsiveScaffold> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(jOnPopInvokedProvider);
    final indicatorBgColor = context.primaryColor.withValues(alpha: 0.2);

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

    if (context.isMobile) {
      scaffoldContent = Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: context.backgroundColor,
            indicatorColor: indicatorBgColor,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: context.primaryColor, size: 24);
              }
              return IconThemeData(
                color: context.unselectedColor.withValues(alpha: 0.7),
                size: 22,
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: context.unselectedColor,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
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
              backgroundColor: context.backgroundColor,
              minWidth: context.isMobile ? 120 : 150,
              labelType: NavigationRailLabelType.all,
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              indicatorColor: indicatorBgColor,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 120,
                  height: 120,
                  color: context.backgroundColor,
                  child: Image.asset(
                    'assets/logos/finance.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              selectedIconTheme: IconThemeData(
                color: context.primaryColor,
                size: 24,
              ),
              unselectedIconTheme: IconThemeData(
                color: context.unselectedColor.withValues(alpha: 0.7),
                size: 22,
              ),
              selectedLabelTextStyle: TextStyle(
                fontSize: context.isMobile ? 11 : 14,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontSize: context.isMobile ? 11 : 13,
                fontWeight: FontWeight.normal,
                color: context.unselectedColor,
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
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop(result);
          return;
        }

        await ref
            .read(jOnPopInvokedProvider.notifier)
            .handlePopInvoked(context);
      },
      child: scaffoldContent,
    );
  }
}