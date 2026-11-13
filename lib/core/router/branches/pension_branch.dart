import 'package:go_router/go_router.dart';

import '../../../presentation/screens/pension/monthly_data/monthly_pension_balance_screen.dart';
import '../../../presentation/screens/pension/pension_screen.dart';
import '../../../presentation/screens/pension/summary/monthly_pension_summary_screen.dart';
import '../app_router_path.dart';

StatefulShellBranch buildPensionBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.pension,
        builder: (context, state) => const PensionScreen(),
        routes: [
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.monthlyPensionSummary),
            builder: (context, state) => MonthlyPensionSummaryScreen(
              extra: state.extra,
            ),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.monthlyPensionBalance),
            builder: (context, state) => MonthlyPensionBalanceScreen(
              initialYearMonth: state.extra as String?,
            ),
          ),
        ],
      ),
    ],
  );
}