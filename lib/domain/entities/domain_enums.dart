import 'package:flutter/material.dart';

enum TransactionType {
  expense,
  income;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;
}

enum PaymentMethod {
  cash,
  bank,
  bKash,
  nagad,
  card,
  other;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bank:
        return 'Bank';
      case PaymentMethod.bKash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.bank:
        return Icons.account_balance_outlined;
      case PaymentMethod.bKash:
        return Icons.phone_android_rounded;
      case PaymentMethod.nagad:
        return Icons.smartphone_rounded;
      case PaymentMethod.card:
        return Icons.credit_card_rounded;
      case PaymentMethod.other:
        return Icons.more_horiz_rounded;
    }
  }
}

enum DebtType {
  gave,      // Money I gave (Lent / Receivable)
  received;  // Money I received (Borrowed / Payable)

  String get displayName {
    switch (this) {
      case DebtType.gave:
        return 'Money I gave';
      case DebtType.received:
        return 'Money I received';
    }
  }

  String get shortLabel {
    switch (this) {
      case DebtType.gave:
        return 'Lent (Receivable)';
      case DebtType.received:
        return 'Borrowed (Payable)';
    }
  }

  bool get isGave => this == DebtType.gave;
  bool get isReceived => this == DebtType.received;
}

enum DebtStatus {
  pending,
  partiallyPaid,
  paid;

  String get displayName {
    switch (this) {
      case DebtStatus.pending:
        return 'Pending';
      case DebtStatus.partiallyPaid:
        return 'Partially Paid';
      case DebtStatus.paid:
        return 'Paid';
    }
  }

  Color get badgeColor {
    switch (this) {
      case DebtStatus.pending:
        return const Color(0xFFEF4444); // Red
      case DebtStatus.partiallyPaid:
        return const Color(0xFFF59E0B); // Amber
      case DebtStatus.paid:
        return const Color(0xFF10B981); // Emerald
    }
  }
}
