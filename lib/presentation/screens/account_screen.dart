import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/account_provider.dart';
import '../../models/account.dart';
import '../widgets/account_form_dialog.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('계좌 삭제'),
        content: Text('\'${account.accountName}\' 계좌를 정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (account.id != null) {
                ref
                    .read(accountNotifierProvider.notifier)
                    .deleteAccount(account.id!);
              }
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, [Account? account]) {
    showDialog(
      context: context,
      builder: (_) => AccountFormDialog(initialAccount: account),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('계좌 관리')),
      body: accountState.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text('등록된 계좌가 없습니다.\n하단 버튼을 눌러 계좌를 추가해보세요.', textAlign: TextAlign.center),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];

              // --- 카드 형태 디자인 ---
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // 계좌 로고 이미지 / 기본 아이콘
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: account.logoUrl != null && account.logoUrl!.isNotEmpty
                            ? NetworkImage(account.logoUrl!)
                            : null,
                        child: account.logoUrl == null || account.logoUrl!.isEmpty
                            ? Text(
                                account.financialInstitution.isNotEmpty
                                    ? account.financialInstitution[0]
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // 계좌 정보 (계좌명, 금융기관 · 계좌구분)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.accountName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  account.financialInstitution,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    account.accountType,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 수정 & 삭제 버튼
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.grey.shade700,
                        onPressed: () => _showFormDialog(context, account),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red.shade400,
                        onPressed: () => _showDeleteConfirmDialog(context, ref, account),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('데이터 로드 실패: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('계좌 추가'),
      ),
    );
  }
}