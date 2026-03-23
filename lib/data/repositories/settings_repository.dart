import 'package:project_tetholiday/domain/repositories/isettings_repository.dart';
import 'package:project_tetholiday/data/database/app_database.dart';

class SettingsRepository implements ISettingsRepository {
  final AppDatabase _db = AppDatabase.instance;

  @override
  Future<String?> getSetting(String key) => _db.getSetting(key);

  @override
  Future<void> saveSetting(String key, String value) => _db.setSetting(key, value);

  @override
  Future<void> deleteSetting(String key) => _db.deleteSetting(key);
}
