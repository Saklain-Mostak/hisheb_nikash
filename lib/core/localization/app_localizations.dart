import 'package:flutter/widgets.dart';
import '../../domain/entities/domain_enums.dart';
import '../../presentation/transactions/viewmodels/transactions_viewmodel.dart';
import 'translations/ar.dart';
import 'translations/bn.dart';
import 'translations/en.dart';
import 'translations/es.dart';
import 'translations/fr.dart';
import 'translations/hi.dart';
import 'translations/id.dart';
import 'translations/pt.dart';
import 'translations/ru.dart';
import 'translations/ur.dart';
import 'translations/zh.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isRtl = false,
  });
}

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _localizedStrings;

  AppLocalizations(this.locale) {
    switch (locale.languageCode) {
      case 'bn':
        _localizedStrings = bnTranslations;
        break;
      case 'hi':
        _localizedStrings = hiTranslations;
        break;
      case 'zh':
        _localizedStrings = zhTranslations;
        break;
      case 'es':
        _localizedStrings = esTranslations;
        break;
      case 'ar':
        _localizedStrings = arTranslations;
        break;
      case 'fr':
        _localizedStrings = frTranslations;
        break;
      case 'pt':
        _localizedStrings = ptTranslations;
        break;
      case 'ru':
        _localizedStrings = ruTranslations;
        break;
      case 'ur':
        _localizedStrings = urTranslations;
        break;
      case 'id':
        _localizedStrings = idTranslations;
        break;
      case 'en':
      default:
        _localizedStrings = enTranslations;
        break;
    }
  }

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文'),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español'),
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', isRtl: true),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français'),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', isRtl: true),
    AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('bn'),
    Locale('hi'),
    Locale('zh'),
    Locale('es'),
    Locale('ar'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('ur'),
    Locale('id'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String translate(String key) {
    return _localizedStrings[key] ?? enTranslations[key] ?? key;
  }

  // Navigation
  String get navHome => translate('navHome');
  String get navTransactions => translate('navTransactions');
  String get navReports => translate('navReports');
  String get navDebts => translate('navDebts');
  String get navSettings => translate('navSettings');

  // Dashboard & Greetings
  String get greetingMorning => translate('greetingMorning');
  String get greetingAfternoon => translate('greetingAfternoon');
  String get greetingEvening => translate('greetingEvening');
  String get totalBalance => translate('totalBalance');
  String get totalIncome => translate('totalIncome');
  String get totalExpense => translate('totalExpense');
  String get quickActions => translate('quickActions');
  String get addIncome => translate('addIncome');
  String get addExpense => translate('addExpense');
  String get addDebt => translate('addDebt');
  String get viewReports => translate('viewReports');
  String get recentTransactions => translate('recentTransactions');
  String get viewAll => translate('viewAll');
  String get noTransactionsYet => translate('noTransactionsYet');
  String get startAddingTransactions => translate('startAddingTransactions');
  String get dailyHistory => translate('dailyHistory');

  // Transactions Screen & Filters
  String get transactions => translate('transactions');
  String get searchTransactions => translate('searchTransactions');
  String get filterAll => translate('filterAll');
  String get filterIncome => translate('filterIncome');
  String get filterExpense => translate('filterExpense');
  String get transactionDetails => translate('transactionDetails');
  String get addTransaction => translate('addTransaction');
  String get editTransaction => translate('editTransaction');
  String get updateTransaction => translate('updateTransaction');
  String get saveTransaction => translate('saveTransaction');
  String get amount => translate('amount');
  String get category => translate('category');
  String get note => translate('note');
  String get noteOptional => translate('noteOptional');
  String get date => translate('date');
  String get dateTime => translate('dateTime');
  String get time => translate('time');
  String get paymentMethod => translate('paymentMethod');
  String get cash => translate('cash');
  String get bank => translate('bank');
  String get card => translate('card');
  String get bKash => translate('bKash');
  String get nagad => translate('nagad');
  String get other => translate('other');
  String get mobileBanking => translate('mobileBanking');
  String get deleteTransaction => translate('deleteTransaction');
  String get confirmDeleteTransaction => translate('confirmDeleteTransaction');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get manage => translate('manage');
  String get sortBy => translate('sortBy');
  String get resetFilters => translate('resetFilters');
  String get allCategories => translate('allCategories');
  String get allMethods => translate('allMethods');
  String get noTransactionsFound => translate('noTransactionsFound');
  String get clearFiltersMessage => translate('clearFiltersMessage');
  String get noTransactionsRecorded => translate('noTransactionsRecorded');
  String get transactionNotFound => translate('transactionNotFound');
  String get noteHint => translate('noteHint');
  String get enterValidAmount => translate('enterValidAmount');
  String get selectCategoryError => translate('selectCategoryError');

  // Sort Orders
  String get sortNewest => translate('sortNewest');
  String get sortOldest => translate('sortOldest');
  String get sortHighest => translate('sortHighest');
  String get sortLowest => translate('sortLowest');

  // Date Filter Presets
  String get presetAll => translate('presetAll');
  String get presetToday => translate('presetToday');
  String get presetThisWeek => translate('presetThisWeek');
  String get presetThisMonth => translate('presetThisMonth');
  String get presetCustom => translate('presetCustom');

  // Categories
  String get categories => translate('categories');
  String get manageCategories => translate('manageCategories');
  String get addCategory => translate('addCategory');
  String get editCategory => translate('editCategory');
  String get newCategory => translate('newCategory');
  String get categoryName => translate('categoryName');
  String get categoryNameLabel => translate('categoryNameLabel');
  String get categoryNameHint => translate('categoryNameHint');
  String get color => translate('color');
  String get icon => translate('icon');
  String get type => translate('type');
  String get selectIcon => translate('selectIcon');
  String get selectColor => translate('selectColor');
  String get deleteCategory => translate('deleteCategory');
  String get confirmDeleteCategory => translate('confirmDeleteCategory');
  String get deleteCategoryMessage => translate('deleteCategoryMessage');
  String get cannotDeleteCategoryLinked => translate('cannotDeleteCategoryLinked');
  String get categoryNameEmpty => translate('categoryNameEmpty');
  String get expenseCategories => translate('expenseCategories');
  String get incomeCategories => translate('incomeCategories');
  String get noCategoriesFound => translate('noCategoriesFound');
  String get saveChanges => translate('saveChanges');
  String get createCategory => translate('createCategory');
  String get defaultLabel => translate('defaultLabel');

  // Debts
  String get debts => translate('debts');
  String get loansAndDebts => translate('loansAndDebts');
  String get iGave => translate('iGave');
  String get iTook => translate('iTook');
  String get receivable => translate('receivable');
  String get payable => translate('payable');
  String get youWillReceive => translate('youWillReceive');
  String get youNeedToPay => translate('youNeedToPay');
  String get moneyIGave => translate('moneyIGave');
  String get moneyIReceived => translate('moneyIReceived');
  String get youWillReceiveSub => translate('youWillReceiveSub');
  String get youNeedToPaySub => translate('youNeedToPaySub');
  String get addDebtTitle => translate('addDebtTitle');
  String get editDebtTitle => translate('editDebtTitle');
  String get addLoanDebt => translate('addLoanDebt');
  String get updateLoan => translate('updateLoan');
  String get saveLoan => translate('saveLoan');
  String get personName => translate('personName');
  String get personNameLabel => translate('personNameLabel');
  String get personNameHint => translate('personNameHint');
  String get personNameRequired => translate('personNameRequired');
  String get amountRequired => translate('amountRequired');
  String get person => translate('person');
  String get settle => translate('settle');
  String get settled => translate('settled');
  String get pending => translate('pending');
  String get partiallyPaid => translate('partiallyPaid');
  String get paid => translate('paid');
  String get statusAll => translate('statusAll');
  String get statusPending => translate('statusPending');
  String get statusPartiallyPaid => translate('statusPartiallyPaid');
  String get statusPaid => translate('statusPaid');
  String get dueDate => translate('dueDate');
  String get dueDateOptional => translate('dueDateOptional');
  String get notSet => translate('notSet');
  String get debtDetails => translate('debtDetails');
  String get deleteDebt => translate('deleteDebt');
  String get confirmDeleteDebt => translate('confirmDeleteDebt');
  String get noLoansOrDebts => translate('noLoansOrDebts');
  String get noLoansOrDebtsSub => translate('noLoansOrDebtsSub');
  String get remainingDue => translate('remainingDue');
  String get totalAmount => translate('totalAmount');
  String get given => translate('given');
  String get due => translate('due');
  String get recordPayment => translate('recordPayment');
  String get paymentAmount => translate('paymentAmount');
  String get savePayment => translate('savePayment');
  String get enterAmountGreaterThanZero => translate('enterAmountGreaterThanZero');

  // Reports
  String get reports => translate('reports');
  String get monthlyReport => translate('monthlyReport');
  String get financialOverview => translate('financialOverview');
  String get netBalance => translate('netBalance');
  String get categoryBreakdown => translate('categoryBreakdown');
  String get topSpendingCategory => translate('topSpendingCategory');
  String get highestExpense => translate('highestExpense');
  String get numberOfTransactions => translate('numberOfTransactions');
  String get expenseByCategory => translate('expenseByCategory');
  String get incomeVsExpense => translate('incomeVsExpense');
  String get topSpendingBreakdown => translate('topSpendingBreakdown');
  String get thisWeek => translate('thisWeek');
  String get thisMonth => translate('thisMonth');
  String get thisYear => translate('thisYear');
  String get allTime => translate('allTime');
  String get noDataForPeriod => translate('noDataForPeriod');
  String get none => translate('none');
  String get transactionsCount => translate('transactionsCount');

  // Calendar
  String get calendar => translate('calendar');
  String get noTransactionsOnDate => translate('noTransactionsOnDate');
  String get noTransactionsOnDateSub => translate('noTransactionsOnDateSub');
  String get previousDay => translate('previousDay');
  String get nextDay => translate('nextDay');
  String get today => translate('today');

  // Settings
  String get settings => translate('settings');
  String get preferences => translate('preferences');
  String get currency => translate('currency');
  String get selectCurrency => translate('selectCurrency');
  String get theme => translate('theme');
  String get selectTheme => translate('selectTheme');
  String get themeSystem => translate('themeSystem');
  String get themeLight => translate('themeLight');
  String get themeDark => translate('themeDark');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');
  String get management => translate('management');
  String get dataAndBackup => translate('dataAndBackup');
  String get backupData => translate('backupData');
  String get backupSubtitle => translate('backupSubtitle');
  String get restoreData => translate('restoreData');
  String get restoreSubtitle => translate('restoreSubtitle');
  String get clearAllData => translate('clearAllData');
  String get clearAllDataSubtitle => translate('clearAllDataSubtitle');
  String get about => translate('about');
  String get aboutSubtitle => translate('aboutSubtitle');
  String get downloadToStorage => translate('downloadToStorage');
  String get downloadToStorageSubtitle => translate('downloadToStorageSubtitle');
  String get shareViaApps => translate('shareViaApps');
  String get shareViaAppsSubtitle => translate('shareViaAppsSubtitle');
  String get copyJson => translate('copyJson');
  String get copyJsonSubtitle => translate('copyJsonSubtitle');
  String get selectBackupFile => translate('selectBackupFile');
  String get selectBackupFileSubtitle => translate('selectBackupFileSubtitle');
  String get pasteJsonContent => translate('pasteJsonContent');
  String get pasteJsonContentSubtitle => translate('pasteJsonContentSubtitle');
  String get backupSuccess => translate('backupSuccess');
  String get restoreSuccess => translate('restoreSuccess');
  String get backupReady => translate('backupReady');
  String get close => translate('close');
  String get confirm => translate('confirm');
  String get clearEverything => translate('clearEverything');

  // Enum Helpers
  String getTransactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return filterExpense;
      case TransactionType.income:
        return filterIncome;
    }
  }

  String getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return cash;
      case PaymentMethod.bank:
        return bank;
      case PaymentMethod.card:
        return card;
      case PaymentMethod.bKash:
        return bKash;
      case PaymentMethod.nagad:
        return nagad;
      case PaymentMethod.other:
        return other;
    }
  }

  String getDebtTypeName(DebtType type) {
    switch (type) {
      case DebtType.gave:
        return moneyIGave;
      case DebtType.received:
        return moneyIReceived;
    }
  }

  String getDebtStatusName(DebtStatus status) {
    switch (status) {
      case DebtStatus.pending:
        return statusPending;
      case DebtStatus.partiallyPaid:
        return statusPartiallyPaid;
      case DebtStatus.paid:
        return statusPaid;
    }
  }

  String getDatePresetName(DateFilterPreset preset) {
    switch (preset) {
      case DateFilterPreset.all:
        return presetAll;
      case DateFilterPreset.today:
        return presetToday;
      case DateFilterPreset.thisWeek:
        return presetThisWeek;
      case DateFilterPreset.thisMonth:
        return presetThisMonth;
      case DateFilterPreset.custom:
        return presetCustom;
    }
  }

  String getSortOrderName(TransactionSortOrder sortOrder) {
    switch (sortOrder) {
      case TransactionSortOrder.newestFirst:
        return sortNewest;
      case TransactionSortOrder.oldestFirst:
        return sortOldest;
      case TransactionSortOrder.highestAmount:
        return sortHighest;
      case TransactionSortOrder.lowestAmount:
        return sortLowest;
    }
  }

  String getCategoryName(String name, [String? id]) {
    final key = id ?? 'cat_${name.toLowerCase().replaceAll(' ', '_')}';
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key]!;
    }
    return name;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
