// ------------------------------------------------
// lib/features/my_list/screens/my_list_screen.dart
// ------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/features/anime_detail/screens/anime_detail_screen.dart';
import 'package:ta_teori/features/my_list/bloc/my_list_bloc.dart';

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
        title: const Text('My Anime List (Lokal)'),
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
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: state.myList.length,
              itemBuilder: (context, index) {
                final entry = state.myList[index];

                return ListTile(
                  leading: Image.network(
                    entry.coverImageUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  title: Text(entry.title),
                  subtitle: Text(
                      'Status: ${entry.status} | Skor: ${entry.userScore ?? 'N/A'}'),
                  
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AnimeDetailScreen(animeId: entry.animeId),
                      ),
                    );
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Konfirmasi'),
                          content: Text(
                              'Anda yakin ingin menghapus ${entry.title} dari list?'),
                          actions: [
                            TextButton(
                              child: const Text('Batal'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                context
                                    .read<MyListBloc>()
                                    .add(RemoveFromMyList(animeId: entry.animeId));
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