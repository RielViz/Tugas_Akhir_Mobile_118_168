// ------------------------------------------------
// lib/screens/my_list_screen.dart
// ------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/my_list_bloc.dart';
import 'anime_detail_screen.dart'; // Sesama folder screens

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyListView();
  }
}

// UI Halaman "My List"
class MyListView extends StatelessWidget {
  const MyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Anime List'),
      ),
      body: BlocBuilder<MyListBloc, MyListState>(
        builder: (context, state) {
          if (state is MyListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyListLoaded) {
            if (state.myList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'List Anda kosong.\nTambahkan anime dari halaman detail.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.myList.length,
              separatorBuilder: (ctx, i) => const Divider(),
              itemBuilder: (context, index) {
                final entry = state.myList[index];

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      entry.coverImageUrl,
                      width: 50,
                      height: 70, // Sedikit lebih tinggi agar proporsional
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // --- PERUBAHAN DI SINI ---
                  // Menampilkan Episode Progress, bukan Skor
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${entry.status} • Eps: ${entry.episodesWatched}',
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),

                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AnimeDetailScreen(animeId: entry.animeId),
                      ),
                    );
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Anime'),
                          content: Text(
                              'Yakin ingin menghapus "${entry.title}" dari list?'),
                          actions: [
                            TextButton(
                              child: const Text('Batal'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                context.read<MyListBloc>().add(
                                    RemoveFromMyList(animeId: entry.animeId));
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Terjadi kesalahan.'));
        },
      ),
    );
  }
}
