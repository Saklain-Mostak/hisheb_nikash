import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../viewmodels/categories_viewmodel.dart';

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel? existingCategory;
  final TransactionType defaultType;

  const AddEditCategoryDialog({
    super.key,
    this.existingCategory,
    this.defaultType = TransactionType.expense,
  });

  static Future<bool> show(
    BuildContext context, {
    CategoryModel? existingCategory,
    TransactionType defaultType = TransactionType.expense,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        existingCategory: existingCategory,
        defaultType: defaultType,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<AddEditCategoryDialog> createState() =>
      _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  late final TextEditingController _nameController;
  late TransactionType _type;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingCategory;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _type = existing?.type ?? widget.defaultType;
    _selectedIconCodePoint = existing?.iconCodePoint ?? AppIcons.availableIcons.first.icon.codePoint;
    _selectedColorValue = existing?.colorValue ?? AppColors.categoryColors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final isEditing = widget.existingCategory != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? l10n.editCategory : l10n.newCategory,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              // Category Name Input
              TextField(
                controller: _nameController,
                autofocus: !isEditing,
                decoration: InputDecoration(
                  labelText: l10n.categoryNameLabel,
                  hintText: l10n.categoryNameHint,
                  prefixIcon: Icon(
                    AppIcons.getIconData(_selectedIconCodePoint),
                    color: Color(_selectedColorValue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Type Selector
              if (!isEditing) ...[
                Text(l10n.type, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(l10n.filterExpense)),
                        selected: _type == TransactionType.expense,
                        selectedColor: AppColors.expenseLight,
                        onSelected: (_) => setState(() => _type = TransactionType.expense),
                        showCheckmark: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(child: Text(l10n.filterIncome)),
                        selected: _type == TransactionType.income,
                        selectedColor: AppColors.incomeLight,
                        onSelected: (_) => setState(() => _type = TransactionType.income),
                        showCheckmark: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Icon Picker
              Text(l10n.selectIcon, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: AppIcons.availableIcons.length,
                  itemBuilder: (context, index) {
                    final item = AppIcons.availableIcons[index];
                    final isSelected = item.icon.codePoint == _selectedIconCodePoint;
                    return InkWell(
                      onTap: () => setState(() => _selectedIconCodePoint = item.icon.codePoint),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColorValue).withValues(alpha: 0.2)
                              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: Color(_selectedColorValue), width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? Color(_selectedColorValue)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Color Picker
              Text(l10n.selectColor, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.categoryColors.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final color = AppColors.categoryColors[index];
                    final isSelected = color.toARGB32() == _selectedColorValue;
                    return InkWell(
                      onTap: () => setState(() => _selectedColorValue = color.toARGB32()),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage == 'Category name cannot be empty'
                      ? l10n.categoryNameEmpty
                      : _errorMessage!,
                  style: const TextStyle(color: AppColors.expense, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
              ],

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) {
                        setState(() => _errorMessage = 'Category name cannot be empty');
                        return;
                      }

                      final notifier = ref.read(categoriesViewModelProvider.notifier);
                      bool ok;
                      if (isEditing) {
                        final updated = widget.existingCategory!.copyWith(
                          name: name,
                          iconCodePoint: _selectedIconCodePoint,
                          colorValue: _selectedColorValue,
                        );
                        ok = await notifier.updateCategory(updated);
                      } else {
                        ok = await notifier.addCategory(
                          name: name,
                          type: _type,
                          iconCodePoint: _selectedIconCodePoint,
                          colorValue: _selectedColorValue,
                        );
                      }

                      if (ok && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(_selectedColorValue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isEditing ? l10n.saveChanges : l10n.createCategory),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
