// lib/responsive/features/account_name/account_name_screen.dart
import 'package:flutter/material.dart';

import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/account_name_desktop.dart';
import 'responsive_screens/account_name_mobile.dart';

class AccountNameScreen extends StatelessWidget {
  const AccountNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonResponsiveLayout(
      desktopScreen: AccountNameDesktopScreen(),
      mobileScreen: AccountNameMobileScreen(),
    );
  }
}