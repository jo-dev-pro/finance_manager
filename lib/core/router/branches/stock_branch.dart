import 'package:go_router/go_router.dart';

import '../../../presentation/screens/bank/bank_screen.dart';
import '../../../presentation/screens/bank/monthy_data/monthly_bank_balance_screen.dart';
import '../app_router_path.dart';

StatefulShellBranch buildBankBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.bank,
        builder: (context, state) => const BankScreen(),
        routes: [
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.monthlyBankBalance),
            builder:
                (context, state) => MonthlyBankBalanceScreen(
                  initialYearMonth: state.extra as String?,
                ),
          ),
        ],
      ),
    ],
  );
}
