// app_router_path.dart
abstract class AppRoutePath {
  // 1. 최상위 탭 Path
  static const String dashboard = '/dashboard';
  static const String bank = '/bank';
  static const String stock = '/stock';
  static const String pension = '/pension';
  static const String all = '/all';

  // 2. 화면 이동용 Full Path (context.push 등에서 사용)
  static const String monthlyBankBalance = '$bank/monthly';
  static const String monthlyStockBalance = '$stock/monthly';
  
  static const String monthlyPensionBalance = '$pension/monthly';
  static const String monthlyPensionSummary = '$pension/summary';

  static const String assetsGuide = '$all/assets-guide';
  static const String investment = '$all/investment';
  static const String account = '$all/account';
  static const String accountName = '$all/accountName';
  static const String stockItem = '$all/stock-item';
  static const String stockHoldingItem = '$all/stock-holding-item';
  static const String pensionAccountProduct = '$all/pension-account-product';
  static const String pensionProduct = '$all/pension-product';

  // 3. GoRoute 하위 path 등록용 헬퍼 (마지막 세그먼트만 추출)
  static String sub(String fullPath) => fullPath.split('/').last;
}