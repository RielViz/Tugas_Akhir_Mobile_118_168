// ---------------------------------------------------
// lib/features/saran_kesan/screens/saran_kesan_screen.dart
// ---------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/data/repositories/saran_kesan_repository.dart';
import 'package:ta_teori/features/saran_kesan/bloc/saran_kesan_bloc.dart';

// Halaman Wrapper untuk menyediakan BLoC
class SaranKesanScreen extends StatelessWidget {
  const SaranKesanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SaranKesanBloc(
        repository: RepositoryProvider.of<SaranKesanRepository>(context),
      )
        ..add(LoadSaranKesan()),
      child: const SaranKesanView(),
    );
  }
}

// UI Halaman Saran & Kesan
class SaranKesanView extends StatefulWidget {
  const SaranKesanView({super.key});

  @override
  State<SaranKesanView> createState() => _SaranKesanViewState();
}

class _SaranKesanViewState extends State<SaranKesanView> {
  // Controller untuk form
  final _saranController = TextEditingController();
  final _kesanController = TextEditingController();

  @override
  void dispose() {
    _saranController.dispose();
    _kesanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran dan Kesan'),
      ),
      body: BlocListener<SaranKesanBloc, SaranKesanState>(
        listener: (context, state) {
          if (state is SaranKesanSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saran & Kesan berhasil disimpan!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<SaranKesanBloc, SaranKesanState>(
          builder: (context, state) {
            
            if (state is SaranKesanLoaded && state.entry != null) {
              _saranController.text = state.entry!.saran;
              _kesanController.text = state.entry!.kesan;
            }

            if (state is SaranKesanLoading && state is! SaranKesanLoaded) {
               return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Sampaikan saran dan kesan Anda untuk mata kuliah ini.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Saran
                  TextField(
                    controller: _saranController,
                    decoration: const InputDecoration(
                      labelText: 'Saran',
                      hintText: 'Tulis saran Anda di sini...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),

                  // Form Kesan
                  TextField(
                    controller: _kesanController,
                    decoration: const InputDecoration(
                      labelText: 'Kesan',
                      hintText: 'Tulis kesan Anda di sini...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () {
                      context.read<SaranKesanBloc>().add(
                            SaveSaranKesan(
                              saran: _saranController.text,
                              kesan: _kesanController.text,
                            ),
                          );
                    },
                    child: (state is SaranKesanLoading)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}