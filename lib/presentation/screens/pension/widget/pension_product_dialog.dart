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
              // 상단 헤더 (타이틀 + 닫기 버튼)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? '연금상품 수정' : '연금상품 등록',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '예: TIGER 미국S&P500, 현금성 자산',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '상품명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 하단 버튼 영역 (좌우 꽉 찬 버튼)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? '수정하기' : '등록하기',
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
}