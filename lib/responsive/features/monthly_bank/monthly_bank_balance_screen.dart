import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/monthly_bank_desktop.dart';
import 'responsive_screens/monthly_bank_mobile.dart';

class MonthlyBankBalanceScreen extends StatelessWidget {
  final String? initialYearMonth;

  const MonthlyBankBalanceScreen({super.key, this.initialYearMonth});

  @override
  Widget build(BuildContext context) {
    return CommonResponsiveLayout(
      desktopScreen: MonthlyBankDesktopScreen(initialYearMonth: initialYearMonth),
      mobileScreen: MonthlyBankMobileScreen(initialYearMonth: initialYearMonth),
    );
  }
}