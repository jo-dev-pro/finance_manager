import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/stock_item.dart';
import '../../providers/stock_item_provider.dart';

class StockItemDialog extends ConsumerStatefulWidget {
  final StockItem? initialData;

  const StockItemDialog({super.key, this.initialData});

  @override
  ConsumerState<StockItemDialog> createState() => _StockItemDialogState();
}

class _StockItemDialogState extends ConsumerState<StockItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _memoController;
  String _selectedMarket = 'KOSPI';
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  final List<String> _markets = ['KOSPI', 'KOSDAQ', 'NYSE', 'NASDAQ', 'ETF', '기타'];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialData?.symbolCode ?? '');
    _nameController = TextEditingController(text: widget.initialData?.name ?? '');
    _memoController = TextEditingController(text: widget.initialData?.memo ?? '');
    if (widget.initialData != null && _markets.contains(widget.initialData!.market)) {
      _selectedMarket = widget.initialData!.market;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final stockItem = StockItem(
        id: widget.initialData?.id,
        symbolCode: _codeController.text.trim(),
        name: _nameController.text.trim(),
        market: _selectedMarket,
        memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
      );

      final notifier = ref.read(stockItemNotifierProvider.notifier);
      if (_isEditing) {
        await notifier.updateStockItem(stockItem);
      } else {
        await notifier.addStockItem(stockItem);
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
      title: Text(_isEditing ? '종목 수정' : '종목 등록'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: '종목코드',
                  hintText: '예: 005930, AAPL',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '종목코드를 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '종목명',
                  hintText: '예: 삼성전자, 애플',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '종목명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMarket,
                decoration: const InputDecoration(labelText: '시장 구분'),
                items: _markets.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMarket = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '비고 사항 입력',
                ),
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