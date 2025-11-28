// ---------------------------------------------------
// lib/features/anime_detail/screens/anime_detail_screen.dart
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/models/anime_model.dart';
import 'package:ta_teori/models/my_anime_entry_model.dart';
import 'package:ta_teori/repositories/anime_repository.dart';
import 'package:ta_teori/repositories/my_list_repository.dart';
import 'package:ta_teori/logic/anime_detail_bloc.dart';
import 'package:ta_teori/logic/my_list_bloc.dart' as myList;

class AnimeDetailScreen extends StatelessWidget {
  final int animeId;
  const AnimeDetailScreen({super.key, required this.animeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimeDetailBloc(
        animeRepository: RepositoryProvider.of<AnimeRepository>(context),
        myListRepository: RepositoryProvider.of<MyListRepository>(context),
      )..add(LoadAnimeDetail(animeId: animeId)),
      child: const AnimeDetailView(),
    );
  }
}

// UI Halaman Detail
class AnimeDetailView extends StatelessWidget {
  const AnimeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AnimeDetailBloc, AnimeDetailState>(
        builder: (context, state) {
          if (state is AnimeDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnimeDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is AnimeDetailLoaded) {
            final anime = state.anime;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 350.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      anime.title,
                      style: const TextStyle(shadows: [Shadow(blurRadius: 5)]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Image.network(
                      anime.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image));
                      },
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildActionButtons(context, state),
                      const SizedBox(height: 16),
                      _buildInfoSection(anime),
                      const Divider(height: 32),
                      _buildDescriptionSection(anime),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AnimeDetailLoaded state) {
    final anime = state.anime;
    final String buttonText = state.isInMyList
        ? 'Status: ${state.entry!.status}'
        : 'Tambah ke List Saya';
    final IconData buttonIcon =
        state.isInMyList ? Icons.check_circle : Icons.add_circle_outline;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            icon: Icon(buttonIcon),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: state.isInMyList ? Colors.green : Colors.blue,
            ),
            onPressed: () {
              _showStatusModal(context, anime, state.entry);
            },
          ),
          if (state.isInMyList) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Hapus dari List',
                  style: TextStyle(color: Colors.red)),
              
              onPressed: () {
                context
                    .read<AnimeDetailBloc>()
                    .add(RemoveFromMyList(animeId: anime.id));
                
                context
                    .read<myList.MyListBloc>()
                    .add(myList.RemoveFromMyList(animeId: anime.id));
              },
            ),
          ]
        ],
      ),
    );
  }

  // Widget untuk Info (Skor & Genre)
  Widget _buildInfoSection(AnimeModel anime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 30),
              const SizedBox(width: 8),
              Text(
                anime.averageScore != null
                    ? '${(anime.averageScore! / 10.0).toStringAsFixed(1)} / 10'
                    : 'N/A',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (anime.genres != null && anime.genres!.isNotEmpty) ...[
            const Text('Genre:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: anime.genres!
                  .map((genre) => Chip(
                        label: Text(genre),
                        backgroundColor: Colors.grey.shade800,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Widget untuk Sinopsis
  Widget _buildDescriptionSection(AnimeModel anime) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sinopsis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            anime.description?.replaceAll(RegExp(r'<br\s*\/?>'), '\n\n') ??
                'Tidak ada sinopsis.',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showStatusModal(
      BuildContext context, AnimeModel anime, MyAnimeEntryModel? entry) {
    
    final detailBloc = context.read<AnimeDetailBloc>();
    
    final myListBloc = context.read<myList.MyListBloc>(); 

    const statuses = ['Watching', 'Completed', 'Paused', 'Dropped', 'Planning'];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Status List',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...statuses.map((status) {
                return ListTile(
                  title: Text(status),
                  trailing: (entry?.status == status)
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    detailBloc.add(AddOrUpdateMyList(
                      animeId: anime.id,
                      title: anime.title,
                      coverImageUrl: anime.coverImageUrl,
                      status: status,
                    ));

                    final newEntry = MyAnimeEntryModel(
                      animeId: anime.id,
                      title: anime.title,
                      coverImageUrl: anime.coverImageUrl,
                      status: status,
                      userScore: entry?.userScore,
                    );

                    myListBloc.add(myList.AddOrUpdateEntry(entry: newEntry));

                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}