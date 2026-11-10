import 'package:flutter/material.dart';
import '../../../core/utils/number_formatter.dart';

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
                children: [
                  if (logoUrl != null && logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        logoUrl!,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (institution.isNotEmpty)
                          Text(
                            institution,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        Text(
                          accountName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    totalBalance.toWon(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E43B3),
                    ),
                  ),
                ],
              ),

              // 2. 중간 영역 (원금 및 손익 - 주식/연금용)
              if (totalPrincipal != null || totalProfitOrLoss != null) ...[
                // const Divider(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (totalPrincipal != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '투자 원금',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalPrincipal!.toWon(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    if (totalProfitOrLoss != null && returnRate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '평가 손익 (수익률)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              totalProfitOrLoss!.toSignedPriceText(
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                positiveColor: Colors.red.shade700,
                                negativeColor: Colors.blue.shade700,
                                zeroColor: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              returnRate!.toSignedPercentText(
                                withParentheses: true,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                positiveColor: Colors.red.shade700,
                                negativeColor: Colors.blue.shade700,
                                zeroColor: Colors.black87,
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ],

              // 3. 하단 부가 정보 (종목수, 인출액, 전월대비)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (itemCount != null)
                    Text(
                      '보유 종목 $itemCount개',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    )
                  else if (diffFromLastMonth != null)
                    Row(
                      children: [
                        const Text('전월 대비: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        diffFromLastMonth!.toSignedPriceText(
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  if (totalWithdrawal != null)
                    Opacity(
                      opacity: totalWithdrawal! > 0 ? 1.0 : 0.0,
                      child: Text(
                        totalWithdrawal! > 0 ? '인출액: ${totalWithdrawal!.toWon()}' : '',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}