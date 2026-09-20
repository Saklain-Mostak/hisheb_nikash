import '../../domain/entities/domain_enums.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/hive_service.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final HiveService _hiveService;

  CategoryRepositoryImpl(this._hiveService);

  @override
  List<CategoryModel> getAllCategories() {
    return _hiveService.categoryBox.values.toList();
  }

  @override
  List<CategoryModel> getCategoriesByType(TransactionType type) {
    return _hiveService.categoryBox.values
        .where((element) => element.type == type)
        .toList();
  }

  @override
  CategoryModel? getCategoryById(String id) {
    return _hiveService.categoryBox.get(id);
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _hiveService.categoryBox.put(category.id, category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _hiveService.categoryBox.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _hiveService.categoryBox.delete(id);
  }

  @override
  Stream<List<CategoryModel>> watchCategories() async* {
    yield getAllCategories();
    yield* _hiveService.categoryBox.watch().map((_) => getAllCategories());
  }
}
