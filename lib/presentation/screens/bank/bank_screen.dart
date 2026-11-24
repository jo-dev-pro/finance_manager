import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/onpop_invoked_provider.dart';
import '../../../core/router/app_router_path.dart';
import '../../../core/utils/responsive_extension.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../core/widgets/month_selector_header.dart';
import '../../../providers/bank/bank_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import 'widgets/build_bank_data.dart';

class BankScreen extends ConsumerWidget {
  const BankScreen({super.key});

  String _getLastYearMonth(String currentYearMonth) {
    try {
      final parts = currentYearMonth.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);

      DateTime date = DateTime(year, month, 1);
      DateTime lastMonthDate = DateTime(date.year, date.month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return currentYearMonth;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop(result);
          return;
        }

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
        appBar: MainAppBar(
          titleText: '은행 자산 현황',
          actions: [
            context.isMobile
                ? IconButton(
                  onPressed: () {
                    context.push(
                      AppRoutePath.monthlyBankBalance,
                      extra: selectedMonth,
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  color: context.primaryColor,
                )
                : ElevatedButton.icon(
                  onPressed: () {
                    context.push(
                      AppRoutePath.monthlyBankBalance,
                      extra: selectedMonth,
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('월말은행'),
                ),
          ],
        ),
        body: availableMonthsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '기준월 정보를 불러오지 못했습니다:\n$err',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          () => ref.invalidate(availableYearMonthsProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
          data: (months) {
            if (months.isEmpty) {
              return const Center(child: Text('등록된 기준월 데이터가 없습니다.'));
            }

            final String defaultTarget = months.first;
            final String activeCurrentMonth =
                (selectedMonth != null && months.contains(selectedMonth))
                    ? selectedMonth
                    : defaultTarget;

            if (selectedMonth == null || !months.contains(selectedMonth)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(selectedYearMonthProvider.notifier)
                    .select(activeCurrentMonth);
              });
            }

            final lastYearMonth = _getLastYearMonth(activeCurrentMonth);

            final bankDataAsync = ref.watch(
              bankScreenDataProvider(
                currentYearMonth: activeCurrentMonth,
                lastYearMonth: lastYearMonth,
              ),
            );

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
                    child: bankDataAsync.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('오류: $err')),
                      data: (rawItems) => BuildBankData(rawItems: rawItems),
                    ),
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
