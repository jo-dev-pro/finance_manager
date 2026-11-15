import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/number_formatter.dart';
import '../../../core/utils/toss_direct_api_service.dart';
import '../../../core/utils/upbit_api_service.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../providers/account/account_name_provider.dart';
import '../../../providers/account/account_provider.dart';
import '../../../providers/dashboard/dashboard_provider.dart';
import '../../../providers/monthly_data/monthly_stock_account_balance_provider.dart';
import '../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../providers/stock/stock_item_provider.dart';

enum AssetFilterType { all, stock, crypto }

class RealtimeAssetScreen extends ConsumerStatefulWidget {
  const RealtimeAssetScreen({super.key});

  @override
  ConsumerState<RealtimeAssetScreen> createState() =>
      _RealtimeAssetScreenState();
}

class _RealtimeAssetScreenState extends ConsumerState<RealtimeAssetScreen> {
  AssetFilterType _filterType = AssetFilterType.all;
  bool _isLoadingQuotes = false;
  DateTime? _lastUpdatedAt;

  Map<String, RealtimeQuote> _quoteMap = {};
  double _realtimeExchangeRate = 1380.0;

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
          ref.read(monthlyStockBalanceNotifierProvider(latestMonth)).value ??
              [];
      final stockItems = ref.read(stockItemNotifierProvider).value ?? [];
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

      if (upbitMarkets.isNotEmpty) {
        final upbitResult = await UpbitApiService.getRealtimeQuotes(
          upbitMarkets.toSet().toList(),
        );
        fetchedQuotes.addAll(upbitResult);
      }

      final rateFuture = TossDirectApiService.getCurrentExchangeRate();
      final tossFutures = tossCodes.toSet().map((code) async {
        final quote = await TossDirectApiService.getRealtimeQuote(code);
        if (quote != null) {
          fetchedQuotes[code] = quote;
        }
      });

      final results = await Future.wait([rateFuture, ...tossFutures]);
      final fetchedRate = results.first as double?;

