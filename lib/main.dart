// ---------------------------------------------------
// lib/main.dart (REVISI)
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ta_teori/core/api/graphql_client.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:ta_teori/core/services/notification_service.dart';

// Import model
import 'package:ta_teori/data/models/user_model.dart';
import 'package:ta_teori/data/models/saran_kesan_model.dart';
import 'package:ta_teori/data/models/my_anime_entry_model.dart';

// Import provider
import 'package:ta_teori/data/providers/anilist_api_provider.dart';

// Import repository
import 'package:ta_teori/data/repositories/auth_repository.dart';
import 'package:ta_teori/data/repositories/anime_repository.dart';
import 'package:ta_teori/data/repositories/my_list_repository.dart';
import 'package:ta_teori/data/repositories/saran_kesan_repository.dart';
import 'package:ta_teori/data/repositories/location_repository.dart';
import 'package:ta_teori/data/repositories/search_history_repository.dart';

// Import BLoC & Screen
import 'package:ta_teori/features/auth/bloc/auth_bloc.dart';
import 'package:ta_teori/features/auth/screens/login_screen.dart';
import 'package:ta_teori/features/my_list/bloc/my_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  await NotificationService().init();
  await Hive.initFlutter();
  await initHiveForFlutter();

  // Daftarkan semua Adapter
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(SaranKesanAdapter());
  Hive.registerAdapter(MyAnimeEntryModelAdapter());

  // Buka semua Box kustom
  await Hive.openBox<User>('userBox');
  await Hive.openBox<SaranKesan>('saranKesanBox');
  await Hive.openBox<MyAnimeEntryModel>('myAnimeEntryBox');
  await Hive.openBox('graphqlClientStore');
  await Hive.openBox<String>('searchHistoryBox');

  final client = GraphQLClientConfig.initializeClient();

  runApp(MyApp(graphqlClient: client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> graphqlClient;

  const MyApp({super.key, required this.graphqlClient});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: graphqlClient,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository(),
          ),
          RepositoryProvider<AnilistApiProvider>(
            create: (context) {
              final client = graphqlClient.value;
              return AnilistApiProvider(client: client);
            },
          ),
          RepositoryProvider<AnimeRepository>(
            create: (context) => AnimeRepository(
                apiProvider: context.read<AnilistApiProvider>()),
          ),
          RepositoryProvider<MyListRepository>(
            create: (context) => MyListRepository(),
          ),
          RepositoryProvider<SaranKesanRepository>(
            create: (context) => SaranKesanRepository(),
          ),
          RepositoryProvider<LocationRepository>(
            create: (context) => LocationRepository(),
          ),
          RepositoryProvider<SearchHistoryRepository>(
            create: (context) => SearchHistoryRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
            BlocProvider<MyListBloc>(
              create: (context) => MyListBloc(
                myListRepository: context.read<MyListRepository>(),
              )..add(LoadMyList()),
            ),
          ],
          child: MaterialApp(
            title: 'Anime App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            ),
            home: const LoginPage(),
          ),
        ),
      ),
    );
  }
}