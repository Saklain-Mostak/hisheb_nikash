import 'package:flutter/material.dart';

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
    CurrencyInfo(
      code: 'BDT',
      symbol: '৳',
      name: 'Bangladeshi Taka',
      isPrefix: true,
    ),
    CurrencyInfo(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      isPrefix: true,
      icon: Icons.attach_money_rounded,
    ),
    CurrencyInfo(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      isPrefix: false,
      icon: Icons.euro_rounded,
    ),
    CurrencyInfo(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      isPrefix: true,
      icon: Icons.currency_pound_rounded,
    ),
    CurrencyInfo(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      isPrefix: true,
      icon: Icons.currency_rupee_rounded,
    ),
    CurrencyInfo(
      code: 'SAR',
      symbol: '﷼',
      name: 'Saudi Riyal',
      isPrefix: false,
    ),
    CurrencyInfo(
      code: 'AED',
      symbol: 'د.إ',
      name: 'UAE Dirham',
      isPrefix: false,
    ),
    CurrencyInfo(
      code: 'CAD',
      symbol: 'CA\$',
      name: 'Canadian Dollar',
      isPrefix: true,
      icon: Icons.attach_money_rounded,
    ),
    CurrencyInfo(
      code: 'AUD',
      symbol: 'AU\$',
      name: 'Australian Dollar',
      isPrefix: true,
      icon: Icons.attach_money_rounded,
    ),
    CurrencyInfo(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      isPrefix: true,
      icon: Icons.currency_yen_rounded,
    ),
    CurrencyInfo(
      code: 'CNY',
      symbol: '¥',
      name: 'Chinese Yuan',
      isPrefix: true,
      icon: Icons.currency_yen_rounded,
    ),
    CurrencyInfo(
      code: 'RUB',
      symbol: '₽',
      name: 'Russian Ruble',
      isPrefix: false,
      icon: Icons.currency_ruble_rounded,
    ),
    CurrencyInfo(
      code: 'IDR',
      symbol: 'Rp',
      name: 'Indonesian Rupiah',
      isPrefix: true,
    ),
  ];

  static bool isSymbolPrefix(String symbolOrCode) {
    if (symbolOrCode == '€' || symbolOrCode == 'EUR' ||
        symbolOrCode == '﷼' || symbolOrCode == 'SAR' ||
        symbolOrCode == 'د.إ' || symbolOrCode == 'AED' ||
        symbolOrCode == '₽' || symbolOrCode == 'RUB') {
      return false;
    }
    return true;
  }

  static CurrencyInfo getCurrency(String codeOrSymbol) {
    return supportedCurrencies.firstWhere(
      (c) => c.code == codeOrSymbol || c.symbol == codeOrSymbol,
      orElse: () => CurrencyInfo(
        code: codeOrSymbol,
        symbol: codeOrSymbol,
        name: codeOrSymbol,
        isPrefix: isSymbolPrefix(codeOrSymbol),
      ),
    );
  }
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final bool isPrefix;
  final IconData? icon;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    this.isPrefix = true,
    this.icon,
  });
}
