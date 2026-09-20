import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/hive_service.dart';
import '../data/models/category_model.dart';
import '../data/models/debt_model.dart';
import '../data/models/settings_model.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/category_repository_impl.dart';
import '../data/repositories/debt_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/debt_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/transaction_repository.dart';

// Hive Service Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

// Repository Providers
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(hiveServiceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(hiveServiceProvider));
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl(ref.watch(hiveServiceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(hiveServiceProvider));
});

// Settings Stream Provider
final settingsStreamProvider = StreamProvider<SettingsModel>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

// Settings Notifier Provider (Riverpod 3 Notifier)
class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    final repo = ref.watch(settingsRepositoryProvider);
    ref.listen(settingsStreamProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        state = next.value!;
      }
    });
    return repo.getSettings();
  }

  Future<void> updateTheme(int themeModeIndex) async {
    final repo = ref.read(settingsRepositoryProvider);
    final updated = state.copyWith(themeModeIndex: themeModeIndex);
    await repo.updateSettings(updated);
    state = updated;
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final repo = ref.read(settingsRepositoryProvider);
    final updated = state.copyWith(
      currencyCode: code,
      currencySymbol: symbol,
    );
    await repo.updateSettings(updated);
    state = updated;
  }

  Future<void> updateLanguage(String languageCode) async {
    final repo = ref.read(settingsRepositoryProvider);
    final updated = state.copyWith(languageCode: languageCode);
    await repo.updateSettings(updated);
    state = updated;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(SettingsNotifier.new);

final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).currencySymbol;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

final appLocaleProvider = Provider<Locale>((ref) {
  final languageCode = ref.watch(settingsProvider).languageCode;
  return Locale(languageCode);
});

// Stream Providers for reactive Hive updates
final transactionsStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions();
});

final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
});

final debtsStreamProvider = StreamProvider<List<DebtModel>>((ref) {
  return ref.watch(debtRepositoryProvider).watchDebts();
});

// Category Map Provider for fast lookup by ID
final categoriesMapProvider = Provider<Map<String, CategoryModel>>((ref) {
  final categories = ref.watch(categoriesStreamProvider).value ?? [];
  return {for (var c in categories) c.id: c};
});
