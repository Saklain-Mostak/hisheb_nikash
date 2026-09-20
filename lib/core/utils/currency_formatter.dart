import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount, {
    String symbol = '৳',
    bool showSign = false,
    bool compact = false,
    int decimalDigits = 2,
    bool? isPrefix,
  }) {
    final absAmount = amount.abs();
    final bool hasDecimals = absAmount % 1 != 0;
    final int effectiveDecimals = hasDecimals ? decimalDigits : 0;

    final numberFormat = compact
        ? NumberFormat.compact()
        : NumberFormat.currency(
            symbol: '',
            decimalDigits: effectiveDecimals,
          );

    final formattedNumber = numberFormat.format(absAmount).trim();

    if (symbol.isEmpty) {
      if (showSign && amount > 0) return '+$formattedNumber';
      if (amount < 0) return '-$formattedNumber';
      return formattedNumber;
    }

    final effectiveIsPrefix = isPrefix ?? AppConstants.isSymbolPrefix(symbol);

    if (effectiveIsPrefix) {
      final symbolWithSpace = '$symbol ';
      if (showSign && amount > 0) {
        return '+$symbolWithSpace$formattedNumber';
      } else if (amount < 0) {
        return '-$symbolWithSpace$formattedNumber';
      }
      return '$symbolWithSpace$formattedNumber';
    } else {
      final spaceWithSymbol = ' $symbol';
      if (showSign && amount > 0) {
        return '+$formattedNumber$spaceWithSymbol';
      } else if (amount < 0) {
        return '-$formattedNumber$spaceWithSymbol';
      }
      return '$formattedNumber$spaceWithSymbol';
    }
  }

  /// Formats only the numeric amount with commas and decimals, without currency symbol or signs.
  static String formatNumber(
    double amount, {
    bool compact = false,
    int decimalDigits = 2,
  }) {
    final absAmount = amount.abs();
    final bool hasDecimals = absAmount % 1 != 0;
    final int effectiveDecimals = hasDecimals ? decimalDigits : 0;

    final numberFormat = compact
        ? NumberFormat.compact()
        : NumberFormat.currency(
            symbol: '',
            decimalDigits: effectiveDecimals,
          );

    return numberFormat.format(absAmount).trim();
  }
}
