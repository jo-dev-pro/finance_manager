import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/monthly_pension_desktop.dart';
import 'responsive_screens/monthly_pension_mobile.dart';

class MonthlyPensionBalanceScreen extends StatelessWidget {
  final String? initialYearMonth;

  const MonthlyPensionBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context) {
    return CommonResponsiveLayout(
      desktopScreen: MonthlyPensionDesktopScreen(initialYearMonth: initialYearMonth),
      mobileScreen: MonthlyPensionMobileScreen(initialYearMonth: initialYearMonth),
    );
  }
}