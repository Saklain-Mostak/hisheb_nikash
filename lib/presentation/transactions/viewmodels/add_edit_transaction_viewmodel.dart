import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/transaction_model.dart';
import '../../../domain/entities/domain_enums.dart';
import '../../common_providers.dart';

class AddEditTransactionState {
  final String? id; // null if new
  final TransactionType type;
  final double? amount;
  final String? categoryId;
  final DateTime date;
  final String? note;
  final PaymentMethod paymentMethod;
  final bool isSaving;
  final String? errorMessage;

  const AddEditTransactionState({
    this.id,
    this.type = TransactionType.expense,
    this.amount,
    this.categoryId,
    required this.date,
    this.note,
    this.paymentMethod = PaymentMethod.cash,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isEditing => id != null;

  AddEditTransactionState copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    PaymentMethod? paymentMethod,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddEditTransactionState(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AddEditTransactionNotifier extends Notifier<AddEditTransactionState> {
  final TransactionType initialType;
  final TransactionModel? existing;

  AddEditTransactionNotifier(this.initialType, this.existing);

  @override
  AddEditTransactionState build() {
    if (existing != null) {
      return AddEditTransactionState(
        id: existing!.id,
        type: existing!.type,
        amount: existing!.amount,
        categoryId: existing!.categoryId,
        date: existing!.date,
        note: existing!.note,
        paymentMethod: existing!.paymentMethod,
      );
    }

    final categories = ref.read(categoryRepositoryProvider).getCategoriesByType(initialType);
    final defaultCatId = categories.isNotEmpty ? categories.first.id : null;

    return AddEditTransactionState(
      type: initialType,
      categoryId: defaultCatId,
      date: DateTime.now(),
    );
  }

  void setType(TransactionType type) {
    if (state.type == type) return;
    final categories = ref.read(categoryRepositoryProvider).getCategoriesByType(type);
    final defaultCatId = categories.isNotEmpty ? categories.first.id : null;
    state = state.copyWith(type: type, categoryId: defaultCatId);
  }

  void setAmount(double? amount) {
    state = state.copyWith(amount: amount, clearError: true);
  }

  void setCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId, clearError: true);
  }

  void setDate(DateTime date) {
    final updated = DateTime(
      date.year,
      date.month,
      date.day,
      state.date.hour,
      state.date.minute,
    );
    state = state.copyWith(date: updated);
  }

  void setTime(int hour, int minute) {
    final updated = DateTime(
      state.date.year,
      state.date.month,
      state.date.day,
      hour,
      minute,
    );
    state = state.copyWith(date: updated);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<bool> saveTransaction() async {
    // Validation
    if (state.amount == null || state.amount! <= 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid amount greater than 0');
      return false;
    }

    if (state.categoryId == null || state.categoryId!.isEmpty) {
      state = state.copyWith(errorMessage: 'Please select a category');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final id = state.id ?? const Uuid().v4();

      final transaction = TransactionModel(
        id: id,
        amount: state.amount!,
        type: state.type,
        categoryId: state.categoryId!,
        date: state.date,
        note: state.note?.trim().isNotEmpty == true ? state.note!.trim() : null,
        paymentMethod: state.paymentMethod,
      );

      if (state.isEditing) {
        await repo.updateTransaction(transaction);
      } else {
        await repo.addTransaction(transaction);
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save transaction: $e',
      );
      return false;
    }
  }
}

final addEditTransactionProvider = NotifierProvider.autoDispose
    .family<AddEditTransactionNotifier, AddEditTransactionState, (TransactionType, TransactionModel?)>(
  (arg) => AddEditTransactionNotifier(arg.$1, arg.$2),
);
