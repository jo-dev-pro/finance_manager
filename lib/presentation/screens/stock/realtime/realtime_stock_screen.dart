import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/toss_direct_api_service.dart';
import '../../../../core/utils/upbit_api_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/jtext.dart';
import '../../../../core/widgets/main_appbar.dart';
import '../../../../core/widgets/main_constrainedbox.dart';
import '../../../../core/widgets/monthly_return_rate_chart_dialog.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/dashboard/dashboard_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class RealtimeStockScreen extends ConsumerStatefulWidget {
  const RealtimeStockScreen({super.key});

  @override
  ConsumerState<RealtimeStockScreen> createState() =>
      _RealtimeAssetScreenState();
}

class _RealtimeAssetScreenState extends ConsumerState<RealtimeStockScreen> {
  String? _selectedAccountId;
  bool _isLoadingQuotes = false;
  DateTime? _lastUpdatedAt;
  DateTime? _exchangeRateDate;

  Map<String, RealtimeQuote> _quoteMap = {};
  double _realtimeExchangeRate = 1380.0;

  String _getPreviousYearMonth(DateTime referenceDate) {
    final prevMonthDate = DateTime(
      referenceDate.year,
      referenceDate.month - 1,
      1,
    );
    return DateFormat('yyyy-MM').format(prevMonthDate);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshRealtimeQuotes();
    });
  }

  Future<void> _refreshRealtimeQuotes() async {
    if (_isLoadingQuotes) return;
    setState(() => _isLoadingQuotes = true);

    try {
      final months = ref.read(availableYearMonthsProvider).value ?? [];
      if (months.isEmpty) return;

      final latestMonth = months.first;
      final stockBalances =
          ref.read(monthlyStockBalanceProvider(latestMonth)).value ?? [];
      final stockItems = ref.read(stockItemProvider).value ?? [];
      final stockItemMap = {for (var s in stockItems) s.id!: s};

      final List<String> tossCodes = [];
      final List<String> upbitMarkets = [];

      for (var b in stockBalances) {
        if (b.quantity <= 0) continue;
        final item = stockItemMap[b.stockItemId];
        final code = item?.stockCode.trim() ?? '';
        if (code.isEmpty) continue;

        if (code.startsWith('KRW-') || code.startsWith('USDT-')) {
          upbitMarkets.add(code);
        } else {
          tossCodes.add(code);
        }
      }

      final Map<String, RealtimeQuote> fetchedQuotes = {};

      // 1. 업비트 시세 일괄 조회
      if (upbitMarkets.isNotEmpty) {
        final upbitResult = await UpbitApiService.getRealtimeQuotes(
          upbitMarkets.toSet().toList(),
        );
        fetchedQuotes.addAll(upbitResult);
      }

      // 2. 환율 및 토스 주식 시세 일괄 조회
      final rateFuture = TossDirectApiService.getCurrentExchangeRate();

      // 앞서 만든 일괄 조회 메서드 활용 (실패 시 예외 발생 또는 빈 결과 반환)
      final tossResult = await TossDirectApiService.getRealtimeQuotes(
        tossCodes.toSet().toList(),
      );
      fetchedQuotes.addAll(tossResult);

      final fetchedRate = await rateFuture;
      final now = DateTime.now();

      if (mounted) {
        setState(() {
          _quoteMap = fetchedQuotes;
          if (fetchedRate != null && fetchedRate > 0) {
            _realtimeExchangeRate = fetchedRate;
            _exchangeRateDate = now;
          }
          _lastUpdatedAt = now;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, '실시간 시세 조회 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingQuotes = false);
      }
    }
  }

  Widget _buildAccountLogo({required String? logoUrl, double size = 18}) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: size - 4,
                  color: Colors.indigo.shade700,
                ),
              ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.account_balance_wallet,
        size: size - 4,
        color: Colors.indigo.shade700,
      ),
    );
  }

  Widget _buildAccountLogoAndName({
    required String? logoUrl,
    required String accountName,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAccountLogo(logoUrl: logoUrl, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            accountName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDbPriceFallbackBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Text(
        'DB 단가 적용 중',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade900,
        ),
      ),
    );
  }

  Widget _buildStockAccountDropdown({
    required String? currentValue,
    required List<dynamic> stockAccounts,
    required Map<String?, dynamic> accountNameMap,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: currentValue,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  _buildAccountLogo(logoUrl: null, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    '전체 계좌',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ...stockAccounts.map((acc) {
              final accId = acc.id as String?;
              final accName =
                  accountNameMap[acc.accountNameId]?.accountName ?? '계좌';
              return DropdownMenuItem<String?>(
                value: accId,
                child: Row(
                  children: [
                    _buildAccountLogo(
                      logoUrl: acc.logoUrl as String?,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        accName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final accounts = ref.watch(accountProvider).value ?? [];
    final accountNames = ref.watch(accountNameProvider).value ?? [];
    final stockItems = ref.watch(stockItemProvider).value ?? [];

    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final stockItemMap = {for (var s in stockItems) s.id!: s};

    final stockAccounts =
        accounts
            .where((a) => a.accountType.trim() == '증권' && a.status == '활동')
            .toList();

    final isValidAccountId =
        _selectedAccountId == null ||
        stockAccounts.any((acc) => acc.id == _selectedAccountId);
    final currentAccountValue = isValidAccountId ? _selectedAccountId : null;

    final selectedAcc =
        currentAccountValue != null ? accountMap[currentAccountValue] : null;
    final isSingleOverseasAccount = selectedAcc?.isForeignCurrency ?? false;

    final formattedRate = _realtimeExchangeRate.toExchangeRateString();
    final quoteDate = _lastUpdatedAt ?? DateTime.now();
    final rateBaseDateStr = (_exchangeRateDate ?? quoteDate).toYmdDot();
    final prevMonthEndStr = _getPreviousYearMonth(quoteDate);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '실시간 자산 평가',
        actions: [
          if (_lastUpdatedAt != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  DateFormat('HH:mm:ss').format(_lastUpdatedAt!),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),
          IconButton(
            onPressed: _isLoadingQuotes ? null : _refreshRealtimeQuotes,
            icon:
                _isLoadingQuotes
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.refresh),
            tooltip: '실시간 시세 새로고침',
          ),
        ],
      ),
      body: availableMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('데이터 로드 실패: $err')),
        data: (months) {
          if (months.isEmpty) {
            return const Center(child: Text('기준 보유 수량 데이터가 없습니다.'));
          }

          final baseMonth = months.first;
          final baseBalances =
              ref.watch(monthlyStockBalanceProvider(baseMonth)).value ?? [];
          final baseAccountBalances =
              ref.watch(monthlyStockAccountBalanceProvider(baseMonth)).value ??
              [];

          final prevMonthBalances =
              ref.watch(monthlyStockBalanceProvider(prevMonthEndStr)).value ??
              [];
          final prevMonthAccountBalances =
              ref
                  .watch(monthlyStockAccountBalanceProvider(prevMonthEndStr))
                  .value ??
              [];

          final prevMonthAccountBalanceMap = {
            for (var ab in prevMonthAccountBalances) ab.accountId: ab,
          };

          final filteredItems =
              baseBalances.where((b) {
                if (b.quantity <= 0) return false;
                if (currentAccountValue != null &&
                    b.accountId != currentAccountValue) {
                  return false;
                }
                return true;
              }).toList();

          final filteredAccountBalances =
              currentAccountValue == null
                  ? baseAccountBalances
                  : baseAccountBalances
                      .where((ab) => ab.accountId == currentAccountValue)
                      .toList();

          final hasAnyLiveQuote = filteredItems.any((item) {
            final code = stockItemMap[item.stockItemId]?.stockCode.trim() ?? '';
            return code.isNotEmpty && _quoteMap[code] != null;
          });

          double totalRealtimeAsset = 0;
          double totalPrincipal = 0;
          double totalPayoutAndSale = 0;
          double totalDailyDiff = 0;
          double totalPrevMonthEndAsset = 0;
          double rawForeignEval = 0;

          for (var item in filteredItems) {
            final acc = accountMap[item.accountId];
            final isForeign = acc?.isForeignCurrency ?? false;
            final rate = isForeign ? _realtimeExchangeRate : 1.0;

            final prevAccBal = prevMonthAccountBalanceMap[item.accountId];
            final prevRate =
                isForeign
                    ? ((prevAccBal != null && prevAccBal.exchangeRate > 0)
                        ? prevAccBal.exchangeRate
                        : _realtimeExchangeRate)
                    : 1.0;

            final stock = stockItemMap[item.stockItemId];
            final code = stock?.stockCode.trim() ?? '';
            final quote = _quoteMap[code];

            final livePrice = quote?.currentPrice ?? item.currentPrice;
            final dailyChangePerUnit = quote?.changePrice ?? 0.0;

            final prevMonthItem = prevMonthBalances.firstWhereOrNull(
              (prev) =>
                  prev.accountId == item.accountId &&
                  prev.stockItemId == item.stockItemId,
            );
            final prevMonthUnitPrice =
                prevMonthItem?.currentPrice ?? item.currentPrice;

            final liveEval = item.quantity * livePrice;
            final liveEvalKrw = liveEval * rate;
            final prevMonthEndEvalKrw =
                (item.quantity * prevMonthUnitPrice) * prevRate;
            final dailyDiffKrw = (item.quantity * dailyChangePerUnit) * rate;

            totalRealtimeAsset += liveEvalKrw;
            totalPrevMonthEndAsset += prevMonthEndEvalKrw;
            totalDailyDiff += dailyDiffKrw;
            totalPrincipal += item.principal * rate;
            totalPayoutAndSale +=
                (item.totalPayout + item.totalWithdrawal) * rate;

            if (isSingleOverseasAccount) {
              rawForeignEval += liveEval;
            }
          }

          double totalCashKrw = 0;
          double totalPrevMonthEndCashKrw = 0;
          double rawForeignCash = 0;

          for (var ab in filteredAccountBalances) {
            final acc = accountMap[ab.accountId];
            final isForeign = acc?.isForeignCurrency ?? false;
            final rate = isForeign ? _realtimeExchangeRate : 1.0;
            totalCashKrw += ab.cashBalance * rate;

            final prevAb = prevMonthAccountBalanceMap[ab.accountId];
            final prevCash = prevAb?.cashBalance ?? ab.cashBalance;
            final prevRate =
                isForeign
                    ? ((prevAb != null && prevAb.exchangeRate > 0)
                        ? prevAb.exchangeRate
                        : _realtimeExchangeRate)
                    : 1.0;
            totalPrevMonthEndCashKrw += prevCash * prevRate;

            if (isSingleOverseasAccount) {
              rawForeignCash += ab.cashBalance;
            }
          }

          totalRealtimeAsset += totalCashKrw;
          totalPrevMonthEndAsset += totalPrevMonthEndCashKrw;

          final rawForeignGrandTotal = rawForeignEval + rawForeignCash;
          final totalAssetDisplayText =
              isSingleOverseasAccount
                  ? '${totalRealtimeAsset.round().toWon()} (${rawForeignGrandTotal.toUSD()})'
                  : totalRealtimeAsset.round().toWon();

          final totalProfit =
              (totalRealtimeAsset + totalPayoutAndSale) - totalPrincipal;
          final totalReturnRate =
              totalPrincipal > 0 ? (totalProfit / totalPrincipal) * 100 : 0.0;
          final monthlyDiff = totalRealtimeAsset - totalPrevMonthEndAsset;

          return MainConstrainedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStockAccountDropdown(
                    currentValue: currentAccountValue,
                    stockAccounts: stockAccounts,
                    accountNameMap: accountNameMap,
                    onChanged:
                        (val) => setState(() => _selectedAccountId = val),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '수량 기준월: $baseMonth',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '환율: $formattedRate원(기준일:$rateBaseDateStr)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (!hasAnyLiveQuote && filteredItems.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildDbPriceFallbackBadge(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '실시간 시세를 불러오지 못해 DB 단가로 계산 중입니다.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // 상단 실시간 요약 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '실시간 총 평가 자산',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        JText(
                          totalAssetDisplayText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '총 투자 원금',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                JText(
                                  totalPrincipal.round().toWon(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  '실시간 총 손익 (수익률)',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    totalProfit.round().toSignedPriceText(
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    totalReturnRate.toSignedPercentText(
                                      withParentheses: true,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '전일 대비: ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                totalDailyDiff.round().toSignedPriceText(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '전월($prevMonthEndStr) 대비: ',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                monthlyDiff.round().toSignedPriceText(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '보유 종목 실시간 평가 내역',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (filteredItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          '선택한 조건에 해당하는 보유 종목이 없습니다.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final acc = accountMap[item.accountId];
                        final accountName =
                            acc != null
                                ? (accountNameMap[acc.accountNameId]
                                        ?.accountName ??
                                    '계좌')
                                : '계좌';
                        final isForeign = acc?.isForeignCurrency ?? false;

                        final stock = stockItemMap[item.stockItemId];
                        final stockName = stock?.itemName ?? '알 수 없는 종목';
                        final stockCode = stock?.stockCode.trim() ?? '';
                        final displayName =
                            stockCode.isNotEmpty
                                ? '$stockName ($stockCode)'
                                : stockName;

                        final quote =
                            stockCode.isNotEmpty ? _quoteMap[stockCode] : null;
                        final isUsingDbPrice = quote == null;

                        final livePrice =
                            quote?.currentPrice ?? item.currentPrice;
                        final dailyChangeUnit = quote?.changePrice ?? 0.0;

                        final prevMonthItem = prevMonthBalances
                            .firstWhereOrNull(
                              (prev) =>
                                  prev.accountId == item.accountId &&
                                  prev.stockItemId == item.stockItemId,
                            );
                        final prevMonthUnitPrice =
                            prevMonthItem?.currentPrice ?? item.currentPrice;

                        final liveBalance = item.quantity * livePrice;
                        final dailyDiff = item.quantity * dailyChangeUnit;
                        final monthlyDiffItem =
                            (livePrice - prevMonthUnitPrice) * item.quantity;

                        final itemProfit =
                            (liveBalance +
                                item.totalPayout +
                                item.totalWithdrawal) -
                            item.principal;
                        final itemReturnRate =
                            item.principal > 0
                                ? (itemProfit / item.principal) * 100
                                : 0.0;

                        String fmtMoney(double val) =>
                            isForeign ? val.toUSD() : val.round().toWon();

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap:
                                () => MonthlyReturnRateChartDialog.show(
                                  context,
                                  titleText: '$displayName 수익률 (%)',
                                  accountName: accountName,
                                  logoUrl: acc?.logoUrl,
                                  emptyMessage: '표시할 수익률 데이터가 없습니다.',
                                  rateCalculator: (dialogRef, ym) {
                                    final monthsList =
                                        dialogRef
                                            .watch(availableYearMonthsProvider)
                                            .value ??
                                        [];
                                    final latestYm =
                                        monthsList.isNotEmpty
                                            ? monthsList.reversed.toList().last
                                            : null;
                                    final liveQuote =
                                        stockCode.isNotEmpty
                                            ? _quoteMap[stockCode]
                                            : null;

                                    final monthItems =
                                        dialogRef
                                            .watch(
                                              monthlyStockBalanceProvider(ym),
                                            )
                                            .value ??
                                        [];
                                    final matchedItems = monthItems.where(
                                      (b) =>
                                          b.accountId == item.accountId &&
                                          b.stockItemId == item.stockItemId,
                                    );
                                    final totalPrin = matchedItems.fold<double>(
                                      0.0,
                                      (sum, b) => sum + b.principal,
                                    );
                                    if (totalPrin <= 0) return 0.0;

                                    final totalPayout = matchedItems
                                        .fold<double>(
                                          0.0,
                                          (sum, b) => sum + b.totalPayout,
                                        );
                                    final totalWithdrawal = matchedItems
                                        .fold<double>(
                                          0.0,
                                          (sum, b) => sum + b.totalWithdrawal,
                                        );

                                    final evalBal =
                                        (ym == latestYm && liveQuote != null)
                                            ? matchedItems.fold<double>(
                                                  0.0,
                                                  (sum, b) => sum + b.quantity,
                                                ) *
                                                liveQuote.currentPrice
                                            : matchedItems.fold<double>(
                                              0.0,
                                              (sum, b) => sum + b.balance,
                                            );

                                    final profit =
                                        (evalBal +
                                            totalPayout +
                                            totalWithdrawal) -
                                        totalPrin;
                                    return (profit / totalPrin) * 100;
                                  },
                                ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isUsingDbPrice) ...[
                                        const SizedBox(width: 8),
                                        _buildDbPriceFallbackBadge(),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _buildAccountLogoAndName(
                                    logoUrl: acc?.logoUrl,
                                    accountName: accountName,
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      JText(
                                        '실시간 평가액: ${fmtMoney(liveBalance)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      JText(
                                        '원금: ${fmtMoney(item.principal)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '현재가: ${fmtMoney(livePrice)}  |  수량: ${item.quantity.toCommaString()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '총 손익: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          isForeign
                                              ? JText(
                                                '${itemProfit > 0 ? '+' : ''}${itemProfit.toUSD()}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      itemProfit >= 0
                                                          ? Colors.red.shade700
                                                          : Colors
                                                              .blue
                                                              .shade700,
                                                ),
                                              )
                                              : itemProfit
                                                  .round()
                                                  .toSignedPriceText(
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 16,
                                    color: Colors.black12,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '수익률: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          itemReturnRate.toSignedPercentText(
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '전일: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          _buildSignedMoney(
                                            dailyDiff,
                                            isForeign: isForeign,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '전월: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          _buildSignedMoney(
                                            monthlyDiffItem,
                                            isForeign: isForeign,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignedMoney(double amount, {required bool isForeign}) {
    if (isForeign) {
      return Text(
        '${amount > 0 ? '+' : ''}${amount.toUSD()}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color:
              amount > 0
                  ? Colors.red.shade700
                  : amount < 0
                  ? Colors.blue.shade700
                  : Colors.grey,
        ),
      );
    }
    return amount.round().toSignedPriceText(
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}
