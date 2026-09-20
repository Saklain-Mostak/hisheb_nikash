import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/debt_model.dart';
import '../../common_providers.dart';

class RecordPaymentDialog extends ConsumerStatefulWidget {
  final DebtModel debt;

  const RecordPaymentDialog({super.key, required this.debt});

  static Future<bool> show(BuildContext context, DebtModel debt) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RecordPaymentDialog(debt: debt),
    );
    return result ?? false;
  }

  @override
  ConsumerState<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  late final TextEditingController _amountController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.debt.remainingAmount.toStringAsFixed(widget.debt.remainingAmount % 1 == 0 ? 0 : 2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final currencySymbol = ref.watch(currencySymbolProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      title: Text(l10n.recordPayment, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.person}: ${widget.debt.personName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.remainingDue}: ${CurrencyFormatter.format(widget.debt.remainingAmount, symbol: currencySymbol)}',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: l10n.paymentAmount,
              prefixText: '$currencySymbol ',
              errorText: _errorMessage,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final val = double.tryParse(_amountController.text);
            if (val == null || val <= 0) {
              setState(() => _errorMessage = l10n.enterAmountGreaterThanZero);
              return;
            }

            await ref.read(debtRepositoryProvider).recordPayment(widget.debt.id, val);
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(l10n.savePayment),
        ),
      ],
    );
  }
}
