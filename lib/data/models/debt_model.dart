import 'package:hive/hive.dart';
import '../../domain/entities/domain_enums.dart';

class DebtModel {
  final String id;
  final String personName;
  final double amount;
  final double paidAmount;
  final DebtType type;
  final DateTime date;
  final DateTime? dueDate;
  final String? note;
  final DebtStatus status;

  const DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    this.paidAmount = 0.0,
    required this.type,
    required this.date,
    this.dueDate,
    this.note,
    this.status = DebtStatus.pending,
  });

  double get remainingAmount => (amount - paidAmount).clamp(0.0, double.infinity);
  bool get isFullyPaid => paidAmount >= amount;

  DebtModel copyWith({
    String? id,
    String? personName,
    double? amount,
    double? paidAmount,
    DebtType? type,
    DateTime? date,
    DateTime? dueDate,
    String? note,
    DebtStatus? status,
  }) {
    return DebtModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      type: type ?? this.type,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'paidAmount': paidAmount,
      'type': type.name,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'note': note,
      'status': status.name,
    };
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      personName: json['personName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      type: DebtType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DebtType.gave,
      ),
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      note: json['note'] as String?,
      status: DebtStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DebtStatus.pending,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          personName == other.personName &&
          amount == other.amount &&
          paidAmount == other.paidAmount &&
          type == other.type &&
          date == other.date &&
          dueDate == other.dueDate &&
          note == other.note &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      personName.hashCode ^
      amount.hashCode ^
      paidAmount.hashCode ^
      type.hashCode ^
      date.hashCode ^
      dueDate.hashCode ^
      note.hashCode ^
      status.hashCode;
}

class DebtModelAdapter extends TypeAdapter<DebtModel> {
  @override
  final int typeId = 2;

  @override
  DebtModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DebtModel(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      paidAmount: (fields[3] as num?)?.toDouble() ?? 0.0,
      type: DebtType.values[fields[4] as int],
      date: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      dueDate: fields[6] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int)
          : null,
      note: fields[7] as String?,
      status: DebtStatus.values[fields[8] as int],
    );
  }

  @override
  void write(BinaryWriter writer, DebtModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paidAmount)
      ..writeByte(4)
      ..write(obj.type.index)
      ..writeByte(5)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.dueDate?.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.status.index);
  }
}
