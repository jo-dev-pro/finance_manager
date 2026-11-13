import 'package:go_router/go_router.dart';

import '../../../presentation/screens/account/account_name_screen.dart';
import '../../../presentation/screens/account/account_screen.dart';
import '../../../presentation/screens/all_menu_screen.dart';
import '../../../presentation/screens/guide/asset_management_guide_screen.dart';
import '../../../presentation/screens/investment/investment_screen.dart';
import '../../../presentation/screens/pension/pension_holding_product_screen.dart';
import '../../../presentation/screens/pension/pension_product_screen.dart';
import '../../../presentation/screens/stock/stock_holding_item_screen.dart';
import '../../../presentation/screens/stock/stock_item_screen.dart';
import '../app_router_path.dart';

StatefulShellBranch buildAllMenuBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.all,
        builder: (context, state) => const AllMenuScreen(),
        routes: [
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.assetsGuide),
            builder: (context, state) => const AssetManagementGuideScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.investment),
            builder: (context, state) => const InvestmentScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.account),
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.accountName),
            builder: (context, state) => const AccountNameScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.stockItem),
            builder: (context, state) => const StockItemScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.stockHoldingItem),
            builder: (context, state) => const StockHoldingItemScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.pensionAccountProduct),
            builder: (context, state) => const PensionHoldingProductScreen(),
          ),
          GoRoute(
            path: AppRoutePath.sub(AppRoutePath.pensionProduct),
            builder: (context, state) => const PensionProductScreen(),
          ),
        ],
      ),
    ],
  );
}