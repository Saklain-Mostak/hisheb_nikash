import 'package:hive/hive.dart';
import '../../domain/entities/domain_enums.dart';

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final PaymentMethod paymentMethod;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.paymentMethod = PaymentMethod.cash,
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
    PaymentMethod? paymentMethod,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'paymentMethod': paymentMethod.name,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          type == other.type &&
          categoryId == other.categoryId &&
          date == other.date &&
          note == other.note &&
          paymentMethod == other.paymentMethod;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      categoryId.hashCode ^
      date.hashCode ^
      note.hashCode ^
      paymentMethod.hashCode;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return TransactionModel(
      id: fields[0] as String,
      amount: (fields[1] as num).toDouble(),
      type: TransactionType.values[fields[2] as int],
      categoryId: fields[3] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      note: fields[5] as String?,
      paymentMethod: fields[6] != null
          ? PaymentMethod.values[fields[6] as int]
          : PaymentMethod.cash,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.paymentMethod.index);
  }
}
