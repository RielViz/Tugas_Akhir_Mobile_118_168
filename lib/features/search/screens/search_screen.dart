// ----------------------------------------------
// lib/features/search/screens/search_screen.dart
// ----------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/features/anime_detail/screens/anime_detail_screen.dart';
import 'package:ta_teori/data/repositories/anime_repository.dart';
import 'package:ta_teori/data/repositories/search_history_repository.dart';
import 'package:ta_teori/features/search/bloc/search_bloc.dart';

import 'package:ta_teori/data/models/anime_model.dart';

// Halaman Wrapper untuk menyediakan BLoC
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        animeRepository: RepositoryProvider.of<AnimeRepository>(context),
        searchHistoryRepository:
            RepositoryProvider.of<SearchHistoryRepository>(context),
      )..add(LoadRecentSearches()),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Anime'),
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ketik judul anime...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    context
                        .read<SearchBloc>()
                        .add(const SearchQueryChanged(query: ''));
                  },
                ),
              ),
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query: query));
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {

                if (state is SearchInitial) {
                  if (state.recentSearches.isEmpty) {
                    return const Center(
                      child: Text('Ketik di atas untuk mulai mencari...'),
                    );
                  }
                  return _buildRecentSearchesList(context, state.recentSearches);
                }

                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchLoaded) {
                  if (state.results.isEmpty) {
                    return const Center(child: Text('Anime tidak ditemukan.'));
                  }
                  return _buildResultsList(state.results);
                }

                if (state is SearchError) {
                  return Center(
                    child: Text('Error: ${state.message}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<AnimeModel> results) { 
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final anime = results[index];
        return ListTile(
          leading: Image.network(
            anime.coverImageUrl,
            width: 50,
            fit: BoxFit.cover,
          ),
          title: Text(anime.title),
          subtitle: Text(
              'Skor: ${anime.averageScore != null ? (anime.averageScore! / 10.0).toStringAsFixed(1) : 'N/A'}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AnimeDetailScreen(animeId: anime.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearchesList(
      BuildContext context, List<String> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pencarian Terakhir',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
                child: const Text('Hapus Semua'),
                onPressed: () {
                  context.read<SearchBloc>().add(ClearRecentSearches());
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                onTap: () {
                  _controller.text = query;
                  _controller.selection =
                      TextSelection.collapsed(offset: query.length);
                  context.read<SearchBloc>().add(SearchQueryChanged(query: query));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}