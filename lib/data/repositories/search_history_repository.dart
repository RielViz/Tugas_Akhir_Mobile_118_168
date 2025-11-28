// ---------------------------------------------------
// lib/data/repositories/search_history_repository.dart
// ---------------------------------------------------

import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryRepository {
  final String _boxName = 'searchHistoryBox';
  static const int _maxHistoryCount = 10;

  Box<String> get _box => Hive.box<String>(_boxName);

  List<String> getSearchHistory() {
    return _box.values.toList();
  }

  Future<void> addSearchTerm(String term) async {
    final normalizedTerm = term.trim().toLowerCase();
    
    if (normalizedTerm.isEmpty) return;

    final List<String> history = _box.values.toList();

    history.removeWhere((item) => item.toLowerCase() == normalizedTerm);

    history.insert(0, normalizedTerm);
    await _box.clear();
    
    await _box.addAll(history.take(_maxHistoryCount));
  }

  Future<void> clearSearchHistory() async {
    await _box.clear();
  }
}