import 'package:flutter_test/flutter_test.dart';
import 'package:hisab_nikash/core/utils/currency_formatter.dart';
import 'package:hisab_nikash/core/utils/date_formatter.dart';
import 'package:hisab_nikash/data/models/category_model.dart';
import 'package:hisab_nikash/data/models/debt_model.dart';
import 'package:hisab_nikash/data/models/settings_model.dart';
import 'package:hisab_nikash/data/models/transaction_model.dart';
import 'package:hisab_nikash/domain/entities/domain_enums.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats whole numbers without unnecessary decimal zeros', () {
      expect(CurrencyFormatter.format(2450.0, symbol: '৳'), '৳ 2,450');
      expect(CurrencyFormatter.format(100.0, symbol: '\$'), '\$ 100');
    });

    test('formats decimals with 2 places', () {
      expect(CurrencyFormatter.format(2450.50, symbol: '৳'), '৳ 2,450.50');
    });

    test('formats signed numbers correctly', () {
      expect(CurrencyFormatter.format(5000.0, symbol: '৳', showSign: true), '+৳ 5,000');
      expect(CurrencyFormatter.format(-250.0, symbol: '৳', showSign: true), '-৳ 250');
    });

    test('formats negative amounts correctly without showSign flag', () {
      expect(CurrencyFormatter.format(-250.0, symbol: '৳'), '-৳ 250');
    });
  });

  group('DateFormatter Tests', () {
    test('isSameDay matches identical dates and ignores time', () {
      final a = DateTime(2026, 9, 9, 10, 30);
      final b = DateTime(2026, 9, 9, 22, 15);
      final c = DateTime(2026, 9, 10, 10, 30);
      expect(DateFormatter.isSameDay(a, b), isTrue);
      expect(DateFormatter.isSameDay(a, c), isFalse);
    });

    test('isSameMonth matches dates in same month and year', () {
      final a = DateTime(2026, 9, 1);
      final b = DateTime(2026, 9, 28);
      final c = DateTime(2026, 10, 1);
      expect(DateFormatter.isSameMonth(a, b), isTrue);
      expect(DateFormatter.isSameMonth(a, c), isFalse);
    });
  });

  group('Data Models & JSON Serialization Tests', () {
    test('TransactionModel converts to and from JSON accurately', () {
      final tx = TransactionModel(
        id: 'tx_123',
        amount: 250.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        date: DateTime(2026, 9, 9, 13, 30),
        note: 'Lunch at Cafe',
        paymentMethod: PaymentMethod.bKash,
      );

      final json = tx.toJson();
      final restored = TransactionModel.fromJson(json);

      expect(restored.id, tx.id);
      expect(restored.amount, tx.amount);
      expect(restored.type, tx.type);
      expect(restored.categoryId, tx.categoryId);
      expect(restored.date, tx.date);
      expect(restored.note, tx.note);
      expect(restored.paymentMethod, tx.paymentMethod);
      expect(restored, equals(tx));
    });

    test('CategoryModel converts to and from JSON accurately', () {
      const cat = CategoryModel(
        id: 'cat_test',
        name: 'Entertainment',
        type: TransactionType.expense,
        iconCodePoint: 58900,
        colorValue: 0xFFEF4444,
        isDefault: true,
      );

      final json = cat.toJson();
      final restored = CategoryModel.fromJson(json);

      expect(restored.id, cat.id);
      expect(restored.name, cat.name);
      expect(restored.type, cat.type);
      expect(restored.iconCodePoint, cat.iconCodePoint);
      expect(restored.colorValue, cat.colorValue);
      expect(restored.isDefault, cat.isDefault);
      expect(restored, equals(cat));
    });

    test('DebtModel remainingAmount and status calculations', () {
      final debt = DebtModel(
        id: 'debt_1',
        personName: 'Rahim',
        amount: 5000.0,
        paidAmount: 2000.0,
        type: DebtType.gave,
        date: DateTime(2026, 9, 1),
        status: DebtStatus.partiallyPaid,
      );

      expect(debt.remainingAmount, 3000.0);
      expect(debt.isFullyPaid, isFalse);

      final fullyPaid = debt.copyWith(paidAmount: 5000.0, status: DebtStatus.paid);
      expect(fullyPaid.remainingAmount, 0.0);
      expect(fullyPaid.isFullyPaid, isTrue);

      final json = debt.toJson();
      final restored = DebtModel.fromJson(json);
      expect(restored.personName, debt.personName);
      expect(restored.remainingAmount, 3000.0);
    });

    test('SettingsModel defaults and JSON serialization', () {
      const settings = SettingsModel();
      expect(settings.currencyCode, 'BDT');
      expect(settings.currencySymbol, '৳');
      expect(settings.themeModeIndex, 0);

      final custom = settings.copyWith(currencyCode: 'USD', currencySymbol: '\$', themeModeIndex: 2);
      final json = custom.toJson();
      final restored = SettingsModel.fromJson(json);
      expect(restored.currencyCode, 'USD');
      expect(restored.currencySymbol, '\$');
      expect(restored.themeModeIndex, 2);
    });
  });

  group('Dynamic Balance Calculations Tests', () {
    test('Calculates balance as income minus expense', () {
      final transactions = [
        TransactionModel(
          id: '1',
          amount: 5000.0,
          type: TransactionType.income,
          categoryId: 'cat_salary',
          date: DateTime(2026, 9, 9),
        ),
        TransactionModel(
          id: '2',
          amount: 1500.0,
          type: TransactionType.expense,
          categoryId: 'cat_food',
          date: DateTime(2026, 9, 9),
        ),
        TransactionModel(
          id: '3',
          amount: 1000.0,
          type: TransactionType.expense,
          categoryId: 'cat_transport',
          date: DateTime(2026, 9, 9),
        ),
      ];

      double totalIncome = 0;
      double totalExpense = 0;

      for (final tx in transactions) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      final balance = totalIncome - totalExpense;

      expect(totalIncome, 5000.0);
      expect(totalExpense, 2500.0);
      expect(balance, 2500.0);
    });
  });
}