      if (mounted) {
        setState(() {
          _quoteMap = fetchedQuotes;
          if (fetchedRate != null && fetchedRate > 0) {
            _realtimeExchangeRate = fetchedRate;
          }
          _lastUpdatedAt = DateTime.now();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingQuotes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableMonthsAsync = ref.watch(availableYearMonthsProvider);
    final accounts = ref.watch(accountNotifierProvider).value ?? [];
    final accountNames = ref.watch(accountNameNotifierProvider).value ?? [];
    final stockItems = ref.watch(stockItemNotifierProvider).value ?? [];

    final accountMap = {for (var a in accounts) a.id!: a};
    final accountNameMap = {for (var an in accountNames) an.id: an};
    final stockItemMap = {for (var s in stockItems) s.id!: s};

    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 자산 평가'),
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
            icon: _isLoadingQuotes
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: '실시간 시세 새로고침',
          ),
          const SizedBox(width: 8),
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
              ref.watch(monthlyStockBalanceNotifierProvider(baseMonth)).value ??
                  [];
          final baseAccountBalances = ref
                  .watch(monthlyStockAccountBalanceNotifierProvider(baseMonth))
                  .value ??
              [];

          final filteredItems = baseBalances.where((b) {
            if (b.quantity <= 0) return false;
            final code = stockItemMap[b.stockItemId]?.stockCode.trim() ?? '';
            final isCrypto =
                code.startsWith('KRW-') || code.startsWith('USDT-');

            if (_filterType == AssetFilterType.stock) return !isCrypto;
            if (_filterType == AssetFilterType.crypto) return isCrypto;
            return true;
          }).toList();

          double totalRealtimeAsset = 0;
          double totalPrincipal = 0;
          double totalPayoutAndSale = 0;
          double totalDailyDiff = 0;
          double totalPrevMonthAsset = 0;

          for (var item in filteredItems) {
            final acc = accountMap[item.accountId];
            final isForeign = acc?.isForeignCurrency ?? false;
            final rate = isForeign ? _realtimeExchangeRate : 1.0;

            final stock = stockItemMap[item.stockItemId];
            final code = stock?.stockCode.trim() ?? '';
            final quote = _quoteMap[code];

            final livePrice = quote?.currentPrice ?? item.currentPrice;
            final dailyChangePerUnit = quote?.changePrice ?? 0.0;

            final liveEvalKrw = (item.quantity * livePrice) * rate;
            final prevMonthEvalKrw = item.balance * rate;
            final dailyDiffKrw = (item.quantity * dailyChangePerUnit) * rate;

            totalRealtimeAsset += liveEvalKrw;
            totalPrevMonthAsset += prevMonthEvalKrw;
            totalDailyDiff += dailyDiffKrw;
            totalPrincipal += item.principal * rate;
            totalPayoutAndSale +=
                (item.totalPayout + item.totalWithdrawal) * rate;
          }

          double totalCashKrw = 0;
          if (_filterType == AssetFilterType.all) {
            for (var ab in baseAccountBalances) {
              final acc = accountMap[ab.accountId];
              final isForeign = acc?.isForeignCurrency ?? false;
              final rate = isForeign ? _realtimeExchangeRate : 1.0;
              totalCashKrw += ab.cashBalance * rate;
            }
          }

          totalRealtimeAsset += totalCashKrw;
          totalPrevMonthAsset += totalCashKrw;

          final totalProfit =
              (totalRealtimeAsset + totalPayoutAndSale) - totalPrincipal;
          final totalReturnRate =
              totalPrincipal > 0 ? (totalProfit / totalPrincipal) * 100 : 0.0;
          final monthlyDiff = totalRealtimeAsset - totalPrevMonthAsset;

          return MainConstrainedBox(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SegmentedButton<AssetFilterType>(
                        segments: const [
                          ButtonSegment(
                            value: AssetFilterType.all,
                            label: Text('전체'),
                          ),
                          ButtonSegment(
                            value: AssetFilterType.stock,
                            label: Text('주식(토스)'),
                          ),
                          ButtonSegment(
                            value: AssetFilterType.crypto,
                            label: Text('코인(업비트)'),
                          ),
                        ],
                        selected: {_filterType},
                        onSelectionChanged: (set) {
                          setState(() => _filterType = set.first);
                        },
                      ),
                    ],
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
                        '적용 환율: ${_realtimeExchangeRate.toCommaString()}원/\$',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
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
                        Text(
                          totalRealtimeAsset.round().toWon(),
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
                                Text(
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
                                      positiveColor: const Color(0xFFFF8A80),
                                      negativeColor: const Color(0xFF82B1FF),
                                      zeroColor: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    totalReturnRate.toSignedPercentText(
                                      withParentheses: true,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      positiveColor: const Color(0xFFFF8A80),
                                      negativeColor: const Color(0xFF82B1FF),
                                      zeroColor: Colors.white,
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
                                  positiveColor: const Color(0xFFFF8A80),
                                  negativeColor: const Color(0xFF82B1FF),
                                  zeroColor: Colors.white,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '전월($baseMonth) 대비: ',
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
                                  positiveColor: const Color(0xFFFF8A80),
                                  negativeColor: const Color(0xFF82B1FF),
                                  zeroColor: Colors.white,
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

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final acc = accountMap[item.accountId];
                      final institution =
                          acc?.financialInstitution ?? '기타 금융기관';
                      final accName =
                          acc != null
                              ? (accountNameMap[acc.accountNameId]?.accountName ??
                                  '계좌')
                              : '계좌';
                      final isForeign = acc?.isForeignCurrency ?? false;

                      final stock = stockItemMap[item.stockItemId];
                      final stockName = stock?.itemName ?? '알 수 없는 종목';
                      final stockCode = stock?.stockCode.trim() ?? '';
                      final isCrypto = stockCode.startsWith('KRW-') ||
                          stockCode.startsWith('USDT-');

                      final quote = _quoteMap[stockCode];
                      final livePrice = quote?.currentPrice ?? item.currentPrice;
                      final dailyChangeUnit = quote?.changePrice ?? 0.0;

                      final liveBalance = item.quantity * livePrice;
                      final dailyDiff = item.quantity * dailyChangeUnit;
                      final monthlyDiffItem = liveBalance - item.balance;

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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                                        stockCode.isNotEmpty
                                            ? '$stockName ($stockCode)'
                                            : stockName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCrypto
                                            ? Colors.orange.shade50
                                            : Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isCrypto ? '업비트' : '토스증권',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isCrypto
                                              ? Colors.orange.shade800
                                              : Colors.indigo.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '[$institution] $accName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '실시간 평가액: ${fmtMoney(liveBalance)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
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
                                            ? Text(
                                                '${itemProfit > 0 ? '+' : ''}${itemProfit.toUSD()}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: itemProfit >= 0
                                                      ? Colors.red.shade700
                                                      : Colors.blue.shade700,
                                                ),
                                              )
                                            : itemProfit
                                                .round()
                                                .toSignedPriceText(
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  positiveColor:
                                                      Colors.red.shade700,
                                                  negativeColor:
                                                      Colors.blue.shade700,
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
                                          positiveColor: Colors.red.shade700,
                                          negativeColor: Colors.blue.shade700,
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
          color: amount > 0
              ? Colors.red.shade700
              : amount < 0
                  ? Colors.blue.shade700
                  : Colors.grey,
        ),
      );
    }
    return amount.round().toSignedPriceText(
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}