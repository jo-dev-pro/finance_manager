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
  late TextEditingController _otherNameController;
  
  // 💡 야후 파이낸스 접미사 기준에 맞춘 시장 구분 값 설정 (KS: 코스피, KQ: 코스닥, 빈값: 미국/기타)
  String _selectedYahooName = 'KS';
  bool _isSubmitting = false;

  bool get _isEditing => widget.initialData != null;

  // 야후 파이낸스 티커 접미사 매핑용 목록 (label: 화면 표시명, value: 실제 yahooName 저장값)
  final List<Map<String, String>> _yahooMarkets = [
    {'label': '코스피 (KS)', 'value': 'KS'},
    {'label': '코스닥 (KQ)', 'value': 'KQ'},
    {'label': '미국 / 기타 (접미사 없음)', 'value': ''},
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialData?.stockCode ?? '');
    _nameController = TextEditingController(text: widget.initialData?.itemName ?? '');
    _otherNameController = TextEditingController(text: widget.initialData?.otherName ?? '');
    
    if (widget.initialData != null && widget.initialData!.yahooName != null) {
      // 기존 저장된 값이 목록에 있다면 반영, 없으면 기본값 유지
      final match = _yahooMarkets.any((m) => m['value'] == widget.initialData!.yahooName);
      if (match) {
        _selectedYahooName = widget.initialData!.yahooName!;
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _otherNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final stockItem = StockItem(
        id: widget.initialData?.id,
        stockCode: _codeController.text.trim(),
        itemName: _nameController.text.trim(),
        yahooName: _selectedYahooName, // 💡 야후 연동용 yahooName 저장
        otherName: _otherNameController.text.trim().isEmpty ? null : _otherNameController.text.trim(),
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
              // 상단 헤더
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
                  labelText: '종목코드 (티커)',
                  hintText: '예: 005930, 285490, AAPL',
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
                  hintText: '예: 삼성전자, 노바텍, 애플',
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

              // 3. 야후 시장 구분 (yahooName) 선택
              DropdownButtonFormField<String>(
                initialValue: _selectedYahooName,
                decoration: const InputDecoration(
                  labelText: '야후 시장 구분 (Yahoo Name)',
                  border: OutlineInputBorder(),
                  helperText: '야후 파이낸스 자동 시세 조회 시 티커 뒤에 붙는 구분자입니다.',
                  helperMaxLines: 2,
                ),
                items: _yahooMarkets.map((market) {
                  return DropdownMenuItem(
                    value: market['value'],
                    child: Text(market['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedYahooName = val);
                },
              ),
              const SizedBox(height: 12),

              // 4. 기타 이름 / 메모 입력 (otherName)
              TextFormField(
                controller: _otherNameController,
                decoration: const InputDecoration(
                  labelText: '기타 이름 / 메모 (선택)',
                  hintText: '비고 사항 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 하단 버튼 영역
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