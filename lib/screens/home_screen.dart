// ---------------------------------------------------------
// lib/screens/home_screen.dart
// ---------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/anime_repository.dart';
import '../logic/home_bloc.dart';
import '../models/anime_model.dart';
import '../widgets/anime_card.dart';
import 'anime_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        animeRepository: RepositoryProvider.of<AnimeRepository>(context),
      )..add(const FetchHomeData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AniList Home', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HomeBloc>().add(const FetchHomeData(isRefresh: true)),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<HomeBloc>().add(const FetchHomeData(isRefresh: true)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TRENDING
                    _buildSectionHeader("TRENDING NOW"),
                    _buildHorizontalList(context, state.trending),

                    // THIS SEASON
                    _buildSectionHeader("POPULAR THIS SEASON"),
                    _buildHorizontalList(context, state.thisSeason),

                    // NEXT SEASON
                    _buildSectionHeader("UPCOMING NEXT SEASON"),
                    _buildHorizontalList(context, state.nextSeason),

                    // ALL TIME
                    _buildSectionHeader("ALL TIME POPULAR"),
                    _buildHorizontalList(context, state.allTime),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          if (state is HomeError) {
            return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget Header Simpel (Tanpa View All)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.white, // Pastikan kontras dengan background gelap
        ),
      ),
    );
  }

  // Widget List Horizontal (Bisa digeser)
  Widget _buildHorizontalList(BuildContext context, List<AnimeModel> animeList) {
    return SizedBox(
      height: 230, // Tinggi area list sedikit ditambah agar tidak terpotong
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal, // Fitur scroll ke samping
        physics: const BouncingScrollPhysics(), // Efek pantul saat mentok (iOS style)
        itemCount: animeList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final anime = animeList[index];
          return SizedBox(
            width: 125, // Lebar kartu
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AnimeDetailScreen(animeId: anime.id),
                  ),
                );
              },
              child: AnimeCard(anime: anime),
            ),
          );
        },
      ),
    );
  }
}