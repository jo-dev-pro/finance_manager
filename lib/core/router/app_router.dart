import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/screens/bank_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/all_menu_screen.dart';
import '../../presentation/screens/pension_screen.dart';
import '../../presentation/screens/stock_screen.dart';
import '../../presentation/widgets/responsive_scaffold.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 탭 1: 대시보드
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
     
          // 탭 2: 은행 / 월말 잔액
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bank',
                builder: (context, state) => const BankScreen(),
              ),
            ],
          ),
          // 탭 3: 증권 / 월말 거래 내역
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stock',
                builder: (context, state) => const StockScreen(),
              ),
            ],
          ),
          // 탭 4: 연금 / 월말 거래 내역
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pension',
                builder: (context, state) => const PensionScreen(),
              ),
            ],
          ),
          // 탭 5: 전체 
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/all',
                builder: (context, state) => const AllMenuScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}