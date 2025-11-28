// ---------------------------------------------
// lib/data/repositories/my_list_repository.dart
// ---------------------------------------------

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ta_teori/models/my_anime_entry_model.dart';

class MyListRepository {
  
  final Box<MyAnimeEntryModel> _myListBox = 
      Hive.box<MyAnimeEntryModel>('myAnimeEntryBox');

  Future<void> addOrUpdateAnime(MyAnimeEntryModel animeEntry) async {
    await _myListBox.put(animeEntry.animeId, animeEntry);
  }

  List<MyAnimeEntryModel> getMyList() {
    return _myListBox.values.toList();
  }

  Future<void> deleteAnime(int animeId) async {
    await _myListBox.delete(animeId);
  }

  bool isInList(int animeId) {
    return _myListBox.containsKey(animeId);
  }

  MyAnimeEntryModel? getEntry(int animeId) {
    return _myListBox.get(animeId);
  }
}
