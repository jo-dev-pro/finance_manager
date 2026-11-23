import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/onpop_invoked_provider.dart';
import '../../presentation/responsive/responsive_scaffold.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import 'app_router_path.dart';
import 'branches/stock_branch.dart';
import 'branches/pension_branch.dart';
import 'branches/all_menu_branch.dart';
import 'branches/bank_branch.dart';

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
          return Consumer(
            builder: (context, consumerRef, _) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  debugPrint(
                    '[Shell PopScope] didPop=$didPop | canPop=${context.canPop()}',
                  );
                  if (didPop) return;

                  if (context.canPop()) {
                    context.pop(result);
                    return;
                  }

                  await consumerRef
                      .read(jOnPopInvokedProvider.notifier)
                      .handlePopInvoked(context);
                },
                child: ResponsiveScaffold(navigationShell: navigationShell),
              );
            },
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          buildBankBranch(),
          buildStockBranch(),
          buildPensionBranch(),
          buildAllMenuBranch(),
        ],
      ),
    ],
  );
}