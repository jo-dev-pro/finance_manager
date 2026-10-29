// app_route_paths.dart
abstract class AppRoutePath {
  // 최상위 탭 Path
  static const String dashboard = '/dashboard';
  static const String bank = '/bank';
  static const String stock = '/stock';
  static const String pension = '/pension';
  static const String all = '/all';

  // 서브 라우트 Relative Path (AppRouter 내부 서브 라우트 등록용)
  static const String monthlyBankBalanceSub = 'monthly';
  static const String monthlyPensionBalanceSub = 'monthly';
  static const String monthlyStockBalanceSub = 'monthly';
  static const String pensionGuideSub = 'pension-guide';
  static const String stockGuideSub = 'stock-guide';
  static const String investmentSub = 'investment';
  static const String accountSub = 'account';
  static const String accountNameSub = 'accountName';
  static const String stockItemSub = 'stock-item';
  static const String stockHoldingItemSub = 'stock-holding-item';
  static const String pensionAccountProductSub = 'pension-account-product';
  static const String pensionProductSub = 'pension-product';

  // 화면 이동용 Full Path (context.push 등에서 직접 사용)
  static const String monthlyBankBalance = '/bank/monthly';
  static const String monthlyPensionBalance = '/pension/monthly';
  static const String monthlyStockBalance = '/stock/monthly';
  static const String pensionGuide = '/all/pension-guide';
  static const String stockGuide = '/all/stock-guide';
  static const String investment = '/all/investment';
  static const String account = '/all/account';
  static const String accountName = '/all/accountName';
  static const String stockItem = '/all/stock-item';
  static const String stockHoldingItem = '/all/stock-holding-item';
  static const String pensionAccountProduct = '/all/pension-account-product';
  static const String pensionProduct = '/all/pension-product';
}
