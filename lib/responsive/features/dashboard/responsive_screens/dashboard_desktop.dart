// lib/responsive/features/dashboard/responsive_screens/dashboard_desktop.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../scaffold/widgets/common_desktop_container.dart';
import 'widgets/dashboard_common_widgets.dart';

class DashboardDesktopScreen extends ConsumerWidget {
  const DashboardDesktopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return monthsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('오류 발생: $e')),
      data: (months) {
        final activeCurrentMonth =
            (selectedMonth != null && months.contains(selectedMonth))
                ? selectedMonth
                : months.first; 

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(availableYearMonthsProvider);
            ref.invalidate(dashboardSummaryProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: DesktopContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 월 선택 헤더
                  buildMonthSelectorHeader(context, ref, months, activeCurrentMonth),
                  
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: summaryAsync.when(
                      data: (summary) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTotalAssetCard(summary),
                          const SizedBox(height: 24),
                          const Text('자산별 현황', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          buildAssetTiles(summary),
                          const SizedBox(height: 28),
                          const Text('자산 비중', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          buildAssetRatioChartCard(summary),
                        ],
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Center(child: Text('데이터 로드 오류: $e')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}