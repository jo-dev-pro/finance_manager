import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/edit_delete_button.dart';
import '../../../core/widgets/jtext.dart';
import '../../../core/widgets/main_appbar.dart';
import '../../../core/widgets/main_constrainedbox.dart';
import '../../../models/account/account_name.dart';
import '../../../providers/account/account_name_provider.dart';
import 'widgets/account_name_dialog.dart';

class AccountNameScreen extends ConsumerWidget {
  const AccountNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountNameAsync = ref.watch(accountNameNotifierProvider);

    return Scaffold(
      appBar: MainAppBar(
        titleText: '계좌명 관리',
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showDialog(context),
            label: const Text('등록'),
          ),
        ],
      ),
      body: accountNameAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
        data: (accountNames) {
          return MainConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Expanded(
                  child: accountNames.isEmpty
                          ? const Center(
                            child: Text(
                              '등록된 계좌가 없습니다.\n상단의 등록 버튼을 눌러 추가해 보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: accountNames.length,
                            itemBuilder: (context, index) {
                              final accountName = accountNames[index];

                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.label_outline,
                                          size: 20,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: JText(
                                          accountName.accountName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      EditDeleteButtons(
                                        onEdit:
                                            () => _showDialog(
                                              context,
                                              accountName: accountName,
                                            ),
                                        onDelete:
                                            () => _confirmDelete(
                                              context,
                                              ref,
                                              accountName,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDialog(BuildContext context, {AccountName? accountName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AccountNameDialog(accountName: accountName),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AccountName accountName,
  ) {
    if (accountName.id == null) return;

    AppDialog.showDeleteConfirm(
      context,
      title: '삭제 확인',
      content: '\'${accountName.accountName}\' 계좌명을 삭제하시겠습니까?',
      onDelete: () async {
        try {
          await ref
              .read(accountNameNotifierProvider.notifier)
              .deleteAccountName(accountName.id!);

          if (!context.mounted) return;
          AppSnackBar.showInfo(context, '계좌명이 삭제되었습니다.');
        } catch (e) {
          if (!context.mounted) return;
          AppSnackBar.showError(context, '삭제 실패: $e');
        }
      },
    );
  }
}
