import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/number_formatter.dart';
import '../../../../models/monthly_data/monthly_stock_balance.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/monthly_data/monthly_stock_balance_provider.dart';
import '../../../../providers/stock/stock_holding_item_provider.dart';
import '../../../../providers/stock/stock_item_provider.dart';

class MonthlyStockBalanceDialog extends ConsumerStatefulWidget {
  final String yearMonth; // 대상 년월 (예: '2026-10')
  final MonthlyStockBalance? initialData; // 수정 시 기존 데이터

  const MonthlyStockBalanceDialog({
    super.key,
    required this.yearMonth,
    this.initialData,
  });

  @override
  ConsumerState<MonthlyStockBalanceDialog> createState() =>
      _MonthlyStockBalanceDialogState();
}

class _MonthlyStockBalanceDialogState
    extends ConsumerState<MonthlyStockBalanceDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedAccountId;
  String? _selectedStockItemId;

  late TextEditingController _quantityController;
  late TextEditingController _currentPriceController;
  late TextEditingController _principalController;
  late TextEditingController _payoutController;
  late TextEditingController _withdrawalController;

  bool _isSubmitting = false;
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialData?.accountId;
    _selectedStockItemId = widget.initialData?.stockItemId;

    _quantityController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.quantity > 0
          ? widget.initialData!.quantity.toString()
          : '',
    );
    _currentPriceController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.currentPrice > 0
          ? widget.initialData!.currentPrice.toCommaString()
          : '',
    );
    _principalController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.principal > 0
          ? widget.initialData!.principal.toCommaString()
          : '',
    );
    _payoutController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.totalPayout > 0
          ? widget.initialData!.totalPayout.toCommaString()
          : '',
    );
    _withdrawalController = TextEditingController(
      text: widget.initialData != null && widget.initialData!.totalWithdrawal > 0
          ? widget.initialData!.totalWithdrawal.toCommaString()
          : '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _currentPriceController.dispose();
    _principalController.dispose();
    _payoutController.dispose();
    _withdrawalController.dispose();
    super.dispose();
  }

  // 💡 수량 × 현재가로 평가액 자동 계산 미리보기 또는 반영
  double _calculateBalance() {
    final cleanQty = _quantityController.text.replaceAll(',', '').trim();
    final cleanPrice = _currentPriceController.text.replaceAll(',', '').trim();
    final qty = double.tryParse(cleanQty) ?? 0.0;
    final price = double.tryParse(cleanPrice) ?? 0.0;
    return qty * price;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedStockItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계좌와 종목을 모두 선택해 주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final qty = double.tryParse(_quantityController.text.replaceAll(',', '').trim()) ?? 0.0;
      final price = double.tryParse(_currentPriceController.text.replaceAll(RegExp(r'[^0-9.]'), '').trim()) ?? 0.0;
      final principal = double.tryParse(_principalController.text.replaceAll(RegExp(r'[^0-9]'), '').trim()) ?? 0.0;
      final payout = double.tryParse(_payoutController.text.replaceAll(RegExp(r'[^0-9]'), '').trim()) ?? 0.0;
      final withdrawal = double.tryParse(_withdrawalController.text.replaceAll(RegExp(r'[^0-9]'), '').trim()) ?? 0.0;

      // 평가액 자동 산출 (수량 × 현재가)
      final balance = qty * price;

      final item = MonthlyStockBalance(
        id: widget.initialData?.id,
        yearMonth: widget.yearMonth,
        accountId: _selectedAccountId!,
        stockItemId: _selectedStockItemId!,
        quantity: qty,
        currentPrice: price,
        balance: balance,
        principal: principal,
        totalPayout: payout,
        totalWithdrawal: withdrawal,
        purchaseDate: widget.initialData?.purchaseDate, // 기존 매수일 유지 또는 프로바이더가 보완
      );

      final notifier = ref.read(monthlyStockBalanceNotifierProvider(widget.yearMonth).notifier);
      await notifier.saveBalance(item);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final holdingItemsAsync = ref.watch(stockHoldingItemNotifierProvider);
    final accountsAsync = ref.watch(accountNotifierProvider);
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final stockItemsAsync = ref.watch(stockItemNotifierProvider);

    return AlertDialog(
      title: Text('${widget.yearMonth} 주식 월말 평가 입력'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 안내 박스
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: const Text(
                    '💡 안내: 해당 월 말일 기준의 보유 수량과 주당 현재가를 입력하면 평가액이 자동으로 계산됩니다.',
                    style: TextStyle(fontSize: 12, color: Colors.indigoAccent),
                  ),
                ),
                const SizedBox(height: 16),

                // 1. 계좌 선택
                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('계좌 로딩 실패: $err'),
                  data: (accounts) {
                    final accountNames = accountNamesAsync.value ?? [];
                    final accountNameMap = {for (var an in accountNames) an.id: an};
                    final activeAccounts = accounts.where((a) => a.status == '활동').toList();

                    if (_selectedAccountId == null && activeAccounts.isNotEmpty) {
                      _selectedAccountId = activeAccounts.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: '계좌 선택',
                        border: OutlineInputBorder(),
                      ),
                      items: activeAccounts.map((acc) {
                        final nameObj = accountNameMap[acc.accountNameId];
                        return DropdownMenuItem(
                          value: acc.id,
                          child: Text('${acc.financialInstitution} - ${nameObj?.accountName ?? '계좌'}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. 종목 선택
                stockItemsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('종목 로딩 실패: $err'),
                  data: (stockItems) {
                    if (stockItems.isEmpty) {
                      return const Text('등록된 종목이 없습니다.');
                    }

                    if (_selectedStockItemId == null && stockItems.isNotEmpty) {
                      _selectedStockItemId = stockItems.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedStockItemId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '종목 선택',
                        border: OutlineInputBorder(),
                      ),
                      items: stockItems.map((stock) {
                        return DropdownMenuItem(
                          value: stock.id,
                          child: Text('${stock.name} (${stock.symbolCode})', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedStockItemId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. 보유 수량 & 현재가 입력 (Row 배치)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '보유 수량',
                          suffixText: '주',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return '수량 입력';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _currentPriceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: '주당 현재가',
                          suffixText: '원',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return '현재가 입력';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 자동 계산되는 평가액 미리보기
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    '🧮 산출 평가액: ${_calculateBalance().toCommaString()} 원',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. 누적 투자 원금
                TextFormField(
                  controller: _principalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: '누적 투자 원금',
                    suffixText: '원',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '누적 원금을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 5. 누적 배당금 및 인출액 (선택 사항)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _payoutController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: '누적 배당금 (선택)',
                          suffixText: '원',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _withdrawalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: '누적 인출액 (선택)',
                          suffixText: '원',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? '수정' : '저장'),
        ),
      ],
    );
  }
}