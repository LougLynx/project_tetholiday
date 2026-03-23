import 'package:flutter/foundation.dart';
import 'package:project_tetholiday/di.dart';
import 'package:project_tetholiday/domain/entities/tip.dart';

class ExploreDishViewModel extends ChangeNotifier {
  TipCategory _selectedCategory = TipCategory.all;
  String _searchQuery = '';
  
  TipInfo? _featuredTip;
  List<TipInfo> _tips = [];
  bool _isLoading = true;

  TipCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  TipInfo? get featuredTip => _featuredTip;
  List<TipInfo> get tips => _tips;
  bool get isLoading => _isLoading;

  ExploreDishViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _featuredTip = await Di.tipRepository.getFeaturedTip();
      
      final categoryFilter = _selectedCategory == TipCategory.all ? null : _selectedCategory;
      final allTips = await Di.tipRepository.getTips(category: categoryFilter);
      
      // Filter out featured
      var filtered = allTips.where((t) => !t.isFeatured).toList();
      
      // Apply search
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((t) => _matchesSearch(t, _searchQuery)).toList();
      }
      
      _tips = filtered;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(TipCategory category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      loadData();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      loadData();
    }
  }

  Future<void> incrementTipViewCount(String tipId) async {
    await Di.tipRepository.incrementTipViewCount(tipId);
  }

  static bool _matchesSearch(TipInfo tip, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return tip.title.toLowerCase().contains(q) ||
        (tip.subtitle?.toLowerCase().contains(q) ?? false) ||
        tip.content.toLowerCase().contains(q) ||
        tip.category.label.toLowerCase().contains(q) ||
        (tip.tags?.toLowerCase().contains(q) ?? false);
  }

}
