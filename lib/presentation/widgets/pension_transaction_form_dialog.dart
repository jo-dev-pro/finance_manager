import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/pension_transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/pension_product_provider.dart';
import '../../providers/pension_transaction_provider.dart';


class PensionTransactionFormDialog extends ConsumerStatefulWidget {
  final PensionTransaction? transaction;

  const PensionTransactionFormDialog({super.key, this.transaction});

  @override
  ConsumerState<PensionTransactionFormDialog> createState() =>
      _PensionTransactionFormDialogState();
}

class _PensionTransactionFormDialogState
    extends ConsumerState<PensionTransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;

  String? _selectedAccountName;
  String? _selectedProductName;
  String _transactionType = '입금';

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;

    _dateController = TextEditingController(
      text: item?.transactionDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _amountController = TextEditingController(
      text: item?.amount != null ? item!.amount.toInt().toString() : '',
    );
    _memoController = TextEditingController(text: item?.memo ?? '');

    if (item != null) {
      _selectedAccountName = item.accountName;
      _selectedProductName = item.productName;
      _transactionType = item.transactionType;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.transaction != null;
    final transactionData = PensionTransaction(
      id: widget.transaction?.id,
      transactionDate: _dateController.text,
      accountName: _selectedAccountName!,
      productName: _selectedProductName,
      transactionType: _transactionType,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
    );

    final notifier = ref.read(pensionTransactionNotifierProvider.notifier);
    if (isEdit) {
      await notifier.updateTransaction(transactionData);
    } else {
      await notifier.addTransaction(transactionData);
    }

    if (mounted) Navigator.pop(context);
  }

  void _delete() async {
    if (widget.transaction?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('해당 거래 내역을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(pensionTransactionNotifierProvider.notifier)
          .deleteTransaction(widget.transaction!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    final accountsAsync = ref.watch(accountNotifierProvider);
    final productsAsync = _selectedAccountName != null
        ? ref.watch(pensionProductsByAccountProvider(_selectedAccountName!))
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 다이얼로그 헤더 (타이틀 & 삭제버튼)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? '거래내역 수정' : '거래내역 등록',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (isEdit)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _delete,
                      ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // 1. 거래일자
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '거래일자',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDate,
                  validator: (val) => val == null || val.isEmpty ? '날짜를 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),

                // 2. 계좌명 콤보박스 (계좌구분 == '연금'만 필터링)
                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text('계좌 로딩 실패: $err', style: const TextStyle(color: Colors.red)),
                  data: (accounts) {
                    final pensionAccounts = accounts
                        .where((a) => a.accountType == '연금')
                        .map((a) => a.accountName)
                        .toList();

                    if (_selectedAccountName != null && !pensionAccounts.contains(_selectedAccountName)) {
                      pensionAccounts.add(_selectedAccountName!);
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAccountName,
                      decoration: const InputDecoration(labelText: '계좌명 *'),
                      hint: const Text('연금 계좌 선택'),
                      items: pensionAccounts
                          .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountName = val;
                          _selectedProductName = null;
                        });
                      },
                      validator: (val) => val == null || val.isEmpty ? '계좌를 선택해주세요.' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 3. 상품명 콤보박스 (선택한 계좌 연동)
                if (_selectedAccountName == null)
                   DropdownButtonFormField<String>(
                    onChanged: null,
                    items: [],
                    decoration: InputDecoration(
                      labelText: '상품명',
                      hintText: '계좌를 먼저 선택하세요',
                    ),
                  )
                else
                  productsAsync?.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (err, stack) => Text('상품 로딩 실패: $err', style: const TextStyle(color: Colors.red)),
                        data: (products) {
                          final productNames = products.map((p) => p.productName).toList();

                          if (_selectedProductName != null && !productNames.contains(_selectedProductName)) {
                            productNames.add(_selectedProductName!);
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedProductName,
                            decoration: const InputDecoration(labelText: '상품명'),
                            hint: const Text('상품 선택'),
                            items: productNames
                                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedProductName = val),
                          );
                        },
                      ) ??
                      const SizedBox.shrink(),
                const SizedBox(height: 12),

                // 4. 거래구분 콤보박스
                DropdownButtonFormField<String>(
                  initialValue: _transactionType,
                  decoration: const InputDecoration(labelText: '거래구분'),
                  items: ['입금', '출금', '매수', '매도', '배당/이자']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _transactionType = val);
                  },
                ),
                const SizedBox(height: 12),

                // 5. 금액
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '금액 *',
                    suffixText: '원',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return '금액을 입력해주세요.';
                    if (double.tryParse(val) == null) return '올바른 숫자를 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 6. 메모
                TextFormField(
                  controller: _memoController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: '메모'),
                ),
                const SizedBox(height: 24),

                // 하단 버튼 (취소 / 저장)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: Text(isEdit ? '수정' : '등록'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}