import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_transaction_type.dart';
import '../../providers/stock_transaction_type_provider.dart';

class StockTransactionTypeDialog extends ConsumerStatefulWidget {
  final StockTransactionType? initialData;

  const StockTransactionTypeDialog({super.key, this.initialData});

  @override
  ConsumerState<StockTransactionTypeDialog> createState() => _StockTransactionTypeDialogState();
}

class _StockTransactionTypeDialogState extends ConsumerState<StockTransactionTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeNameController;
  
  // 수량 및 금액 연산자 상태값
  String _selectedQuantitySign = 'PLUS';
  String _selectedAmountSign = 'MINUS';
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  // 선택지 리스트 (증가, 차감, 변동없음)
  final List<String> _signOptions = ['PLUS', 'MINUS', 'ZERO'];

  // 화면 표시용 레이블 맵
  final Map<String, String> _signLabels = {
    'PLUS': '증가 (+)',
    'MINUS': '차감 (-)',
    'ZERO': '변동 없음 (0)',
  };

  @override
  void initState() {
    super.initState();
    _typeNameController = TextEditingController(text: widget.initialData?.typeName ?? '');
    
    if (widget.initialData != null) {
      _selectedQuantitySign = widget.initialData!.quantitySign;
      _selectedAmountSign = widget.initialData!.amountSign;
    }
  }

  @override
  void dispose() {
    _typeNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final stockItem = StockTransactionType(
        id: widget.initialData?.id,
        typeName: _typeNameController.text.trim(),
        quantitySign: _selectedQuantitySign,
        amountSign: _selectedAmountSign,
      );

      final notifier = ref.read(stockTransactionTypeNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateStockTransactionType(stockItem);
      } else {
        await notifier.addStockTransactionType(stockItem);
      }

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
    return AlertDialog(
      title: Text(_isEditing ? '거래구분 수정' : '거래구분 등록'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 거래구분명 입력
              TextFormField(
                controller: _typeNameController,
                decoration: const InputDecoration(
                  labelText: '거래구분명',
                  hintText: '예: 매수, 매도, 무상증자, 배당금',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '거래구분명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. 수량 연산자 선택
              DropdownButtonFormField<String>(
                value: _signOptions.contains(_selectedQuantitySign)
                    ? _selectedQuantitySign
                    : 'PLUS',
                decoration: const InputDecoration(
                  labelText: '수량 연산',
                  helperText: '거래 발생 시 주식 수량 변동방식',
                ),
                items: _signOptions.map((sign) {
                  return DropdownMenuItem(
                    value: sign,
                    child: Text(_signLabels[sign] ?? sign),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedQuantitySign = val);
                },
              ),
              const SizedBox(height: 16),

              // 3. 금액 연산자 선택
              DropdownButtonFormField<String>(
                value: _signOptions.contains(_selectedAmountSign)
                    ? _selectedAmountSign
                    : 'MINUS',
                decoration: const InputDecoration(
                  labelText: '금액(현금) 연산',
                  helperText: '거래 발생 시 현금 잔고 변동방식',
                ),
                items: _signOptions.map((sign) {
                  return DropdownMenuItem(
                    value: sign,
                    child: Text(_signLabels[sign] ?? sign),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedAmountSign = val);
                },
              ),
            ],
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
              : Text(_isEditing ? '수정' : '등록'),
        ),
      ],
    );
  }
}