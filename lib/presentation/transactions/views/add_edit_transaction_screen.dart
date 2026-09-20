import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';
import '../viewmodels/add_edit_transaction_viewmodel.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;
  final TransactionModel? existingTransaction;

  const AddEditTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
    this.existingTransaction,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final FocusNode _amountFocusNode;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(existing.amount % 1 == 0 ? 0 : 2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _amountFocusNode = FocusNode();

    // Auto-focus amount field when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.existingTransaction == null) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final currencySymbol = ref.watch(currencySymbolProvider);

    final providerKey = (widget.initialType, widget.existingTransaction);
    final state = ref.watch(addEditTransactionProvider(providerKey));
    final notifier = ref.read(addEditTransactionProvider(providerKey).notifier);

    final isIncome = state.type == TransactionType.income;
    final activeTypeColor = isIncome ? AppColors.income : AppColors.expense;

    // Get categories for selected type
    final allCategories = ref.watch(categoriesStreamProvider).value ?? [];
    final matchingCategories =
        allCategories.where((c) => c.type == state.type).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.isEditing ? l10n.editTransaction : l10n.addTransaction,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Type Selector (Expense / Income)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TypeButton(
                              label: l10n.filterExpense,
                              icon: Icons.remove_circle_outline_rounded,
                              isSelected: state.type == TransactionType.expense,
                              activeColor: AppColors.expense,
                              onTap: () => notifier.setType(TransactionType.expense),
                            ),
                          ),
                          Expanded(
                            child: _TypeButton(
                              label: l10n.filterIncome,
                              icon: Icons.add_circle_outline_rounded,
                              isSelected: state.type == TransactionType.income,
                              activeColor: AppColors.income,
                              onTap: () => notifier.setType(TransactionType.income),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Amount Input (Large, Prominent, Auto-focused)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.errorMessage != null && (state.amount == null || state.amount! <= 0)
                              ? AppColors.expense
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            currencySymbol,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: activeTypeColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: activeTypeColor,
                                letterSpacing: -0.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                              onChanged: (val) {
                                final parsed = double.tryParse(val);
                                notifier.setAmount(parsed);
                              },
                            ),
                          ),
                          if (_amountController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _amountController.clear();
                                notifier.setAmount(null);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Selector Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.category,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/categories'),
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: Text(l10n.manage, style: const TextStyle(fontSize: 13)),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category Grid / List
                    if (matchingCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          l10n.noCategoriesFound,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: matchingCategories.map((cat) {
                          final isSelected = state.categoryId == cat.id;
                          final catColor = Color(cat.colorValue);
                          final iconData = AppIcons.getIconData(cat.iconCodePoint);

                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  iconData,
                                  size: 16,
                                  color: isSelected ? Colors.white : catColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.getCategoryName(cat.name, cat.id),
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: catColor,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant,
                            onSelected: (_) => notifier.setCategory(cat.id),
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    // Date & Time Row
                    Text(
                      l10n.dateTime,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Date Picker Button
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: state.date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                notifier.setDate(picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      DateFormatter.formatDate(state.date),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Time Picker Button
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(state.date),
                              );
                              if (time != null) {
                                notifier.setTime(time.hour, time.minute);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      DateFormatter.formatTime(state.date),
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Section
                    Text(
                      l10n.paymentMethod,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: PaymentMethod.values.map((method) {
                          final isSelected = state.paymentMethod == method;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    method.icon,
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.primaryLight : AppColors.primary),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.getPaymentMethodName(method),
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: isDark ? AppColors.primaryDark : AppColors.primary,
                              backgroundColor: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.lightSurfaceVariant,
                              onSelected: (_) => notifier.setPaymentMethod(method),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Note Input Field
                    Text(
                      l10n.noteOptional,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: l10n.noteHint,
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      ),
                      maxLines: 2,
                      onChanged: notifier.setNote,
                    ),
                    const SizedBox(height: 16),

                    // Error Message display
                    if (state.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.expense, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.errorMessage == 'Please enter a valid amount greater than 0'
                                    ? l10n.enterValidAmount
                                    : state.errorMessage == 'Please select a category'
                                        ? l10n.selectCategoryError
                                        : state.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.expense,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Save Transaction Button (Fixed at bottom)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final success = await notifier.saveTransaction();
                        if (success && context.mounted) {
                          context.pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTypeColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isEditing ? Icons.check_rounded : Icons.save_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.isEditing ? l10n.updateTransaction : l10n.saveTransaction,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
