import '../../models/stock_transaction_type.dart';

extension StockTransactionTypeX on StockTransactionType {
  // 수량 계산용 계수 (+1, -1, 0)
  int get quantityFactor {
    switch (quantitySign) {
      case 'PLUS': return 1;
      case 'MINUS': return -1;
      case 'ZERO': default: return 0;
    }
  }

  // 금액 계산용 계수 (+1, -1, 0)
  int get amountFactor {
    switch (amountSign) {
      case 'PLUS': return 1;
      case 'MINUS': return -1;
      case 'ZERO': default: return 0;
    }
  }
}