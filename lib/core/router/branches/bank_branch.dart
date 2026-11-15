import 'package:go_router/go_router.dart';

import '../../../presentation/screens/stock/stock_screen.dart';
import '../../../presentation/screens/stock/monthly_data/monthly_stock_balance_screen.dart';
import '../../../presentation/screens/stock/summary/monthly_stock_summary_screen.dart';
import '../app_router_path.dart';

StatefulShellBranch buildStockBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.stock,
        builder: (context, state) => const StockScreen(),
        routes: [
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.monthlyStockSummary),
            builder: (context, state) => MonthlyStockSummaryScreen(
              extra: state.extra,
            ),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.monthlyStockBalance),
            builder: (context, state) => MonthlyStockBalanceScreen(
              initialYearMonth: state.extra as String?,
            ),
          ),
        ],
      ),
    ],
  );
}