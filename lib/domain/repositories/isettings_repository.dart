/// Interface cho cấu hình ứng dụng (Dark mode, ngày bốc xăm, ngôn ngữ...).
abstract class ISettingsRepository {
  Future<String?> getSetting(String key);
  Future<void> saveSetting(String key, String value);
  Future<void> deleteSetting(String key);
}
