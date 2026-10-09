import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 💡 FilteringTextInputFormatter 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart'; // 💡 첨부해주신 포맷터 파일 import
import '../../../../models/pension/pension_transaction.dart';
import '../../../../providers/account/account_name_provider.dart';
import '../../../../providers/account/account_provider.dart';
import '../../../../providers/pension/pension_product_provider.dart';
import '../../../../providers/pension/pension_transaction_provider.dart';
import '../../../../providers/pension/pension_transaction_type_provider.dart';

class PensionTransactionDialog extends ConsumerStatefulWidget {
  final PensionTransaction? transaction;

  const PensionTransactionDialog({super.key, this.transaction});

  @override
  ConsumerState<PensionTransactionDialog> createState() =>
      _PensionTransactionDialogState();
}

class _PensionTransactionDialogState
    extends ConsumerState<PensionTransactionDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;

  String? _selectedAccountId;
  String? _selectedProductId;
  String? _transactionType;

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;

    _dateController = TextEditingController(
      text: item?.transactionDate ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    
    // 💡 초기 금액 표시 시 콤마 포맷팅 적용
    _amountController = TextEditingController(
      text: item?.amount != null ? item!.amount.toCommaString() : '',
    );
    _memoController = TextEditingController(text: item?.memo ?? '');

    if (item != null) {
      _selectedAccountId = item.accountId;
      _selectedProductId = item.productId;
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

    final accounts = ref.read(accountNotifierProvider).value ?? [];
    final matchedAccount = accounts.firstWhereOrNull(
      (a) => a.id == _selectedAccountId,
    );

    // 💡 콤마(,) 제거 후 숫자 변환
    final cleanAmountText = _amountController.text.replaceAll(',', '').trim();
    final parsedAmount = double.tryParse(cleanAmountText) ?? 0.0;

    final isEdit = widget.transaction != null;
    final transactionData = PensionTransaction(
      id: widget.transaction?.id,
      transactionDate: _dateController.text,
      financialInstitution: matchedAccount?.financialInstitution,
      accountId: _selectedAccountId!,
      productId: _selectedProductId,
      transactionType: _transactionType!,
      amount: parsedAmount,
      memo: _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim(),
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
    final accountNamesAsync = ref.watch(accountNameNotifierProvider);
    final transactionTypesAsync =
        ref.watch(pensionTransactionTypeNotifierProvider);
    final productsAsync = ref.watch(pensionProductNotifierProvider);

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? '연금 거래내역 수정' : '연금 거래내역 등록',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '거래일자',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _selectDate,
                  validator: (val) =>
                      val == null || val.isEmpty ? '날짜를 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),

                accountsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text(
                    '계좌 로딩 실패: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (accounts) {
                    final pensionAccounts = accounts
                        .where((a) => a.accountType.toUpperCase() == '연금')
                        .toList();

                    final accountNames = accountNamesAsync.value ?? [];
                    final accountNameMap = {
                      for (var an in accountNames) an.id: an,
                    };

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAccountId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: '연금 계좌명 *'),
                      hint: const Text('연금 계좌 선택'),
                      items: pensionAccounts.map((acc) {
                        final matchedName = accountNameMap[acc.accountNameId];
                        final displayName = matchedName?.accountName ?? '계좌';

                        return DropdownMenuItem(
                          value: acc.id,
                          child: Text(
                            '${acc.financialInstitution} - $displayName',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountId = val;
                        });
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? '계좌를 선택해주세요.' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text(
                    '상품 로딩 실패: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (products) {
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedProductId,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: '연금 상품명 (선택)'),
                      hint: const Text('상품 선택 (입출금일 경우 미선택가능)'),
                      items: products
                          .map(
                            (prod) => DropdownMenuItem(
                              value: prod.id,
                              child: Text(
                                prod.productName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedProductId = val),
                    );
                  },
                ),
                const SizedBox(height: 12),

                transactionTypesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text(
                    '거래구분 로딩 실패: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (types) {
                    final activeTypes =
                        types.where((t) => t.isActive).toList();

                    final initialType = activeTypes.any(
                      (t) => t.name == _transactionType,
                    )
                        ? _transactionType
                        : (activeTypes.isNotEmpty ? activeTypes.first.name : null);

                    if (_transactionType == null && initialType != null) {
                      _transactionType = initialType;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: initialType,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: '거래구분 *'),
                      hint: const Text('거래구분 선택'),
                      items: activeTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type.name,
                              child: Text(
                                type.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _transactionType = val);
                        }
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? '거래구분을 선택해주세요.' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 💡 천 단위 콤마 포맷터(ThousandsSeparatorInputFormatter) 적용
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: '금액 *',
                    suffixText: '원',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return '금액을 입력해주세요.';
                    }
                    final cleanVal = val.replaceAll(',', '').trim();
                    if (double.tryParse(cleanVal) == null) {
                      return '올바른 숫자를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _memoController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: '메모'),
                ),
                const SizedBox(height: 24),

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