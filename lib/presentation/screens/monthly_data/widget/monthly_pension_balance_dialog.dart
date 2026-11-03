import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../models/pension/pension_product.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';

class _GroupedPensionItem {
  final String accountId;
  final String productId;
  double principal;

  _GroupedPensionItem({
    required this.accountId,
    required this.productId,
    required this.principal,
  });
}

class MonthlyPensionBalanceDialog extends ConsumerStatefulWidget {
  final String yearMonth;

  const MonthlyPensionBalanceDialog({super.key, required this.yearMonth});

  @override
  ConsumerState<MonthlyPensionBalanceDialog> createState() =>
      _MonthlyPensionBalanceDialogState();
}

class _MonthlyPensionBalanceDialogState
    extends ConsumerState<MonthlyPensionBalanceDialog> {
  late String _selectedYearMonth;
  String? _selectedAccountId;

  // 상품별 직접 평가액 입력 컨트롤러
  final Map<String, TextEditingController> _balanceControllers = {};
  // 상품별 좌수 / 기준가 입력 컨트롤러
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _basePriceControllers = {};

  final Map<String, TextEditingController> _principalControllers = {};
  final Map<String, TextEditingController> _payoutControllers = {};
  final Map<String, TextEditingController> _withdrawalControllers = {};

  // 계좌 공통 입력 컨트롤러 (현금성 잔액, 당월 중도 인출금)
  final TextEditingController _accountCashBalanceController =
      TextEditingController();
  final TextEditingController _accountMonthlyWithdrawalController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.yearMonth;
  }

  @override
  void dispose() {
    for (var c in _balanceControllers.values) {
      c.dispose();
    }
    for (var c in _quantityControllers.values) {
      c.dispose();
    }
    for (var c in _basePriceControllers.values) {
      c.dispose();
    }
    for (var c in _principalControllers.values) {
      c.dispose();
    }
    for (var c in _payoutControllers.values) {
      c.dispose();
    }
    for (var c in _withdrawalControllers.values) {
      c.dispose();
    }
    _accountCashBalanceController.dispose();
    _accountMonthlyWithdrawalController.dispose();
    super.dispose();
  }

  String _getPreviousYearMonth(String ym) {
    try {
      final parts = ym.split('-');
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      DateTime lastMonthDate = DateTime(year, month - 1, 1);
      return DateFormat('yyyy-MM').format(lastMonthDate);
    } catch (_) {
      return ym;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final holdingProductsAsync = ref.watch(
      pensionHoldingProductNotifierProvider,
    );
    final pensionProductsAsync = ref.watch(pensionProductNotifierProvider);

    final existingCurrentBalancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth),
    );
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final existingPrevBalancesAsync = ref.watch(
      monthlyPensionBalanceNotifierProvider(prevYearMonth),
    );

    final currentAccountBalancesAsync = ref.watch(
      monthlyPensionAccountBalanceNotifierProvider(_selectedYearMonth),
    );
    final prevAccountBalancesAsync = ref.watch(
      monthlyPensionAccountBalanceNotifierProvider(prevYearMonth),
    );

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '연금 월말 평가액/원금 일괄 입력',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _selectedYearMonth,
                decoration: const InputDecoration(
                  labelText: '기준월',
                  hintText: 'YYYY-MM',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _selectedYearMonth = val.trim();
                  });
                },
                validator:
                    (val) => val == null || val.isEmpty ? '기준월을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),

              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('계좌 로딩 실패: $err'),
                data: (accounts) {
                  final accountNames = accountNamesAsync.value ?? [];
                  final accountNameMap = {
                    for (var an in accountNames) an.id: an,
                  };

                  final pensionAccounts =
                      accounts
                          .where(
                            (a) =>
                                (a.accountType.trim().contains('연금') ||
                                    a.accountType.trim().contains('IRP') ||
                                    a.accountType.trim().contains('DC')) &&
                                a.status == '활동',
                          )
                          .toList();

                  if (pensionAccounts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '등록된 연금 계좌가 없습니다. 계좌 관리에서 연금 계좌를 먼저 추가해 주세요.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (_selectedAccountId == null ||
                      !pensionAccounts.any((a) => a.id == _selectedAccountId)) {
                    _selectedAccountId = pensionAccounts.first.id;
                  }

                  final currentAccBalances =
                      currentAccountBalancesAsync.value ?? [];
                  final prevAccBalances = prevAccountBalancesAsync.value ?? [];

                  final currentAccData = currentAccBalances.firstWhereOrNull(
                    (b) => b.accountId == _selectedAccountId,
                  );
                  final prevAccData = prevAccBalances.firstWhereOrNull(
                    (b) => b.accountId == _selectedAccountId,
                  );

                  if (_accountCashBalanceController.text.isEmpty) {
                    final defaultCash =
                        (currentAccData != null &&
                                currentAccData.cashBalance > 0)
                            ? currentAccData.cashBalance
                            : (prevAccData?.cashBalance ?? 0.0);
                    if (defaultCash > 0) {
                      _accountCashBalanceController.text =
                          defaultCash.toCommaString();
                    }
                  }

                  if (_accountMonthlyWithdrawalController.text.isEmpty &&
                      currentAccData != null &&
                      currentAccData.monthlyWithdrawal > 0) {
                    _accountMonthlyWithdrawalController.text =
                        currentAccData.monthlyWithdrawal.toCommaString();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: '연금 계좌 선택',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        items:
                            pensionAccounts.map((acc) {
                              final institution = acc.financialInstitution;
                              final nameObj = accountNameMap[acc.accountNameId];
                              final nameDisplay = nameObj?.accountName ?? '계좌';
                              return DropdownMenuItem(
                                value: acc.id,
                                child: Text('$institution - $nameDisplay'),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedAccountId = val;
                            _accountCashBalanceController.clear();
                            _accountMonthlyWithdrawalController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 계좌 공통 현금성 자산 카드
                      Card(
                        color: Colors.teal.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.teal.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 18,
                                    color: Colors.teal.shade800,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '계좌 공통 현금성 자산 및 인출 관리',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _accountCashBalanceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: '계좌 현금성 잔액 (예수금)',
                                        hintText: '0',
                                        suffixText: '원',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _accountMonthlyWithdrawalController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: '당월 계좌 인출액',
                                        hintText: '0',
                                        suffixText: '원',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        fillColor: Colors.white,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      holdingProductsAsync.when(
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error: (err, _) => Text('보유 상품 로딩 실패: $err'),
                        data: (holdingProducts) {
                          final pensionProducts =
                              pensionProductsAsync.value ?? [];
                          final productMap = {
                            for (var p in pensionProducts) p.id!: p.productName,
                          };

                          final Map<String, _GroupedPensionItem> groupedMap =
                              {};
                          final currentBalances =
                              existingCurrentBalancesAsync.value ?? [];
                          final prevBalances =
                              existingPrevBalancesAsync.value ?? [];

                          final prevBalanceMap = {
                            for (var b in prevBalances)
                              '${b.accountId}_${b.productId}': b,
                          };

                          final matchedHoldings =
                              holdingProducts
                                  .where(
                                    (hp) =>
                                        hp.accountId == _selectedAccountId &&
                                        hp.isActive,
                                  )
                                  .toList();

                          for (var hp in matchedHoldings) {
                            final prodId = hp.productId;
                            final prevData =
                                prevBalanceMap['${hp.accountId}_$prodId'];
                            groupedMap[prodId] = _GroupedPensionItem(
                              accountId: hp.accountId,
                              productId: prodId,
                              principal: prevData?.principal ?? 0.0,
                            );
                          }

                          final groupedItems = groupedMap.values.toList();
                          final currentBalanceMap = {
                            for (var b in currentBalances)
                              '${b.accountId}_${b.productId}': b,
                          };

                          if (groupedItems.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('해당 연금 계좌에 등록된 보유 상품이 없습니다.'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedItems.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final groupItem = groupedItems[index];
                              final prodId = groupItem.productId;
                              final productName =
                                  productMap[prodId] ?? '알 수 없는 상품';

                              final key = '${_selectedAccountId}_$prodId';
                              final currentData = currentBalanceMap[key];

                              if (!_balanceControllers.containsKey(key)) {
                                final currentBal =
                                    (currentData != null &&
                                            currentData.balance > 0)
                                        ? currentData.balance
                                        : (prevBalanceMap[key]?.balance ?? 0.0);

                                final currentPrin =
                                    (currentData != null &&
                                            currentData.principal > 0)
                                        ? currentData.principal
                                        : (prevBalanceMap[key]?.principal ??
                                            groupItem.principal);

                                final currentPayout =
                                    currentData?.totalPayout ?? 0.0;
                                final currentWithdrawal =
                                    currentData?.totalWithdrawal ?? 0.0;

                                _balanceControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentBal > 0
                                              ? currentBal.toCommaString()
                                              : '',
                                    );
                                _quantityControllers[key] =
                                    TextEditingController();
                                _basePriceControllers[key] =
                                    TextEditingController();

                                _principalControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentPrin > 0
                                              ? currentPrin.toCommaString()
                                              : '',
                                    );
                                _payoutControllers[key] = TextEditingController(
                                  text:
                                      currentPayout > 0
                                          ? currentPayout.toCommaString()
                                          : '',
                                );
                                _withdrawalControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentWithdrawal > 0
                                              ? currentWithdrawal
                                                  .toCommaString()
                                              : '',
                                    );
                              }

                              final hasQuantityOrBasePrice =
                                  (_quantityControllers[key]?.text
                                          .trim()
                                          .isNotEmpty ??
                                      false) ||
                                  (_basePriceControllers[key]?.text
                                          .trim()
                                          .isNotEmpty ??
                                      false);

                              final hasWithdrawal =
                                  (_withdrawalControllers[key]?.text
                                          .trim()
                                          .isNotEmpty ??
                                      false) &&
                                  (double.tryParse(
                                            _withdrawalControllers[key]!.text
                                                .replaceAll(
                                                  RegExp(r'[^0-9]'),
                                                  '',
                                                ),
                                          ) ??
                                          0) >
                                      0;

                              // 좌수 * 기준가 / 1000 계산
                              final qty =
                                  double.tryParse(
                                    _quantityControllers[key]?.text
                                            .replaceAll(',', '')
                                            .trim() ??
                                        '',
                                  ) ??
                                  0.0;
                              final basePrice =
                                  double.tryParse(
                                    _basePriceControllers[key]?.text
                                            .replaceAll(',', '')
                                            .trim() ??
                                        '',
                                  ) ??
                                  0.0;
                              final calculatedBalance =
                                  (qty * basePrice) / 1000.0;

                              return Card(
                                elevation: 1.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Divider(height: 16),

                                      // 💡 1. 평가액 직접 입력 OR (좌수 * 기준가 계산)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _quantityControllers[key],
                                              enabled:
                                                  !hasWithdrawal, // 환매액 입력 시 계산불가 배제
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: '보유 좌수',
                                                border:
                                                    const OutlineInputBorder(),
                                                isDense: true,
                                                filled: hasWithdrawal,
                                                fillColor: Colors.grey.shade100,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _basePriceControllers[key],
                                              enabled: !hasWithdrawal,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: '기준가 (1000좌당)',
                                                border:
                                                    const OutlineInputBorder(),
                                                isDense: true,
                                                filled: hasWithdrawal,
                                                fillColor: Colors.grey.shade100,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (calculatedBalance > 0) ...[
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '좌수 산출 평가액: ${calculatedBalance.toWon()}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.teal.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _balanceControllers[key],
                                              enabled: !hasQuantityOrBasePrice,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: '당월 평가액 (직접입력)',
                                                suffixText: '원',
                                                border:
                                                    const OutlineInputBorder(),
                                                isDense: true,
                                                filled: hasQuantityOrBasePrice,
                                                fillColor: Colors.grey.shade100,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 💡 2. 당월 환매액 필드 (좌수/기준가와 상호 배타)
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _withdrawalControllers[key],
                                              enabled:
                                                  !hasQuantityOrBasePrice, // 좌수/기준가 입력 시 환매액 입력 불가
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: '당월 환매액',
                                                hintText: '0',
                                                suffixText: '원',
                                                border:
                                                    const OutlineInputBorder(),
                                                isDense: true,
                                                filled: hasQuantityOrBasePrice,
                                                fillColor: Colors.grey.shade100,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (hasQuantityOrBasePrice &&
                                          hasWithdrawal) ...[
                                        const SizedBox(height: 4),
                                        const Text(
                                          '⚠️ 좌수/기준가와 당월 환매액은 동시에 입력할 수 없습니다.',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _principalControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '누적 원금',
                                                suffixText: '원',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _payoutControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '누적 연금 수령액',
                                                hintText: '0',
                                                suffixText: '원',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBalances,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('저장하기', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBalances() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAccountId == null) return;

    final pensionNotifier = ref.read(
      monthlyPensionBalanceNotifierProvider(_selectedYearMonth).notifier,
    );
    final accountBalanceNotifier = ref.read(
      monthlyPensionAccountBalanceNotifierProvider(_selectedYearMonth).notifier,
    );

    // 1. 계좌 요약 테이블 저장
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final prevAccountBalances =
        ref
            .read(monthlyPensionAccountBalanceNotifierProvider(prevYearMonth))
            .value ??
        [];

    final prevAccountBalance = prevAccountBalances.firstWhereOrNull(
      (b) => b.accountId == _selectedAccountId,
    );
    final prevTotalWithdrawal = prevAccountBalance?.totalWithdrawal ?? 0.0;

    final accountCashBalance =
        double.tryParse(
          _accountCashBalanceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;
    final currentMonthlyWithdrawal =
        double.tryParse(
          _accountMonthlyWithdrawalController.text.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ),
        ) ??
        0.0;
    final finalTotalWithdrawal = prevTotalWithdrawal + currentMonthlyWithdrawal;

    final accountBalanceItem = MonthlyPensionAccountBalance(
      yearMonth: _selectedYearMonth,
      accountId: _selectedAccountId!,
      cashBalance: accountCashBalance,
      monthlyWithdrawal: currentMonthlyWithdrawal,
      totalWithdrawal: finalTotalWithdrawal,
    );
    await accountBalanceNotifier.saveBalance(accountBalanceItem);

    // 2. 상품별 월말 데이터 파싱 및 DB 저장
    final holdingProducts =
        ref.read(pensionHoldingProductNotifierProvider).value ?? [];
    final Map<String, _GroupedPensionItem> groupedMap = {};

    final prevBalances =
        ref.read(monthlyPensionBalanceNotifierProvider(prevYearMonth)).value ??
        [];
    final prevBalanceMap = {
      for (var b in prevBalances) '${b.accountId}_${b.productId}': b,
    };

    final matchedHoldings =
        holdingProducts
            .where((hp) => hp.accountId == _selectedAccountId && hp.isActive)
            .toList();

    for (var hp in matchedHoldings) {
      final prodId = hp.productId;
      final prevData = prevBalanceMap['${hp.accountId}_$prodId'];
      groupedMap[prodId] = _GroupedPensionItem(
        accountId: hp.accountId,
        productId: prodId,
        principal: prevData?.principal ?? 0.0,
      );
    }

    final List<MonthlyPensionBalance> itemsToSave = [];

    for (var entry in groupedMap.entries) {
      final prodId = entry.key;
      final groupItem = entry.value;
      final key = '${_selectedAccountId}_$prodId';

      final qtyCtrl = _quantityControllers[key];
      final basePriceCtrl = _basePriceControllers[key];
      final balCtrl = _balanceControllers[key];
      final prinCtrl = _principalControllers[key];
      final payoutCtrl = _payoutControllers[key];
      final withdrawalCtrl = _withdrawalControllers[key];

      final qty =
          double.tryParse(qtyCtrl?.text.replaceAll(',', '').trim() ?? '') ??
          0.0;
      final basePrice =
          double.tryParse(
            basePriceCtrl?.text.replaceAll(',', '').trim() ?? '',
          ) ??
          0.0;

      double finalBalance = 0.0;
      if (qty > 0 && basePrice > 0) {
        // 좌수 * 기준가 / 1000 계산 결과 적용
        finalBalance = (qty * basePrice) / 1000.0;
      } else {
        // 직접 입력된 평가액 적용
        finalBalance =
            double.tryParse(balCtrl?.text.replaceAll(',', '').trim() ?? '') ??
            0.0;
      }

      final prinVal =
          double.tryParse(prinCtrl?.text.replaceAll(',', '').trim() ?? '') ??
          groupItem.principal;
      final payoutVal =
          double.tryParse(payoutCtrl?.text.replaceAll(',', '').trim() ?? '') ??
          0.0;
      final withdrawalVal =
          double.tryParse(
            withdrawalCtrl?.text.replaceAll(',', '').trim() ?? '',
          ) ??
          0.0;

      if (finalBalance > 0 || withdrawalVal > 0 || prinVal > 0) {
        itemsToSave.add(
          MonthlyPensionBalance(
            yearMonth: _selectedYearMonth,
            accountId: _selectedAccountId!,
            productId: prodId,
            balance: finalBalance,
            principal: prinVal,
            totalPayout: payoutVal,
            totalWithdrawal: withdrawalVal, // 💡 DB에는 최종 계산된 당월 환매액만 저장
          ),
        );
      }
    }

    if (itemsToSave.isNotEmpty) {
      await pensionNotifier.saveBatchBalances(itemsToSave);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
