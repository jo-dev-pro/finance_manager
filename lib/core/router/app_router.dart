// app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/screens/account/account_screen.dart';
import '../../presentation/screens/all_menu_screen.dart';
import '../../presentation/screens/account/account_name_screen.dart';
import '../../presentation/screens/bank/bank_screen.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/guide/pension_guide.dart';
import '../../presentation/screens/guide/stock_guide.dart';
import '../../presentation/screens/investment/investment_screen.dart';
import '../../presentation/screens/monthly_data/monthly_bank_balance_screen.dart';
import '../../presentation/screens/monthly_data/monthly_pension_balance_screen.dart';
import '../../presentation/screens/monthly_data/monthly_stock_balance_screen.dart';
import '../../presentation/screens/pension/pension_holding_product_screen.dart';
import '../../presentation/screens/pension/pension_product_screen.dart';
import '../../presentation/screens/pension/pension_screen.dart';
import '../../presentation/screens/stock/stock_holding_item_screen.dart';
import '../../presentation/screens/stock/stock_item_screen.dart';
import '../../presentation/screens/stock/stock_screen.dart';
import '../../presentation/responsive/responsive_scaffold.dart';
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
                      return MonthlyBankBalanceScreen(
                        initialYearMonth: selectedMonth,
                      );
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
                routes: [
                  GoRoute(
                    path: AppRoutePath.monthlyStockBalanceSub,
                    builder: (context, state) {
                      final selectedMonth = state.extra as String?;
                      return MonthlyStockBalanceScreen(
                        initialYearMonth: selectedMonth,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // 탭 4: 연금
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.pension,
                builder: (context, state) => const PensionScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutePath.monthlyPensionBalanceSub,
                    builder: (context, state) {
                      final selectedMonth = state.extra as String?;
                      return MonthlyPensionBalanceScreen(
                        initialYearMonth: selectedMonth,
                      );
                    },
                  ),
                ],
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
                    path: AppRoutePath.pensionGuideSub,
                    builder: (context, state) => const PensionGuideScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.stockGuideSub,
                    builder: (context, state) => const StockGuideScreen(),
                  ),
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
                    path: AppRoutePath.stockHoldingItemSub,
                    builder: (context, state) => const StockHoldingItemScreen(),
                  ),
                  GoRoute(
                    path: AppRoutePath.pensionAccountProductSub,
                    builder:
                        (context, state) => const PensionHoldingProductScreen(),
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
