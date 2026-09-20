import 'package:hive/hive.dart';
import '../../domain/entities/domain_enums.dart';

class CategoryModel {
  final String id;
  final String name;
  final TransactionType type;
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    TransactionType? type,
    int? iconCodePoint,
    int? colorValue,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      iconCodePoint: json['iconCodePoint'] as int,
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          iconCodePoint == other.iconCodePoint &&
          colorValue == other.colorValue &&
          isDefault == other.isDefault;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      iconCodePoint.hashCode ^
      colorValue.hashCode ^
      isDefault.hashCode;
}

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: TransactionType.values[fields[2] as int],
      iconCodePoint: fields[3] as int,
      colorValue: fields[4] as int,
      isDefault: fields[5] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.isDefault);
  }
}
