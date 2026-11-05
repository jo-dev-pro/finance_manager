import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../models/monthly_data/monthly_pension_account_balance.dart';
import '../../../../../models/monthly_data/monthly_pension_balance.dart';
import '../../../../../providers/account/account_name_provider.dart';
import '../../../../../providers/account/account_provider.dart';
import '../../../../../providers/monthly_data/monthly_pension_account_balance_provider.dart';
import '../../../../../providers/monthly_data/monthly_pension_balance_provider.dart';
import '../../../../../providers/pension/pension_holding_product_provider.dart';
import '../../../../../providers/pension/pension_product_provider.dart';

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

  // 상품별 평가액 입력 컨트롤러
  final Map<String, TextEditingController> _balanceControllers = {};
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _basePriceControllers = {};

  // 상품별 당월분 입력 컨트롤러들
  final Map<String, TextEditingController> _monthlyPrincipalControllers = {};
  final Map<String, TextEditingController> _monthlyPayoutControllers = {};
  final Map<String, TextEditingController> _monthlyWithdrawalControllers = {};

  // 계좌 공통 입력 컨트롤러 (예수금, 당월 입금액, 당월 인출액)
  final TextEditingController _accountCashBalanceController =
      TextEditingController();
  final TextEditingController _accountMonthlyPrincipalController =
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
    for (var c in _balanceControllers.values) { c.dispose(); }
    for (var c in _quantityControllers.values) { c.dispose(); }
    for (var c in _basePriceControllers.values) { c.dispose(); }
    for (var c in _monthlyPrincipalControllers.values) { c.dispose(); }
    for (var c in _monthlyPayoutControllers.values) { c.dispose(); }
    for (var c in _monthlyWithdrawalControllers.values) { c.dispose(); }
    _accountCashBalanceController.dispose();
    _accountMonthlyPrincipalController.dispose();
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
                    '연금 월말 평가액/입금액 일괄 입력',
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

                  if (_accountMonthlyPrincipalController.text.isEmpty &&
                      currentAccData != null &&
                      currentAccData.monthlyPrincipal > 0) {
                    _accountMonthlyPrincipalController.text =
                        currentAccData.monthlyPrincipal.toCommaString();
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
                            _accountMonthlyPrincipalController.clear();
                            _accountMonthlyWithdrawalController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 상단 계좌 공통 정보 카드 (예수금, 당월 입금액, 당월 인출액)
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
                                    '계좌 공통 현금성 자산 및 입금/인출 관리',
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
                                          _accountMonthlyPrincipalController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: '당월 계좌 입금액',
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
                              const SizedBox(height: 10),
                              Row(
                                children: [
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

                      const Text(
                        '보유 상품별 상세 입력',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

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

                          final currentBalances =
                              existingCurrentBalancesAsync.value ?? [];
                          final prevBalances =
                              existingPrevBalancesAsync.value ?? [];

                          final currentBalanceMap = {
                            for (var b in currentBalances)
                              '${b.accountId}_${b.productId}': b,
                          };

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

                          if (matchedHoldings.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('해당 연금 계좌에 등록된 보유 상품이 없습니다.'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matchedHoldings.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final hp = matchedHoldings[index];
                              final prodId = hp.productId;
                              final productName =
                                  productMap[prodId] ?? '알 수 없는 상품';

                              final key = '${_selectedAccountId}_$prodId';
                              final currentData = currentBalanceMap[key];
                              final prevData = prevBalanceMap[key];

                              if (!_balanceControllers.containsKey(key)) {
                                final currentBal =
                                    (currentData != null &&
                                            currentData.balance > 0)
                                        ? currentData.balance
                                        : (prevData?.balance ?? 0.0);

                                final currentMonthlyPrin =
                                    currentData?.monthlyPrincipal ?? 0.0;
                                final currentMonthlyPayout =
                                    currentData?.monthlyPayout ?? 0.0;
                                final currentMonthlyWithdrawal =
                                    currentData?.monthlyWithdrawal ?? 0.0;

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

                                _monthlyPrincipalControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentMonthlyPrin > 0
                                              ? currentMonthlyPrin
                                                  .toCommaString()
                                              : '',
                                    );
                                _monthlyPayoutControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentMonthlyPayout > 0
                                              ? currentMonthlyPayout
                                                  .toCommaString()
                                              : '',
                                    );
                                _monthlyWithdrawalControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentMonthlyWithdrawal > 0
                                              ? currentMonthlyWithdrawal
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
                                  (_monthlyWithdrawalControllers[key]?.text
                                          .trim()
                                          .isNotEmpty ??
                                      false) &&
                                  (double.tryParse(
                                            _monthlyWithdrawalControllers[key]!
                                                .text
                                                .replaceAll(
                                                  RegExp(r'[^0-9]'),
                                                  '',
                                                ),
                                          ) ??
                                          0) >
                                      0;

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

                              final prevPrincipal = prevData?.principal ?? 0.0;

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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (prevPrincipal > 0)
                                            Text(
                                              '전월 누적원금: ${prevPrincipal.toWon()}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _quantityControllers[key],
                                              enabled: !hasWithdrawal,
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
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _monthlyWithdrawalControllers[key],
                                              enabled: !hasQuantityOrBasePrice,
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
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _monthlyPrincipalControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '당월 입금액 (추가원금)',
                                                hintText: '0',
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
                                                  _monthlyPayoutControllers[key],
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: const InputDecoration(
                                                labelText: '당월 연금 수령액',
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

    // 1. 계좌 요약 테이블 저장 (전월 누적원금 + 당월 입금액 연동)
    final prevYearMonth = _getPreviousYearMonth(_selectedYearMonth);
    final prevAccountBalances =
        ref
            .read(monthlyPensionAccountBalanceNotifierProvider(prevYearMonth))
            .value ??
        [];

    final prevAccountBalance = prevAccountBalances.firstWhereOrNull(
      (b) => b.accountId == _selectedAccountId,
    );
    final prevAccountPrincipal = prevAccountBalance?.principal ?? 0.0;
    final prevTotalWithdrawal = prevAccountBalance?.totalWithdrawal ?? 0.0;

    final accountCashBalance =
        double.tryParse(
          _accountCashBalanceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0.0;
    final currentMonthlyPrincipal =
        double.tryParse(
          _accountMonthlyPrincipalController.text.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ),
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

    final finalAccountPrincipal = prevAccountPrincipal + currentMonthlyPrincipal;
    final finalTotalWithdrawal = prevTotalWithdrawal + currentMonthlyWithdrawal;

    final accountBalanceItem = MonthlyPensionAccountBalance(
      yearMonth: _selectedYearMonth,
      accountId: _selectedAccountId!,
      cashBalance: accountCashBalance,
      principal: finalAccountPrincipal,
      monthlyPrincipal: currentMonthlyPrincipal,
      monthlyWithdrawal: currentMonthlyWithdrawal,
      totalWithdrawal: finalTotalWithdrawal,
    );
    await accountBalanceNotifier.saveBalance(accountBalanceItem);

    // 2. 상품별 월말 데이터 파싱 및 누적금액 계산 후 저장
    final holdingProducts =
        ref.read(pensionHoldingProductNotifierProvider).value ?? [];

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

    final List<MonthlyPensionBalance> itemsToSave = [];

    for (var hp in matchedHoldings) {
      final prodId = hp.productId;
      final key = '${_selectedAccountId}_$prodId';
      final prevData = prevBalanceMap[key];

      final qtyCtrl = _quantityControllers[key];
      final basePriceCtrl = _basePriceControllers[key];
      final balCtrl = _balanceControllers[key];
      final monthlyPrinCtrl = _monthlyPrincipalControllers[key];
      final monthlyPayoutCtrl = _monthlyPayoutControllers[key];
      final monthlyWithdrawalCtrl = _monthlyWithdrawalControllers[key];

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
        finalBalance = (qty * basePrice) / 1000.0;
      } else {
        finalBalance =
            double.tryParse(balCtrl?.text.replaceAll(',', '').trim() ?? '') ??
            (prevData?.balance ?? 0.0);
      }

      final monthlyPrinVal =
          double.tryParse(
            monthlyPrinCtrl?.text.replaceAll(',', '').trim() ?? '',
          ) ??
          0.0;
      final monthlyPayoutVal =
          double.tryParse(
            monthlyPayoutCtrl?.text.replaceAll(',', '').trim() ?? '',
          ) ??
          0.0;
      final monthlyWithdrawalVal =
          double.tryParse(
            monthlyWithdrawalCtrl?.text.replaceAll(',', '').trim() ?? '',
          ) ??
          0.0;

      final prevPrincipal = prevData?.principal ?? 0.0;
      final prevTotalPayout = prevData?.totalPayout ?? 0.0;
      final prevTotalWithdrawalProd = prevData?.totalWithdrawal ?? 0.0;

      final finalPrincipal = prevPrincipal + monthlyPrinVal;
      final finalTotalPayout = prevTotalPayout + monthlyPayoutVal;
      final finalTotalWithdrawalProd =
          prevTotalWithdrawalProd + monthlyWithdrawalVal;

      if (finalBalance > 0 ||
          monthlyWithdrawalVal > 0 ||
          monthlyPrinVal > 0 ||
          finalPrincipal > 0) {
        itemsToSave.add(
          MonthlyPensionBalance(
            yearMonth: _selectedYearMonth,
            accountId: _selectedAccountId!,
            productId: prodId,
            balance: finalBalance,
            principal: finalPrincipal,
            monthlyPrincipal: monthlyPrinVal,
            totalPayout: finalTotalPayout,
            monthlyPayout: monthlyPayoutVal,
            totalWithdrawal: finalTotalWithdrawalProd,
            monthlyWithdrawal: monthlyWithdrawalVal,
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