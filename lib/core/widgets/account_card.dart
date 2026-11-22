import 'package:flutter/material.dart';
import '../../../core/utils/number_formatter.dart';
import '../utils/responsive_extension.dart';
import 'jtext.dart';

class AccountCard extends StatelessWidget {
  final String? logoUrl;
  final String institution;
  final String accountName;
  final double totalBalance;

  // 선택적 필드 (주식/연금은 원금/손익이 있고, 은행은 없을 수 있음)
  final double? totalPrincipal;
  final double? totalProfitOrLoss;
  final double? returnRate;
  final double? totalWithdrawal;
  final double? diffFromLastMonth;
  final int? itemCount;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    this.logoUrl,
    required this.institution,
    required this.accountName,
    required this.totalBalance,
    this.totalPrincipal,
    this.totalProfitOrLoss,
    this.returnRate,
    this.totalWithdrawal,
    this.diffFromLastMonth,
    this.itemCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. 헤더 (로고, 기관명, 계좌명, 잔액)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (logoUrl != null && logoUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            logoUrl!,
                            width: 25,
                            height: 25,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.account_balance,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.account_balance,
                          size: 20,
                          color: Colors.indigo,
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: JText(
                          accountName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: JText(
                        totalBalance.toWon(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. 중간 영역 (원금 및 손익 - 주식/연금용)
              if (totalPrincipal != null || totalProfitOrLoss != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (totalPrincipal != null)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '투자원금',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: JText(
                                totalPrincipal!.toWon(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (totalPrincipal != null &&
                        totalProfitOrLoss != null &&
                        returnRate != null)
                      const SizedBox(width: 8),
                    if (totalProfitOrLoss != null && returnRate != null)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '평가손익(수익률)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  totalProfitOrLoss!.toSignedPriceText(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  returnRate!.toSignedPercentText(
                                    withParentheses: true,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],

              // 3. 하단 부가 정보 (종목수, 인출액, 전월대비)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child:
                        itemCount != null
                            ? Text(
                              '보유 종목 $itemCount개',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                            : diffFromLastMonth != null
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '전월 대비: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: diffFromLastMonth!.toSignedPriceText(
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
                  ),
                  if (totalWithdrawal != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Opacity(
                        opacity: totalWithdrawal! > 0 ? 1.0 : 0.0,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: JText(
                            totalWithdrawal! > 0
                                ? '인출액: ${totalWithdrawal!.toWon()}'
                                : '',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
