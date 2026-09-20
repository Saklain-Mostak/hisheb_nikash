import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/debt_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class AddEditDebtScreen extends ConsumerStatefulWidget {
  final DebtModel? existingDebt;
  final DebtType initialType;

  const AddEditDebtScreen({
    super.key,
    this.existingDebt,
    this.initialType = DebtType.gave,
  });

  @override
  ConsumerState<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends ConsumerState<AddEditDebtScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late DebtType _type;
  late DateTime _date;
  DateTime? _dueDate;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingDebt;
    _nameController = TextEditingController(text: existing?.personName ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(existing.amount % 1 == 0 ? 0 : 2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _type = existing?.type ?? widget.initialType;
    _date = existing?.date ?? DateTime.now();
    _dueDate = existing?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final isEditing = widget.existingDebt != null;

    final activeColor = _type == DebtType.gave ? AppColors.lentColor : AppColors.borrowedColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Debt / Loan' : 'Add Debt / Loan',
          style: const TextStyle(fontWeight: FontWeight.w700),
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
                    // Type selector: Money I gave vs Money I received
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DebtTypeChip(
                              label: 'Money I gave',
                              sublabel: '(You will receive)',
                              isSelected: _type == DebtType.gave,
                              activeColor: AppColors.lentColor,
                              onTap: () => setState(() => _type = DebtType.gave),
                            ),
                          ),
                          Expanded(
                            child: _DebtTypeChip(
                              label: 'Money I received',
                              sublabel: '(You need to pay)',
                              isSelected: _type == DebtType.received,
                              activeColor: AppColors.borrowedColor,
                              onTap: () => setState(() => _type = DebtType.received),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Person Name Input
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Person Name *',
                        hintText: 'e.g. Rahim, John Doe, Store',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Total Amount *',
                        prefixText: '$currencySymbol ',
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dates Row (Date given/received & Due Date)
                    Row(
                      children: [
                        // Date
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => _date = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormatter.formatDate(_date),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Due Date
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate ?? _date.add(const Duration(days: 30)),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => _dueDate = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Due Date (Opt)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      if (_dueDate != null)
                                        InkWell(
                                          onTap: () => setState(() => _dueDate = null),
                                          child: const Icon(Icons.close_rounded, size: 14),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dueDate != null ? DateFormatter.formatDate(_dueDate!) : 'Not set',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: _dueDate != null ? null : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Note Input
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText: 'Add description or purpose',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Save Button
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
                onPressed: _isSaving
                    ? null
                    : () async {
                        final personName = _nameController.text.trim();
                        final amount = double.tryParse(_amountController.text);

                        if (personName.isEmpty) {
                          setState(() => _errorMessage = 'Please enter the person name');
                          return;
                        }
                        if (amount == null || amount <= 0) {
                          setState(() => _errorMessage = 'Please enter a valid amount greater than 0');
                          return;
                        }

                        setState(() {
                          _isSaving = true;
                          _errorMessage = null;
                        });

                        try {
                          final repo = ref.read(debtRepositoryProvider);
                          final id = widget.existingDebt?.id ?? const Uuid().v4();
                          final paidAmount = widget.existingDebt?.paidAmount ?? 0.0;
                          final status = paidAmount >= amount
                              ? DebtStatus.paid
                              : (paidAmount > 0 ? DebtStatus.partiallyPaid : DebtStatus.pending);

                          final debt = DebtModel(
                            id: id,
                            personName: personName,
                            amount: amount,
                            paidAmount: paidAmount,
                            type: _type,
                            date: _date,
                            dueDate: _dueDate,
                            note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
                            status: status,
                          );

                          if (isEditing) {
                            await repo.updateDebt(debt);
                          } else {
                            await repo.addDebt(debt);
                          }

                          if (context.mounted) {
                            context.pop();
                          }
                        } catch (e) {
                          setState(() {
                            _isSaving = false;
                            _errorMessage = 'Failed to save: $e';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Text(
                  isEditing ? 'Update Loan' : 'Save Loan',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtTypeChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _DebtTypeChip({
    required this.label,
    required this.sublabel,
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 13,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
