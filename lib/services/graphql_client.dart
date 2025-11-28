// --------------------------------
// lib/services/graphql_client.dart
// --------------------------------

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GraphQLClientConfig {
  static final HttpLink _httpLink = HttpLink(
    'https://graphql.anilist.co',
  );

  // PERBAIKAN: Hapus tanda '?' setelah Box<dynamic>
  // Ubah 'Box<dynamic>? box' menjadi 'Box<dynamic> box'
  static ValueNotifier<GraphQLClient> initializeClient(Box<dynamic> box) {
    final Link link = _httpLink;

    return ValueNotifier(
      GraphQLClient(
        link: link,
        // Sekarang 'box' sudah pasti tidak null, jadi bisa langsung dipakai
        cache: GraphQLCache(store: HiveStore()), 
      ),
    );
  }
}