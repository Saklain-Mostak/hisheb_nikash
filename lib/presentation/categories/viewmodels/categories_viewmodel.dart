import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class CategoriesViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state completed
  }

  Future<bool> addCategory({
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(categoryRepositoryProvider);
      final newCat = CategoryModel(
        id: const Uuid().v4(),
        name: name.trim(),
        type: type,
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        isDefault: false,
      );
      await repo.addCategory(newCat);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.updateCategory(category);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      // Check if transactions are using this category
      final transactions = ref.read(transactionRepositoryProvider).getAllTransactions();
      final hasTransactions = transactions.any((tx) => tx.categoryId == id);
      if (hasTransactions) {
        throw Exception('Cannot delete category because transactions are linked to it.');
      }

      final repo = ref.read(categoryRepositoryProvider);
      await repo.deleteCategory(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final categoriesViewModelProvider =
    AsyncNotifierProvider<CategoriesViewModel, void>(CategoriesViewModel.new);

final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(categoriesStreamProvider).value ?? [];
  return all.where((c) => c.type == TransactionType.expense).toList();
});

final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final all = ref.watch(categoriesStreamProvider).value ?? [];
  return all.where((c) => c.type == TransactionType.income).toList();
});
