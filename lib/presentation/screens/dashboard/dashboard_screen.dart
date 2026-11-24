import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/onpop_invoked_provider.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import 'widgets/build_dashboard_data.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<String>>>(availableYearMonthsProvider, (
      previous,
      next,
    ) {
      next.whenData((months) {
        if (months.isNotEmpty) {
          final selectedMonth = ref.read(selectedYearMonthProvider);
          if (selectedMonth == null || !months.contains(selectedMonth)) {
            ref.read(selectedYearMonthProvider.notifier).select(months.first);
          }
        }
      });
    });

    final monthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop(result);
          return;
        }

        await ref
            .read(jOnPopInvokedProvider.notifier)
            .handlePopInvoked(context);
      },
      child: Scaffold(
        appBar: MainAppBar(titleText: '대시보드'),
        body: monthsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (err, stack) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
          data: (months) {
            if (months.isEmpty) {
              return const Center(child: Text('등록된 자산/기준월 데이터가 없습니다.'));
            }

            final String activeCurrentMonth =
                (selectedMonth != null && months.contains(selectedMonth))
                    ? selectedMonth
                    : months.first;

            if (selectedMonth == null || !months.contains(selectedMonth)) {
              Future.microtask(() {
                ref
                    .read(selectedYearMonthProvider.notifier)
                    .select(activeCurrentMonth);
              });
            }

            final summary = summaryAsync.value;

            return MainConstrainedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthSelectorHeader(
                    months: months,
                    currentMonth: activeCurrentMonth,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        summary == null
                            ? const Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : BuildDashboardData(summary: summary),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
