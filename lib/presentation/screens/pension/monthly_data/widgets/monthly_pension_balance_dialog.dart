import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/number_formatter.dart';
import '../../../../../core/utils/responsive_extension.dart';
import '../../../../../core/widgets/app_snackbar.dart';
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
  final MonthlyPensionBalance? editItem;

  const MonthlyPensionBalanceDialog({
    super.key,
    required this.yearMonth,
    this.editItem,
  });

  @override
  ConsumerState<MonthlyPensionBalanceDialog> createState() =>
      _MonthlyPensionBalanceDialogState();
}

class _MonthlyPensionBalanceDialogState
    extends ConsumerState<MonthlyPensionBalanceDialog> {
  late String _selectedYearMonth;
  String? _selectedAccountId;

  final Map<String, TextEditingController> _balanceControllers = {};
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _basePriceControllers = {};
  final Map<String, TextEditingController> _monthlyPrincipalControllers = {};
  final Map<String, TextEditingController> _monthlySaleControllers = {};

  final TextEditingController _accountCashBalanceController =
      TextEditingController();
  final TextEditingController _accountMonthlyPrincipalController =
      TextEditingController();
  final TextEditingController _accountMonthlyWithdrawalController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    _selectedYearMonth = widget.editItem?.yearMonth ?? widget.yearMonth;
    _selectedAccountId = widget.editItem?.accountId;
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
    for (var c in _monthlyPrincipalControllers.values) {
      c.dispose();
    }
    for (var c in _monthlySaleControllers.values) {
      c.dispose();
    }
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, context.bottomInset + 20),
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
                  Text(
                    _isEditing ? '연금 월말 내역 수정' : '연금 월말 평가액/입금액 일괄 입력',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                readOnly: _isEditing,
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
                  if (_isEditing) return;
                  setState(() {
                    _selectedYearMonth = val.trim();
                  });
                },
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? '기준월을 입력해주세요.'
                            : null,
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
                      _isEditing
                          ? accounts
                              .where((a) => a.id == widget.editItem!.accountId)
                              .toList()
                          : accounts
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
                        onChanged:
                            _isEditing
                                ? null
                                : (val) {
                                  setState(() {
                                    _selectedAccountId = val;
                                    _accountCashBalanceController.clear();
                                    _accountMonthlyPrincipalController.clear();
                                    _accountMonthlyWithdrawalController
                                        .clear();
                                  });
                                },
                      ),
                      const SizedBox(height: 16),

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
                                  Expanded(
                                    child: Text(
                                      '계좌 공통 현금성 자산 및 입금/인출 관리',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.teal.shade900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                        labelText: '당월 계좌 인출액 (중도인출·연금지급)',
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
                              holdingProducts.where((hp) {
                                final matchesAccount =
                                    hp.accountId == _selectedAccountId &&
                                    hp.isActive;
                                if (_isEditing) {
                                  return matchesAccount &&
                                      hp.productId == widget.editItem!.productId;
                                }
                                return matchesAccount;
                              }).toList();

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
                                final isTargetEdit =
                                    _isEditing &&
                                    widget.editItem!.productId == prodId;

                                final currentBal =
                                    isTargetEdit
                                        ? widget.editItem!.balance
                                        : (currentData != null &&
                                                currentData.balance > 0)
                                            ? currentData.balance
                                            : (prevData?.balance ?? 0.0);

                                final currentMonthlyPrin =
                                    isTargetEdit
                                        ? widget.editItem!.monthlyPrincipal
                                        : (currentData?.monthlyPrincipal ??
                                            0.0);
                                final currentMonthlySale =
                                    isTargetEdit
                                        ? widget.editItem!.monthlySale
                                        : (currentData?.monthlySale ?? 0.0);

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
                                _monthlySaleControllers[key] =
                                    TextEditingController(
                                      text:
                                          currentMonthlySale > 0
                                              ? currentMonthlySale
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

                              final hasSale =
                                  (_monthlySaleControllers[key]?.text
                                          .trim()
                                          .isNotEmpty ??
                                      false) &&
                                  (double.tryParse(
                                            _monthlySaleControllers[key]!
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
                                              enabled: !hasSale,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: '보유 좌수',
                                                border:
                                                    const OutlineInputBorder(),
                                                isDense: true,
                                                filled: hasSale,
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
                                              enabled: !hasSale,
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText: '기준가 (1000좌당)',
                                                border:
                                                    const OutlineInputBorder(),
                                                isDense: true,
                                                filled: hasSale,
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
                                                  _monthlySaleControllers[key],
                                              enabled: !hasQuantityOrBasePrice,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                ThousandsSeparatorInputFormatter(),
                                              ],
                                              decoration: InputDecoration(
                                                labelText: '당월 매도액 (환매액)',
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
                  child: Text(
                    _isEditing ? '수정하기' : '저장하기',
                    style: const TextStyle(fontSize: 16),
                  ),
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

    try {
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

      final finalAccountPrincipal =
          prevAccountPrincipal + currentMonthlyPrincipal;
      final finalTotalWithdrawal =
          prevTotalWithdrawal + currentMonthlyWithdrawal;

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

      final holdingProducts =
          ref.read(pensionHoldingProductNotifierProvider).value ?? [];

      final prevBalances =
          ref.read(monthlyPensionBalanceNotifierProvider(prevYearMonth)).value ??
          [];
      final prevBalanceMap = {
        for (var b in prevBalances) '${b.accountId}_${b.productId}': b,
      };

      final matchedHoldings =
          holdingProducts.where((hp) {
            final matchesAccount =
                hp.accountId == _selectedAccountId && hp.isActive;
            if (_isEditing) {
              return matchesAccount && hp.productId == widget.editItem!.productId;
            }
            return matchesAccount;
          }).toList();

      final List<MonthlyPensionBalance> itemsToSave = [];

      for (var hp in matchedHoldings) {
        final prodId = hp.productId;
        final key = '${_selectedAccountId}_$prodId';
        final prevData = prevBalanceMap[key];
        final isTargetEdit =
            _isEditing && widget.editItem!.productId == prodId;

        final qtyCtrl = _quantityControllers[key];
        final basePriceCtrl = _basePriceControllers[key];
        final balCtrl = _balanceControllers[key];
        final monthlyPrinCtrl = _monthlyPrincipalControllers[key];
        final monthlySaleCtrl = _monthlySaleControllers[key];

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
              (isTargetEdit
                  ? widget.editItem!.balance
                  : (prevData?.balance ?? 0.0));
        }

        final monthlyPrinVal =
            double.tryParse(
              monthlyPrinCtrl?.text.replaceAll(',', '').trim() ?? '',
            ) ??
            0.0;
        final monthlySaleVal =
            double.tryParse(
              monthlySaleCtrl?.text.replaceAll(',', '').trim() ?? '',
            ) ??
            0.0;

        final basePrincipal =
            isTargetEdit
                ? (widget.editItem!.principal -
                    widget.editItem!.monthlyPrincipal)
                : (prevData?.principal ?? 0.0);
        final baseTotalSale =
            isTargetEdit
                ? (widget.editItem!.totalSale - widget.editItem!.monthlySale)
                : (prevData?.totalSale ?? 0.0);

        final finalPrincipal = basePrincipal + monthlyPrinVal;
        final finalTotalSale = baseTotalSale + monthlySaleVal;

        if (finalBalance > 0 ||
            monthlySaleVal > 0 ||
            monthlyPrinVal > 0 ||
            finalPrincipal > 0) {
          itemsToSave.add(
            MonthlyPensionBalance(
              id: isTargetEdit ? widget.editItem!.id : null,
              yearMonth: _selectedYearMonth,
              accountId: _selectedAccountId!,
              productId: prodId,
              balance: finalBalance,
              principal: finalPrincipal,
              monthlyPrincipal: monthlyPrinVal,
              totalSale: finalTotalSale,
              monthlySale: monthlySaleVal,
            ),
          );
        }
      }

      if (itemsToSave.isNotEmpty) {
        await pensionNotifier.saveBatchBalances(itemsToSave);
      }

      if (!mounted) return;
      Navigator.pop(context);
      AppSnackBar.showInfo(
        context,
        _isEditing ? '연금 월말 내역이 수정되었습니다.' : '연금 월말 평가액이 성공적으로 저장되었습니다.',
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, '저장 실패: $e');
    }
  }
}