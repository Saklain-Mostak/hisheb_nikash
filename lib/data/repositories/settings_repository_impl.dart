import '../../domain/repositories/settings_repository.dart';
import '../datasources/hive_service.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final HiveService _hiveService;

  SettingsRepositoryImpl(this._hiveService);

  @override
  SettingsModel getSettings() {
    return _hiveService.settingsBox.get('settings') ?? const SettingsModel();
  }

  @override
  Future<void> updateSettings(SettingsModel settings) async {
    await _hiveService.settingsBox.put('settings', settings);
  }

  @override
  Stream<SettingsModel> watchSettings() async* {
    yield getSettings();
    yield* _hiveService.settingsBox.watch(key: 'settings').map((_) => getSettings());
  }
}
