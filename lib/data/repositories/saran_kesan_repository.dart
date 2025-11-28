// -------------------------------------------------
// lib/data/repositories/saran_kesan_repository.dart
// -------------------------------------------------

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ta_teori/data/models/saran_kesan_model.dart';

class SaranKesanRepository {
  
  final Box<SaranKesan> _box = Hive.box<SaranKesan>('saranKesanBox');
  final String _entryKey = 'saranKesanEntry';

  Future<void> saveSaranKesan(String saran, String kesan) async {
    final entry = SaranKesan(
      saran: saran,
      kesan: kesan,
      timestamp: DateTime.now(),
    );
    await _box.put(_entryKey, entry);
  }

  SaranKesan? getSaranKesan() {
    return _box.get(_entryKey);
  }
}