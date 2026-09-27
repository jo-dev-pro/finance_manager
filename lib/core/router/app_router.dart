// app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/screens/account_screen.dart';
import '../../presentation/screens/all_menu_screen.dart';
import '../../presentation/screens/account_name_screen.dart';
import '../../presentation/screens/bank_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/investment_screen.dart';
import '../../presentation/screens/monthly_bank_balance_screen.dart';
import '../../presentation/screens/pension_product_screen.dart';
import '../../presentation/screens/pension_screen.dart';
import '../../presentation/screens/stock_item_screen.dart';
import '../../presentation/screens/stock_screen.dart';
import '../../presentation/screens/stock_transaction_type_screen.dart';
import '../../presentation/widgets/responsive_scaffold.dart';
import 'app_router_path.dart';

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
          // 탭 1: 대시보드
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // 탭 2: 은행
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.bank,
                builder: (context, state) => const BankScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePath.monthlyBankBalanceSub,
                    builder: (context, state) {
                      final selectedMonth = state.extra as String?;
                      return MonthlyBankBalanceScreen(initialYearMonth: selectedMonth);
                    },
                  ),
                ],
              ),
            ],
          ),

          // 탭 3: 증권
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.stock,
                builder: (context, state) => const StockScreen(),
              ),
            ],
          ),

          // 탭 4: 연금
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.pension,
                builder: (context, state) => const PensionScreen(),
              ),
            ],
          ),

          // 탭 5: 전체 메뉴
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.all,
                builder: (context, state) => const AllMenuScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePath.investmentSub,
                    builder: (context, state) => const InvestmentScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.accountSub,
                    builder: (context, state) => const AccountScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.accountNameSub,
                    builder: (context, state) => const AccountNameScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.stockItemSub,
                    builder: (context, state) => const StockItemScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.stockTransactionTypeSub,
                    builder: (context, state) => const StockTransactionTypeScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.pensionProductSub,
                    builder: (context, state) => const PensionProductScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}