// lib/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/dashboard/dashboard_provider.dart';
import '../../scaffold/widgets/common_responsive_layout.dart';
import 'responsive_screens/dashboard_desktop.dart';
import 'responsive_screens/dashboard_mobile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 기존에 있던 기준월 초기화 및 리스너 로직 유지
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

    return Scaffold(
      appBar: AppBar(title: const Text('대시보드'), elevation: 0),
      body: monthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('기준월 정보를 불러올 수 없습니다: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('등록된 자산/기준월 데이터가 없습니다.'));
          }

          // 반응형 레이아웃 분기 (768px 기준)
          return CommonResponsiveLayout(
            desktopScreen: const DashboardDesktopScreen(),
            mobileScreen: const DashboardMobileScreen(),
          );
        },
      ),
    );
  }
}