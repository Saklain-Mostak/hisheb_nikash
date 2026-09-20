import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/domain_enums.dart';
import '../models/category_model.dart';
import '../models/debt_model.dart';
import '../models/settings_model.dart';
import '../models/transaction_model.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  late Box<TransactionModel> _transactionBox;
  late Box<CategoryModel> _categoryBox;
  late Box<DebtModel> _debtBox;
  late Box<SettingsModel> _settingsBox;

  Box<TransactionModel> get transactionBox => _transactionBox;
  Box<CategoryModel> get categoryBox => _categoryBox;
  Box<DebtModel> get debtBox => _debtBox;
  Box<SettingsModel> get settingsBox => _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DebtModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }

    // Open Boxes
    _transactionBox = await Hive.openBox<TransactionModel>(AppConstants.transactionsBox);
    _categoryBox = await Hive.openBox<CategoryModel>(AppConstants.categoriesBox);
    _debtBox = await Hive.openBox<DebtModel>(AppConstants.debtsBox);
    _settingsBox = await Hive.openBox<SettingsModel>(AppConstants.settingsBox);

    // Seed defaults if needed
    await _seedDefaultCategories();
    await _seedDefaultSettings();
  }

  Future<void> _seedDefaultCategories() async {
    if (_categoryBox.isNotEmpty) return;

    final defaultCategories = [
      // Expense Categories
      CategoryModel(
        id: 'cat_food',
        name: 'Food',
        type: TransactionType.expense,
        iconCodePoint: Icons.fastfood_rounded.codePoint,
        colorValue: 0xFFEF4444, // Red
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_transport',
        name: 'Transport',
        type: TransactionType.expense,
        iconCodePoint: Icons.directions_car_rounded.codePoint,
        colorValue: 0xFFF97316, // Orange
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_shopping',
        name: 'Shopping',
        type: TransactionType.expense,
        iconCodePoint: Icons.shopping_bag_rounded.codePoint,
        colorValue: 0xFFEC4899, // Pink
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_bills',
        name: 'Bills',
        type: TransactionType.expense,
        iconCodePoint: Icons.receipt_long_rounded.codePoint,
        colorValue: 0xFFF59E0B, // Amber
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_rent',
        name: 'Rent',
        type: TransactionType.expense,
        iconCodePoint: Icons.home_rounded.codePoint,
        colorValue: 0xFF8B5CF6, // Purple
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_health',
        name: 'Health',
        type: TransactionType.expense,
        iconCodePoint: Icons.medical_services_rounded.codePoint,
        colorValue: 0xFF10B981, // Emerald
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_education',
        name: 'Education',
        type: TransactionType.expense,
        iconCodePoint: Icons.school_rounded.codePoint,
        colorValue: 0xFF3B82F6, // Blue
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_entertainment',
        name: 'Entertainment',
        type: TransactionType.expense,
        iconCodePoint: Icons.movie_creation_rounded.codePoint,
        colorValue: 0xFF6366F1, // Indigo
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_travel',
        name: 'Travel',
        type: TransactionType.expense,
        iconCodePoint: Icons.flight_rounded.codePoint,
        colorValue: 0xFF06B6D4, // Cyan
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_family',
        name: 'Family',
        type: TransactionType.expense,
        iconCodePoint: Icons.people_rounded.codePoint,
        colorValue: 0xFF14B8A6, // Teal
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_other_expense',
        name: 'Other',
        type: TransactionType.expense,
        iconCodePoint: Icons.interests_rounded.codePoint,
        colorValue: 0xFF64748B, // Slate
        isDefault: true,
      ),

      // Income Categories
      CategoryModel(
        id: 'cat_salary',
        name: 'Salary',
        type: TransactionType.income,
        iconCodePoint: Icons.work_rounded.codePoint,
        colorValue: 0xFF10B981, // Emerald
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_freelance',
        name: 'Freelance',
        type: TransactionType.income,
        iconCodePoint: Icons.laptop_mac_rounded.codePoint,
        colorValue: 0xFF06B6D4, // Cyan
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_business',
        name: 'Business',
        type: TransactionType.income,
        iconCodePoint: Icons.storefront_rounded.codePoint,
        colorValue: 0xFF3B82F6, // Blue
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_gift',
        name: 'Gift',
        type: TransactionType.income,
        iconCodePoint: Icons.card_giftcard_rounded.codePoint,
        colorValue: 0xFFEC4899, // Pink
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_bonus',
        name: 'Bonus',
        type: TransactionType.income,
        iconCodePoint: Icons.military_tech_rounded.codePoint,
        colorValue: 0xFFF59E0B, // Amber
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_other_income',
        name: 'Other',
        type: TransactionType.income,
        iconCodePoint: Icons.savings_rounded.codePoint,
        colorValue: 0xFF64748B, // Slate
        isDefault: true,
      ),
    ];

    for (final cat in defaultCategories) {
      await _categoryBox.put(cat.id, cat);
    }
  }

  Future<void> _seedDefaultSettings() async {
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', const SettingsModel());
    }
  }

  // Backup data to JSON string
  String exportDataAsJson() {
    final transactions = _transactionBox.values.map((e) => e.toJson()).toList();
    final categories = _categoryBox.values.map((e) => e.toJson()).toList();
    final debts = _debtBox.values.map((e) => e.toJson()).toList();
    final settings = (_settingsBox.get('settings') ?? const SettingsModel()).toJson();

    final data = {
      'appName': AppConstants.appName,
      'version': AppConstants.appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': transactions,
      'categories': categories,
      'debts': debts,
      'settings': settings,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // Restore data from JSON string
  Future<Map<String, int>> importDataFromJson(String jsonString) async {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup file format.');
    }

    int txCount = 0;
    int catCount = 0;
    int debtCount = 0;

    // Restore Settings
    if (decoded['settings'] is Map<String, dynamic>) {
      final settings = SettingsModel.fromJson(decoded['settings'] as Map<String, dynamic>);
      await _settingsBox.put('settings', settings);
    }

    // Restore Categories
    if (decoded['categories'] is List) {
      final list = decoded['categories'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final cat = CategoryModel.fromJson(item);
          await _categoryBox.put(cat.id, cat);
          catCount++;
        }
      }
    }

    // Restore Transactions
    if (decoded['transactions'] is List) {
      final list = decoded['transactions'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final tx = TransactionModel.fromJson(item);
          await _transactionBox.put(tx.id, tx);
          txCount++;
        }
      }
    }

    // Restore Debts
    if (decoded['debts'] is List) {
      final list = decoded['debts'] as List;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final debt = DebtModel.fromJson(item);
          await _debtBox.put(debt.id, debt);
          debtCount++;
        }
      }
    }

    return {
      'transactions': txCount,
      'categories': catCount,
      'debts': debtCount,
    };
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _transactionBox.clear();
    await _debtBox.clear();
    await _categoryBox.clear();
    await _settingsBox.clear();

    // Re-seed defaults
    await _seedDefaultCategories();
    await _seedDefaultSettings();
  }
}
