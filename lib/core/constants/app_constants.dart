class AppConstants {
  AppConstants._();

  static const String appName = 'Hishab Nikash';
  static const String appTaglineBengali = 'হিসাব-নিকাশ';
  static const String appTagline = 'Personal Expense & Income Tracker';
  static const String appVersion = '1.0.0';
  static const String appLogoPath = 'assets/images/app_logo.png';
  static const String appLogoMarkPath = 'assets/images/app_logo_mark.png';
  static const String appLogoSquarePath = 'assets/images/app_logo.png';

  // Hive Box Names
  static const String transactionsBox = 'transactions_box';
  static const String categoriesBox = 'categories_box';
  static const String debtsBox = 'debts_box';
  static const String settingsBox = 'settings_box';

  // Default Currency
  static const String defaultCurrencyCode = 'BDT';
  static const String defaultCurrencySymbol = '৳';

  // Supported Currencies List
  static const List<CurrencyInfo> supportedCurrencies = [
    CurrencyInfo(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka'),
    CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British Pound'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    CurrencyInfo(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
    CurrencyInfo(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    CurrencyInfo(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    CurrencyInfo(code: 'AUD', symbol: 'AU\$', name: 'Australian Dollar'),
    CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  ];
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
  });
}
