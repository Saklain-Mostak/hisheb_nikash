import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount, {
    String symbol = '৳',
    bool showSign = false,
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

    final formattedNumber = numberFormat.format(absAmount).trim();
    final symbolWithSpace = symbol.isNotEmpty ? '$symbol ' : '';

    if (showSign) {
      if (amount > 0) {
        return '+$symbolWithSpace$formattedNumber';
      } else if (amount < 0) {
        return '-$symbolWithSpace$formattedNumber';
      }
    }

    if (amount < 0) {
      return '-$symbolWithSpace$formattedNumber';
    }

    return '$symbolWithSpace$formattedNumber';
  }
}
