import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthsAsync = ref.watch(availableYearMonthsProvider);
    final selectedMonth = ref.watch(selectedYearMonthProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final currencyFormatter = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('자산 대시보드'),
      ),
      body: monthsAsync.when(
        data: (months) {
          if (months.isEmpty) {
            return const Center(
              child: Text('등록된 월말 잔액 데이터가 없습니다.'),
            );
          }

          // 초기 기준월 세팅 (첫 진입 시 가장 최근 월 자동 선택)
          if (selectedMonth == null && months.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedYearMonthProvider.notifier).select(months.first);
            });
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(availableYearMonthsProvider);
              ref.invalidate(dashboardSummaryProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0. 기준월 선택 (콤보박스)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '기준월 선택',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedMonth ?? months.first,
                            underline: const SizedBox(),
                            items: months.map((m) {
                              return DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref
                                    .read(selectedYearMonthProvider.notifier)
                                    .select(val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  summaryAsync.when(
                    data: (summary) {
                      final isPositive = summary.profitOrLoss >= 0;
                      final profitColor =
                          isPositive ? Colors.redAccent : Colors.blueAccent;

                      return Column(
                        children: [
                          // 1. 최상단 총 평가액, 총투자액, 평가손, 수익률
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.blueGrey.shade900,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '총 자산 평가액',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${currencyFormatter.format(summary.totalValuation)} 원',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(
                                      height: 24, color: Colors.white24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoItem(
                                        '총 투자액',
                                        '${currencyFormatter.format(summary.totalInvested)} 원',
                                      ),
                                      _buildInfoItem(
                                        '평가손익',
                                        '${isPositive ? '+' : ''}${currencyFormatter.format(summary.profitOrLoss)} 원',
                                        textColor: profitColor,
                                      ),
                                      _buildInfoItem(
                                        '수익률',
                                        '${isPositive ? '+' : ''}${summary.returnRate.toStringAsFixed(2)}%',
                                        textColor: profitColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. 은행 총 잔액, 증권 총 평가액, 연금 총 평가액
                          Row(
                            children: [
                              Expanded(
                                child: _buildAssetCard(
                                  '은행 잔액',
                                  summary.bankBalance,
                                  Colors.blue,
                                  currencyFormatter,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildAssetCard(
                                  '증권 평가액',
                                  summary.stockBalance,
                                  Colors.orange,
                                  currencyFormatter,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildAssetCard(
                                  '연금 평가액',
                                  summary.pensionBalance,
                                  Colors.green,
                                  currencyFormatter,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 3. 차트 (총 평가액 구성 비율 파이 차트)
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '자산 구성 비중',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 200,
                                    child: summary.totalValuation == 0
                                        ? const Center(
                                            child: Text('평가액 데이터가 없습니다.'))
                                        : PieChart(
                                            PieChartData(
                                              sectionsSpace: 4,
                                              centerSpaceRadius: 40,
                                              sections: [
                                                PieChartSectionData(
                                                  color: Colors.blue,
                                                  value: summary.bankBalance,
                                                  title: '은행\n${_calcRatio(summary.bankBalance, summary.totalValuation)}%',
                                                  radius: 50,
                                                  titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                PieChartSectionData(
                                                  color: Colors.orange,
                                                  value: summary.stockBalance,
                                                  title: '증권\n${_calcRatio(summary.stockBalance, summary.totalValuation)}%',
                                                  radius: 50,
                                                  titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                PieChartSectionData(
                                                  color: Colors.green,
                                                  value: summary.pensionBalance,
                                                  title: '연금\n${_calcRatio(summary.pensionBalance, summary.totalValuation)}%',
                                                  radius: 50,
                                                  titleStyle: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, st) => Center(child: Text('오류 발생: $e')),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('기준월 목록 로드 실패: $e')),
      ),
    );
  }

  // 자산 카드 컴포넌트
  Widget _buildAssetCard(
      String title, double amount, Color color, NumberFormat formatter) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatter.format(amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const Text('원', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // 요약 정보 항목 컴포넌트
  Widget _buildInfoItem(String title, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _calcRatio(double value, double total) {
    if (total == 0) return '0';
    return ((value / total) * 100).toStringAsFixed(1);
  }
}