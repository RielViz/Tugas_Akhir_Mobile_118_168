// --------------------------------
// lib/core/api/graphql_client.dart
// --------------------------------

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

class GraphQLClientConfig {
  //URL endpoint untuk AniList API
  static final HttpLink _httpLink = HttpLink(
    'https://graphql.anilist.co',
  );
  //Inisialisasi GraphQL Client
  static ValueNotifier<GraphQLClient> initializeClient(Box graphqlBox) {
    final Link link = _httpLink;

    return ValueNotifier(
      GraphQLClient(
        link: link,
      cache: GraphQLCache(store: InMemoryStore()),      ),
    );
  }
}