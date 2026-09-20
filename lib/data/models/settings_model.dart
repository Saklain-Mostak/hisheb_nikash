import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

class SettingsModel {
  final String currencyCode;
  final String currencySymbol;
  final int themeModeIndex; // 0: system, 1: light, 2: dark
  final String languageCode; // e.g. 'en', 'bn', 'hi', 'zh', 'es', 'ar', 'fr', 'pt', 'ru', 'ur', 'id'

  const SettingsModel({
    this.currencyCode = AppConstants.defaultCurrencyCode,
    this.currencySymbol = AppConstants.defaultCurrencySymbol,
    this.themeModeIndex = 0,
    this.languageCode = 'en',
  });

  ThemeMode get themeMode {
    switch (themeModeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  SettingsModel copyWith({
    String? currencyCode,
    String? currencySymbol,
    int? themeModeIndex,
    String? languageCode,
  }) {
    return SettingsModel(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'themeModeIndex': themeModeIndex,
      'languageCode': languageCode,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currencyCode: json['currencyCode'] as String? ?? AppConstants.defaultCurrencyCode,
      currencySymbol: json['currencySymbol'] as String? ?? AppConstants.defaultCurrencySymbol,
      themeModeIndex: json['themeModeIndex'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModel &&
          runtimeType == other.runtimeType &&
          currencyCode == other.currencyCode &&
          currencySymbol == other.currencySymbol &&
          themeModeIndex == other.themeModeIndex &&
          languageCode == other.languageCode;

  @override
  int get hashCode =>
      currencyCode.hashCode ^
      currencySymbol.hashCode ^
      themeModeIndex.hashCode ^
      languageCode.hashCode;
}

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 3;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return SettingsModel(
      currencyCode: fields[0] as String? ?? AppConstants.defaultCurrencyCode,
      currencySymbol: fields[1] as String? ?? AppConstants.defaultCurrencySymbol,
      themeModeIndex: fields[2] as int? ?? 0,
      languageCode: fields[3] as String? ?? 'en',
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.currencySymbol)
      ..writeByte(2)
      ..write(obj.themeModeIndex)
      ..writeByte(3)
      ..write(obj.languageCode);
  }
}
