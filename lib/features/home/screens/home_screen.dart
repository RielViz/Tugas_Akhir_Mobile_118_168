// ------------------------------------------
// lib/features/home/screens/home_screen.dart
// ------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/data/repositories/anime_repository.dart';
import 'package:ta_teori/features/anime_detail/screens/anime_detail_screen.dart';
import 'package:ta_teori/features/home/bloc/home_bloc.dart';
import 'package:ta_teori/core/widgets/anime_card.dart';

//"Halaman Wrapper" yang menyediakan BLoC
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        animeRepository: RepositoryProvider.of<AnimeRepository>(context),
      )
        ..add(const FetchHomeData()),
      child: const HomeView(),
    );
  }
}

// Ini adalah UI Halaman Home yang sebenarnya
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Now🔥'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HomeBloc>().add(const FetchHomeData(isRefresh: true));
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HomeLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.popularAnime.length,
              itemBuilder: (context, index) {
                final anime = state.popularAnime[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AnimeDetailScreen(animeId: anime.id),
                      ),
                    );
                  },
                  child: AnimeCard(anime: anime),
                );
              },
            );
          }

          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat data:\n${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return const Center(child: Text('Terjadi kesalahan.'));
        },
      ),
    );
  }
}