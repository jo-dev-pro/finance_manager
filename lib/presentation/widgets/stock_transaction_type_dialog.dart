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
  String _selectedType = 'PLUS';
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  final List<String> _types = ['PLUS', 'MINUS'];

  @override
  void initState() {
    super.initState();
    _typeNameController = TextEditingController(text: widget.initialData?.typeName ?? '');
    if (widget.initialData != null ) {
      _selectedType = widget.initialData!.typeName;
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
        type: _selectedType,
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
              TextFormField(
                controller: _typeNameController,
                decoration: const InputDecoration(
                  labelText: '거래구분명',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '거래구분명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: '거래구분 유형'),
                items: _types.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
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