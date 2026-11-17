import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/responsive/responsive_scaffold.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import 'app_router_path.dart';
import 'branches/stock_branch.dart';
import 'branches/pension_branch.dart';
import 'branches/all_menu_branch.dart';
import 'branches/bank_branch.dart';

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

          // 2. 은행 (별도 모듈)
          buildBankBranch(),

          // 3. 증권 (별도 모듈)
          buildStockBranch(),

          // 4. 연금 (별도 모듈)
          buildPensionBranch(),

          // 5. 전체 메뉴 (별도 모듈)
          buildAllMenuBranch(),
        ],
      ),
    ],
  );
}