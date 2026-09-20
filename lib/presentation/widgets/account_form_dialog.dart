import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';

class AccountFormDialog extends ConsumerStatefulWidget {
  final Account? initialAccount;

  const AccountFormDialog({super.key, this.initialAccount});

  @override
  ConsumerState<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _institutionController;
  late final TextEditingController _nameController;
  late String _selectedType;

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  final List<String> _accountTypes = ['은행', '연금', '증권', '기타'];

  bool get _isEditing => widget.initialAccount != null;

  @override
  void initState() {
    super.initState();
    _institutionController = TextEditingController(
      text: widget.initialAccount?.financialInstitution ?? '',
    );
    _nameController = TextEditingController(
      text: widget.initialAccount?.accountName ?? '',
    );
    _selectedType = widget.initialAccount?.accountType ?? '은행';
    if (!_accountTypes.contains(_selectedType)) {
      _selectedType = '기타';
    }
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final updatedAccount = widget.initialAccount!.copyWith(
          financialInstitution: _institutionController.text.trim(),
          accountType: _selectedType,
          accountName: _nameController.text.trim(),
        );
        ref
            .read(accountNotifierProvider.notifier)
            .updateAccount(updatedAccount, _selectedImage);
      } else {
        final newAccount = Account(
          financialInstitution: _institutionController.text.trim(),
          accountType: _selectedType,
          accountName: _nameController.text.trim(),
        );
        ref
            .read(accountNotifierProvider.notifier)
            .addAccount(newAccount, _selectedImage);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingLogoUrl = widget.initialAccount?.logoUrl;

    return AlertDialog(
      title: Text(_isEditing ? '계좌 정보 수정' : '신규 계좌 등록'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : (existingLogoUrl != null && existingLogoUrl.isNotEmpty
                          ? NetworkImage(existingLogoUrl) as ImageProvider
                          : null),
                  child: (_imageBytes == null &&
                          (existingLogoUrl == null || existingLogoUrl.isEmpty))
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 20, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('로고 선택', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _institutionController,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: '금융기관 (예: 국민은행)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? '금융기관을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: '계좌구분',
                  border: OutlineInputBorder(),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items: _accountTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: '계좌명 (예: 주거래 통장)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? '계좌명을 입력하세요' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? '수정' : '등록'),
        ),
      ],
    );
  }
}