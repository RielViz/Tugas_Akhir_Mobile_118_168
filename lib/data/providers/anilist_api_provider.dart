// --------------------------------------------
// lib/data/providers/anilist_api_provider.dart
// --------------------------------------------

import 'package:graphql_flutter/graphql_flutter.dart';

class AnilistApiProvider {
  final GraphQLClient client;

  AnilistApiProvider({required this.client});

  Future<Map<String, dynamic>> getPopularAnime(
      {bool isRefresh = false}) async {
    //"script" query GraphQL
    final String queryString = """
      query {
        Page(page: 1, perPage: 20) {
          media(type: ANIME, sort: [POPULARITY_DESC]) {
            id
            title {
              romaji
              english
            }
            coverImage {
              large
            }
            averageScore
          }
        }
      }
    """;

    //FETCH POLICY
    final fetchPolicy =
        isRefresh ? FetchPolicy.networkOnly : FetchPolicy.cacheFirst;

    //opsi query dengan fetchPolicy
    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      fetchPolicy: fetchPolicy, // <-- 4. TERAPKAN POLICY
    );

    //Panggil API
    final QueryResult result = await client.query(options);

    //Cek untuk error
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    //Kembalikan data mentahnya
    return result.data!;
  }

  
  Future<Map<String, dynamic>> searchAnime(String query) async {
    final String queryString = """
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
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      variables: {
        'search': query, 
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return result.data!;
  }

  
  Future<Map<String, dynamic>> getAnimeDetail(int animeId) async {
    final String queryString = """
      query (\$id: Int) {
        Media(id: \$id, type: ANIME) {
          id
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          averageScore
          description(asHtml: false)
          genres
        }
      }
    """;

    
    final QueryOptions options = QueryOptions(
      document: gql(queryString),
      variables: {
        'id': animeId, 
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data!['Media'];
  }
}