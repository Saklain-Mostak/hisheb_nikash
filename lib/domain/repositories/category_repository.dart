import '../../data/models/category_model.dart';
import '../entities/domain_enums.dart';

abstract class CategoryRepository {
  List<CategoryModel> getAllCategories();
  List<CategoryModel> getCategoriesByType(TransactionType type);
  CategoryModel? getCategoryById(String id);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Stream<List<CategoryModel>> watchCategories();
}
