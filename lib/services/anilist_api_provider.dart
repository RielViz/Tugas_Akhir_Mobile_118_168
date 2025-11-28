// ---------------------------------------------------------
// lib/services/anilist_api_provider.dart
// ---------------------------------------------------------

import 'package:graphql_flutter/graphql_flutter.dart';

class AnilistApiProvider {
  final GraphQLClient client;

  AnilistApiProvider({required this.client});

  // Helper untuk mendapatkan Season & Tahun saat ini
  Map<String, dynamic> _getCurrentSeason() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;
    String season;
    String nextSeason;
    int nextYear = year;

    if (month >= 1 && month <= 3) {
      season = 'WINTER';
      nextSeason = 'SPRING';
    } else if (month >= 4 && month <= 6) {
      season = 'SPRING';
      nextSeason = 'SUMMER';
    } else if (month >= 7 && month <= 9) {
      season = 'SUMMER';
      nextSeason = 'FALL';
    } else {
      season = 'FALL';
      nextSeason = 'WINTER';
      nextYear = year + 1;
    }

    return {
      'season': season,
      'year': year,
      'nextSeason': nextSeason,
      'nextYear': nextYear,
    };
  }

  Future<Map<String, dynamic>> getHomeData({bool isRefresh = false}) async {
    final seasonData = _getCurrentSeason();

    // UBAH perPage JADI 20 AGAR SCROLL LEBIH PANJANG
    final String queryString = """
      query(\$season: MediaSeason, \$year: Int, \$nextSeason: MediaSeason, \$nextYear: Int) {
        trending: Page(page: 1, perPage: 20) { 
          media(type: ANIME, sort: TRENDING_DESC) {
            ...mediaFields
          }
        }
        thisSeason: Page(page: 1, perPage: 20) {
          media(type: ANIME, season: \$season, seasonYear: \$year, sort: POPULARITY_DESC) {
            ...mediaFields
          }
        }
        nextSeason: Page(page: 1, perPage: 20) {
          media(type: ANIME, season: \$nextSeason, seasonYear: \$nextYear, sort: POPULARITY_DESC) {
            ...mediaFields
          }
        }
        allTime: Page(page: 1, perPage: 20) {
          media(type: ANIME, sort: POPULARITY_DESC) {
            ...mediaFields
          }
        }
      }

      fragment mediaFields on Media {
        id
        title {
          romaji
          english
        }
        coverImage {
          large
        }
        averageScore
        genres
        status
        episodes
        season
        seasonYear
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      fetchPolicy: FetchPolicy.noCache, // Tetap noCache agar aman dari error hive
      variables: {
        'season': seasonData['season'],
        'year': seasonData['year'],
        'nextSeason': seasonData['nextSeason'],
        'nextYear': seasonData['nextYear'],
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!;
  }

  Future<Map<String, dynamic>> searchAnime(String query) async {
    const String queryString = """
      query (\$search: String) { 
        Page(page: 1, perPage: 20) {
          media(type: ANIME, search: \$search, sort: [POPULARITY_DESC]) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            averageScore
            genres
            status
            season
            seasonYear
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      variables: {'search': query},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return result.data!;
  }

  Future<Map<String, dynamic>> getAnimeDetail(int animeId) async {
    const String queryString = """
      query (\$id: Int) {
        Media(id: \$id, type: ANIME) {
          id
          title { romaji english }
          coverImage { large }
          averageScore
          description(asHtml: false)
          genres
          status
          episodes
          season
          seasonYear
          trailer { id site }
          characters(sort: ROLE, perPage: 6) {
            nodes {
              name { full }
              image { large }
            }
          }
          recommendations(sort: RATING_DESC, perPage: 5) {
            nodes {
              mediaRecommendation {
                id
                title { romaji english }
                coverImage { large }
                averageScore
              }
            }
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      variables: {'id': animeId},
      fetchPolicy: FetchPolicy.networkOnly, 
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['Media'];
  }
}