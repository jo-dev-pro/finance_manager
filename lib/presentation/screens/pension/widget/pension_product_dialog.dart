import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/pension/pension_product.dart';
import '../../../../providers/pension/pension_product_provider.dart';

class PensionProductDialog extends ConsumerStatefulWidget {
  final PensionProduct? initialData;

  const PensionProductDialog({super.key, this.initialData});

  @override
  ConsumerState<PensionProductDialog> createState() =>
      _PensionProductDialogState();
}

class _PensionProductDialogState extends ConsumerState<PensionProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController(
      text: widget.initialData?.productName ?? '',
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final product = PensionProduct(
        id: widget.initialData?.id,
        productName: _productNameController.text.trim(),
      );

      final notifier = ref.read(pensionProductNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updatePensionProduct(product);
      } else {
        await notifier.addPensionProduct(product);
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
      title: Text(_isEditing ? '연금상품 수정' : '연금상품 등록'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '예: TIGER 미국S&P500, 현금성 자산',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '상품명을 입력해 주세요.';
                  }
                  return null;
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