import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/number_formatter.dart';
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
  late TextEditingController _purchaseDateController; // 💡 상품 매수일 컨트롤러
  late TextEditingController _amountController;
  late TextEditingController _memoController;

  String? _selectedAccountId;
  String? _selectedProductId;
  String? _transactionTypeId;

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;

    _dateController = TextEditingController(
      text: item?.transactionDate ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    
    // 💡 기존에 저장된 상품 매수일이 있거나, 없으면 오늘 날짜 기본값
    _purchaseDateController = TextEditingController(
      text: item?.purchaseDate ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    _amountController = TextEditingController(
      text: item?.amount != null ? item!.amount.toCommaString() : '',
    );
    _memoController = TextEditingController(text: item?.memo ?? '');

    if (item != null) {
      _selectedAccountId = item.accountId;
      _selectedProductId = item.productId;
      _transactionTypeId = item.transactionTypeId;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _purchaseDateController.dispose();
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

  Future<void> _selectPurchaseDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_purchaseDateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final cleanAmountText = _amountController.text.replaceAll(',', '').trim();
    final parsedAmount = double.tryParse(cleanAmountText) ?? 0.0;

    final types = ref.read(pensionTransactionTypeNotifierProvider).value ?? [];
    final selectedType = types.firstWhereOrNull((t) => t.id == _transactionTypeId);
    final isBuyType = selectedType?.typeName.contains('매수') ?? false;

    final isEdit = widget.transaction != null;
    
    // 💡 수기 등록 시 현재 시간 기반의 밀리초를 sortOrder로 사용하여 가장 최신(마지막) 순서로 배치
    final assignedSortOrder = isEdit 
        ? widget.transaction!.sortOrder 
        : DateTime.now().millisecondsSinceEpoch;

    final transactionData = PensionTransaction(
      id: widget.transaction?.id,
      transactionDate: _dateController.text,
      accountId: _selectedAccountId!,
      productId: _selectedProductId,
      transactionTypeId: _transactionTypeId!,
      amount: parsedAmount,
      memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
      purchaseDate: isBuyType ? _purchaseDateController.text : null,
      sortOrder: assignedSortOrder, // 💡 정렬 순서 할당
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
                    final initialType =
                        types.any((t) => t.id == _transactionTypeId)
                            ? _transactionTypeId
                            : (types.isNotEmpty ? types.first.id : null);

                    if (_transactionTypeId == null && initialType != null) {
                      _transactionTypeId = initialType;
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: initialType,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: '거래구분 *'),
                      hint: const Text('거래구분 선택'),
                      items: types
                          .map(
                            (type) => DropdownMenuItem(
                              value: type.id,
                              child: Text(
                                type.typeName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _transactionTypeId = val);
                        }
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? '거래구분을 선택해주세요.' : null,
                    );
                  },
                ),

                // 💡 거래구분이 '매수'일 때만 노출되는 '상품 매수일' 입력 필드
                transactionTypesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (types) {
                    final selectedType = types.firstWhereOrNull(
                      (t) => t.id == _transactionTypeId,
                    );
                    final isBuyType =
                        selectedType?.typeName.contains('매수') ?? false;

                    if (!isBuyType) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        controller: _purchaseDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: '상품 매수일',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: _selectPurchaseDate,
                        validator: (val) =>
                            isBuyType && (val == null || val.isEmpty)
                                ? '상품 매수일을 선택해주세요.'
                                : null,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

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