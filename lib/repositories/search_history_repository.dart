// ---------------------------------------------------
// lib/repositories/search_history_repository.dart
// ---------------------------------------------------

import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryRepository {
  final String _boxName = 'searchHistoryBox';
  static const int _maxHistoryCount = 10;

  Box<String> get _box => Hive.box<String>(_boxName);

  List<String> getSearchHistory() {
    // Mengambil data dan membalik urutannya agar yang terbaru di atas
    return _box.values.toList().cast<String>();
  }

  Future<void> addSearchTerm(String term) async {
    final normalizedTerm = term.trim();
    if (normalizedTerm.isEmpty) return;

    // Ambil history lama
    final List<String> history = _box.values.toList().cast<String>();

    // Hapus jika sudah ada (agar tidak duplikat dan naik ke paling atas)
    history.removeWhere((item) => item.toLowerCase() == normalizedTerm.toLowerCase());

    // Masukkan ke paling depan (index 0)
    history.insert(0, normalizedTerm);

    // Simpan ulang (hanya simpan 10 terakhir)
    await _box.clear();
    await _box.addAll(history.take(_maxHistoryCount));
  }

  // --- FUNGSI BARU: Hapus 1 Item ---
  Future<void> deleteSearchTerm(String term) async {
    final List<String> history = _box.values.toList().cast<String>();
    
    // Hapus item yang cocok
    history.removeWhere((item) => item == term);
    
    // Simpan ulang list yang sudah diupdate
    await _box.clear();
    await _box.addAll(history);
  }

  // Hapus Semua
  Future<void> clearSearchHistory() async {
    await _box.clear();
  }
}