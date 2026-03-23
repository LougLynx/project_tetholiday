abstract interface class IFortuneRepository {
  Future<Map<String, String>> generateDailyFortune();
}
