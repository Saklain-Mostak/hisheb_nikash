import '../../data/models/settings_model.dart';

abstract class SettingsRepository {
  SettingsModel getSettings();
  Future<void> updateSettings(SettingsModel settings);
  Stream<SettingsModel> watchSettings();
}
