import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../viewmodels/categories_viewmodel.dart';
import 'add_edit_category_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    final expenseList = ref.watch(expenseCategoriesProvider);
    final incomeList = ref.watch(incomeCategoriesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.categories, style: const TextStyle(fontWeight: FontWeight.w700)),
          bottom: TabBar(
            indicatorColor: isDark ? AppColors.primaryLight : AppColors.primary,
            labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: l10n.expenseCategories),
              Tab(text: l10n.incomeCategories),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CategoryListView(categories: expenseList, type: TransactionType.expense),
            _CategoryListView(categories: incomeList, type: TransactionType.income),
          ],
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            onPressed: () {
              final tabIndex = DefaultTabController.of(ctx).index;
              final type = tabIndex == 0 ? TransactionType.expense : TransactionType.income;
              AddEditCategoryDialog.show(context, defaultType: type);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addCategory, style: const TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            foregroundColor: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CategoryListView extends ConsumerWidget {
  final List<CategoryModel> categories;
  final TransactionType type;

  const _CategoryListView({
    required this.categories,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    if (categories.isEmpty) {
      return Center(
        child: Text(
          l10n.noCategoriesFound,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final catColor = Color(cat.colorValue);
        final iconData = AppIcons.getIconData(cat.iconCodePoint);

        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: catColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getCategoryName(cat.name, cat.id),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (cat.isDefault)
                      Text(
                        l10n.defaultLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: l10n.edit,
                onPressed: () {
                  AddEditCategoryDialog.show(context, existingCategory: cat);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.expense),
                tooltip: l10n.delete,
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: l10n.deleteCategory,
                    message: '${l10n.confirmDeleteCategory} ${l10n.deleteCategoryMessage}',
                    confirmLabel: l10n.delete,
                    cancelLabel: l10n.cancel,
                    isDestructive: true,
                  );

                  if (confirmed && context.mounted) {
                    final success = await ref
                        .read(categoriesViewModelProvider.notifier)
                        .deleteCategory(cat.id);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.cannotDeleteCategoryLinked),
                          backgroundColor: AppColors.expense,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
