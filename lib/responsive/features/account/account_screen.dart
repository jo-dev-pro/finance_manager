import 'package:flutter/material.dart';
import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/account_desktop.dart';
import 'responsive_screens/account_mobile.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: AccountDesktopScreen(),
      mobileScreen: AccountMobileScreen(),
    );
  }
}