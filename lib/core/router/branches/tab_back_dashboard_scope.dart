import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/onpop_invoked_provider.dart';
import '../app_router_path.dart';

class TabBackToDashboardScope extends ConsumerWidget {
  const TabBackToDashboardScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop(result);
          return;
        }

        final shell = StatefulNavigationShell.maybeOf(context);
        if (shell != null && shell.currentIndex != 0) {
          ref.read(jOnPopInvokedProvider.notifier).reset();
          shell.goBranch(0, initialLocation: true);
          return;
        }

        final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
        if (currentLocation != AppRoutePath.dashboard) {
          ref.read(jOnPopInvokedProvider.notifier).reset();
          context.go(AppRoutePath.dashboard);
          return;
        }

        await ref
            .read(jOnPopInvokedProvider.notifier)
            .handlePopInvoked(context);
      },
      child: child,
    );
  }
}