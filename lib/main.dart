// ---------------------------------------------------
// lib/main.dart
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;

// Services
import 'services/notification_service.dart';
import 'services/graphql_client.dart';
import 'services/anilist_api_provider.dart';

// Models
import 'models/user_model.dart';
import 'models/my_anime_entry_model.dart';

// Repositories
import 'repositories/auth_repository.dart';
import 'repositories/anime_repository.dart';
import 'repositories/my_list_repository.dart';
import 'repositories/search_history_repository.dart';

// Logic (BLoC)
import 'logic/auth_bloc.dart';
import 'logic/my_list_bloc.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  await NotificationService().init();
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(MyAnimeEntryModelAdapter()); // Pastikan tanpa 'as TypeAdapter'

  // Open Boxes
  await Hive.openBox<User>('userBox');
  await Hive.openBox<MyAnimeEntryModel>('myAnimeEntryBox');
  await Hive.openBox('graphqlClientStore'); // Buka box untuk cache API
  await Hive.openBox<String>('searchHistoryBox');
  await Hive.openBox('sessionBox');

  // Ambil box yang sudah dibuka
  final graphqlBox = Hive.box('graphqlClientStore');
  
  // Kirim ke config (sekarang tipenya cocok: Box<dynamic>)
  final client = GraphQLClientConfig.initializeClient(graphqlBox);

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
              create: (context) => AuthRepository()),
          RepositoryProvider<AnilistApiProvider>(create: (context) {
            final client = graphqlClient.value;
            return AnilistApiProvider(client: client);
          }),
          RepositoryProvider<AnimeRepository>(
              create: (context) => AnimeRepository(
                  apiProvider: context.read<AnilistApiProvider>())),
          RepositoryProvider<MyListRepository>(
              create: (context) => MyListRepository()),
          RepositoryProvider<SearchHistoryRepository>(
              create: (context) => SearchHistoryRepository())
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              )..add(AuthCheckSession()), 
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
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const MainShell();
                }
                return const LoginPage();
              },
            ),
          ),
        ),
      ),
    );
  }
}