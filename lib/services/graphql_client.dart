// --------------------------------
// lib/services/graphql_client.dart
// --------------------------------

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GraphQLClientConfig {
  static final HttpLink _httpLink = HttpLink('https://graphql.anilist.co');

  static ValueNotifier<GraphQLClient> initializeClient(Box<dynamic> box) {
    final Link link = _httpLink;

    return ValueNotifier(
      GraphQLClient(
        link: link,
        // PERBAIKAN: Masukkan variabel 'box' di sini!
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
  }
}
