// -------------------------------------------
// lib/data/repositories/anime_repository.dart
// -------------------------------------------

import 'package:ta_teori/models/anime_model.dart';
import 'package:ta_teori/services/anilist_api_provider.dart';

class AnimeRepository {
  final AnilistApiProvider apiProvider;

  AnimeRepository({required this.apiProvider});

  Future<List<AnimeModel>> getPopularAnime(
      {bool isRefresh = false}) async { 
    try {
      final data = await apiProvider.getPopularAnime(isRefresh: isRefresh);
      final List mediaList = data['Page']['media'];

      return mediaList.map((item) => AnimeModel.fromJson(item)).toList();
    } catch (e) {
      
      throw Exception('Gagal memuat data anime: $e');
    }
  }

  Future<List<AnimeModel>> searchAnime(String query) async {
    try {
      final data = await apiProvider.searchAnime(query);
      final List mediaList = data['Page']['media'];
      return mediaList.map((item) => AnimeModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mencari anime: $e');
    }
  }

  Future<AnimeModel> getAnimeDetail(int animeId) async {
    try {
      final data = await apiProvider.getAnimeDetail(animeId);
      return AnimeModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail anime: $e');
    }
  }
}