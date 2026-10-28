import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/stock/stock_item.dart';
import '../../../../providers/stock/stock_item_provider.dart';

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
    // 키보드가 올라올 때 바텀시트가 가려지지 않도록 하단 인셋 확보
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
                    _isEditing ? '종목 수정' : '종목 등록',
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

              // 1. 종목코드 입력
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: '종목코드',
                  hintText: '예: 005930, AAPL',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '종목코드를 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 2. 종목명 입력
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '종목명',
                  hintText: '예: 삼성전자, 애플',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '종목명을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 3. 시장 구분 선택
              DropdownButtonFormField<String>(
                initialValue: _selectedMarket,
                decoration: const InputDecoration(
                  labelText: '시장 구분',
                  border: OutlineInputBorder(),
                ),
                items: _markets.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMarket = val);
                },
              ),
              const SizedBox(height: 12),

              // 4. 메모 입력
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '비고 사항 입력',
                  border: OutlineInputBorder(),
                ),
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