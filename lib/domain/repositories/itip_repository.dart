import 'package:project_tetholiday/domain/entities/tip.dart';

abstract interface class ITipRepository {
  Future<List<TipInfo>> getTips({TipCategory? category});
  Future<TipInfo?> getFeaturedTip();
  Future<TipInfo?> getTipById(String id);
  Future<void> incrementTipViewCount(String id);
}
