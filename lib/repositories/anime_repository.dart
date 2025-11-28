// -------------------------------------------
// lib/repositories/anime_repository.dart
// -------------------------------------------

import '../models/anime_model.dart';
import '../services/anilist_api_provider.dart';

class AnimeRepository {
  final AnilistApiProvider apiProvider;

  AnimeRepository({required this.apiProvider});

  // Return Map berisi List untuk setiap kategori
  Future<Map<String, List<AnimeModel>>> getHomeData({bool isRefresh = false}) async {
    try {
      final data = await apiProvider.getHomeData(isRefresh: isRefresh);
      
      // Helper function untuk parsing list
      List<AnimeModel> parseList(String key) {
        final List list = data[key]['media'];
        return list.map((item) => AnimeModel.fromJson(item)).toList();
      }

      return {
        'trending': parseList('trending'),
        'thisSeason': parseList('thisSeason'),
        'nextSeason': parseList('nextSeason'),
        'allTime': parseList('allTime'),
      };
    } catch (e) {
      throw Exception('Gagal memuat data home: $e');
    }
  }

  // ... (Method searchAnime dan getAnimeDetail BIARKAN TETAP SAMA)
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