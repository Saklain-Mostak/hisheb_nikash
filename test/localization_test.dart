import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab_nikash/core/localization/app_localizations.dart';
import 'package:hisab_nikash/domain/entities/domain_enums.dart';
import 'package:hisab_nikash/presentation/transactions/viewmodels/transactions_viewmodel.dart';

void main() {
  group('Localization Tests', () {
    test('Verifies all 11 required languages are supported', () {
      final codes = AppLocalizations.supportedLanguages.map((l) => l.code).toList();
      expect(codes, containsAll([
        'en', // English
        'bn', // Bengali
        'hi', // Hindi
        'zh', // Mandarin Chinese
        'es', // Spanish
        'ar', // Arabic
        'fr', // French
        'pt', // Portuguese
        'ru', // Russian
        'ur', // Urdu
        'id', // Indonesian
      ]));
      expect(codes.length, equals(11));

      final localeCodes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(localeCodes, equals(codes));
    });

    test('RTL languages are correctly identified', () {
      final ar = AppLocalizations.supportedLanguages.firstWhere((l) => l.code == 'ar');
      final ur = AppLocalizations.supportedLanguages.firstWhere((l) => l.code == 'ur');
      final en = AppLocalizations.supportedLanguages.firstWhere((l) => l.code == 'en');
      final bn = AppLocalizations.supportedLanguages.firstWhere((l) => l.code == 'bn');

      expect(ar.isRtl, isTrue);
      expect(ur.isRtl, isTrue);
      expect(en.isRtl, isFalse);
      expect(bn.isRtl, isFalse);
    });

    test('Each of the 11 languages returns valid localized navigation strings', () {
      for (final lang in AppLocalizations.supportedLanguages) {
        final l10n = AppLocalizations(Locale(lang.code));

        expect(l10n.navHome.isNotEmpty, isTrue, reason: '${lang.code} navHome is empty');
        expect(l10n.navTransactions.isNotEmpty, isTrue, reason: '${lang.code} navTransactions is empty');
        expect(l10n.navReports.isNotEmpty, isTrue, reason: '${lang.code} navReports is empty');
        expect(l10n.navDebts.isNotEmpty, isTrue, reason: '${lang.code} navDebts is empty');
        expect(l10n.navSettings.isNotEmpty, isTrue, reason: '${lang.code} navSettings is empty');
        expect(l10n.totalBalance.isNotEmpty, isTrue, reason: '${lang.code} totalBalance is empty');
        expect(l10n.backupData.isNotEmpty, isTrue, reason: '${lang.code} backupData is empty');
        expect(l10n.restoreData.isNotEmpty, isTrue, reason: '${lang.code} restoreData is empty');
      }
    });

    test('AppLocalizations delegate correctly supports all 11 locales', () {
      const delegate = AppLocalizations.delegate;

      for (final locale in AppLocalizations.supportedLocales) {
        expect(delegate.isSupported(locale), isTrue, reason: '$locale not supported by delegate');
      }

      expect(delegate.isSupported(const Locale('de')), isFalse);
    });

    test('Bengali translations return expected native strings', () {
      final l10n = AppLocalizations(const Locale('bn'));
      expect(l10n.navHome, equals('হোম'));
      expect(l10n.navTransactions, equals('লেনদেন'));
      expect(l10n.navReports, equals('রিপোর্ট'));
      expect(l10n.navDebts, equals('ধার-দেনা'));
      expect(l10n.navSettings, equals('সেটিংস'));
      expect(l10n.totalBalance, equals('মোট ব্যালেন্স'));
      expect(l10n.loansAndDebts, equals('ধার ও ঋণ'));
      expect(l10n.getCategoryName('Food', 'cat_food'), equals('খাবার'));
    });

    test('All 11 languages support new keys, sort orders, date presets, and enum helpers', () {
      for (final lang in AppLocalizations.supportedLanguages) {
        final l10n = AppLocalizations(Locale(lang.code));

        expect(l10n.sortNewest.isNotEmpty, isTrue, reason: '${lang.code} sortNewest empty');
        expect(l10n.sortOldest.isNotEmpty, isTrue, reason: '${lang.code} sortOldest empty');
        expect(l10n.presetToday.isNotEmpty, isTrue, reason: '${lang.code} presetToday empty');
        expect(l10n.presetThisMonth.isNotEmpty, isTrue, reason: '${lang.code} presetThisMonth empty');
        expect(l10n.loansAndDebts.isNotEmpty, isTrue, reason: '${lang.code} loansAndDebts empty');
        expect(l10n.monthlyReport.isNotEmpty, isTrue, reason: '${lang.code} monthlyReport empty');
        expect(l10n.recordPayment.isNotEmpty, isTrue, reason: '${lang.code} recordPayment empty');

        // Enum helpers
        expect(l10n.getPaymentMethodName(PaymentMethod.cash).isNotEmpty, isTrue);
        expect(l10n.getPaymentMethodName(PaymentMethod.bank).isNotEmpty, isTrue);
        expect(l10n.getTransactionTypeName(TransactionType.expense).isNotEmpty, isTrue);
        expect(l10n.getTransactionTypeName(TransactionType.income).isNotEmpty, isTrue);
        expect(l10n.getDebtTypeName(DebtType.gave).isNotEmpty, isTrue);
        expect(l10n.getDebtTypeName(DebtType.received).isNotEmpty, isTrue);
        expect(l10n.getDebtStatusName(DebtStatus.paid).isNotEmpty, isTrue);
        expect(l10n.getDatePresetName(DateFilterPreset.thisWeek).isNotEmpty, isTrue);
        expect(l10n.getSortOrderName(TransactionSortOrder.newestFirst).isNotEmpty, isTrue);

        // Category localization helper
        expect(l10n.getCategoryName('Food', 'cat_food').isNotEmpty, isTrue);
        expect(l10n.getCategoryName('Salary', 'cat_salary').isNotEmpty, isTrue);
        expect(l10n.getCategoryName('Custom User Gym', 'user_custom_id'), equals('Custom User Gym'));
      }
    });

    test('Arabic translations return expected Arabic strings', () {
      final l10n = AppLocalizations(const Locale('ar'));
      expect(l10n.navHome, equals('الرئيسية'));
      expect(l10n.navTransactions, equals('المعاملات'));
      expect(l10n.navReports, equals('التقارير'));
      expect(l10n.navDebts, equals('الديون'));
      expect(l10n.navSettings, equals('الإعدادات'));
      expect(l10n.loansAndDebts, equals('القروض والديون'));
    });

    test('Urdu translations return expected Urdu strings', () {
      final l10n = AppLocalizations(const Locale('ur'));
      expect(l10n.navHome, equals('ہوم'));
      expect(l10n.navTransactions, equals('لین دین'));
      expect(l10n.navReports, equals('رپورٹس'));
      expect(l10n.navDebts, equals('قرضے'));
      expect(l10n.navSettings, equals('ترتیبات'));
      expect(l10n.loansAndDebts, equals('قرضے اور ادھار'));
    });

    test('Indonesian translations return expected Indonesian strings', () {
      final l10n = AppLocalizations(const Locale('id'));
      expect(l10n.navHome, equals('Beranda'));
      expect(l10n.navTransactions, equals('Transaksi'));
      expect(l10n.navReports, equals('Laporan'));
      expect(l10n.navDebts, equals('Utang Piutang'));
      expect(l10n.navSettings, equals('Pengaturan'));
      expect(l10n.loansAndDebts, equals('Pinjaman & Utang'));
      expect(l10n.getCategoryName('Food', 'cat_food'), equals('Makanan'));
    });
  });
}
