import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/monthly_stock_desktop.dart';
import 'responsive_screens/monthly_stock_mobile.dart';

class MonthlyStockBalanceScreen extends StatelessWidget {
  final String? initialYearMonth;

  const MonthlyStockBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context) {
    return CommonResponsiveLayout(
      desktopScreen: MonthlyStockDesktopScreen(initialYearMonth: initialYearMonth),
      mobileScreen: MonthlyStockMobileScreen(initialYearMonth: initialYearMonth),
    );
  }
}