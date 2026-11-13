import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/responsive/responsive_scaffold.dart';
import '../../presentation/screens/bank/bank_screen.dart';
import '../../presentation/screens/bank/monthy_data/monthly_bank_balance_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/stock/monthly_data/monthly_stock_balance_screen.dart';
import '../../presentation/screens/stock/stock_screen.dart';
import 'app_router_path.dart';
import 'branches/pension_branch.dart';
import 'branches/all_menu_branch.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 1. 대시보드
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // 2. 은행
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.bank,
                builder: (context, state) => const BankScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePath.sub(AppRoutePath.monthlyBankBalance),
                    builder: (context, state) => MonthlyBankBalanceScreen(
                      initialYearMonth: state.extra as String?,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 3. 증권
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.stock,
                builder: (context, state) => const StockScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePath.sub(AppRoutePath.monthlyStockBalance),
                    builder: (context, state) => MonthlyStockBalanceScreen(
                      initialYearMonth: state.extra as String?,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 4. 연금 (별도 모듈)
          buildPensionBranch(),

          // 5. 전체 메뉴 (별도 모듈)
          buildAllMenuBranch(),
        ],
      ),
    ],
  );
}