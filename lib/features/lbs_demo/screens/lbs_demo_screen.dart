// --------------------------------------------------
// lib/features/lbs_demo/screens/lbs_demo_screen.dart
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/data/repositories/location_repository.dart';
import 'package:ta_teori/features/lbs_demo/bloc/lbs_bloc.dart';

class LbsDemoScreen extends StatelessWidget {
  const LbsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LbsBloc(
        locationRepository: RepositoryProvider.of<LocationRepository>(context),
      ),
      child: const LbsDemoView(),
    );
  }
}

class LbsDemoView extends StatelessWidget {
  const LbsDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo LBS (GPS)'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<LbsBloc, LbsState>(
            builder: (context, state) {
              if (state is LbsLoading) {
                return const CircularProgressIndicator();
              }

              if (state is LbsLoaded) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 60, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      'Lokasi Berhasil Didapat!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text('Latitude: ${state.position.latitude}'),
                    Text('Longitude: ${state.position.longitude}'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LbsBloc>().add(FetchLocation());
                      },
                      child: const Text('Ambil Ulang Lokasi'),
                    )
                  ],
                );
              }

              if (state is LbsError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal Mendapat Lokasi',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LbsBloc>().add(FetchLocation());
                      },
                      child: const Text('Coba Lagi'),
                    )
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gps_fixed, size: 60, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Tes Fitur LBS',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Klik tombol di bawah untuk mengambil lokasi GPS Anda saat ini.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12)),
                    onPressed: () {
                      context.read<LbsBloc>().add(FetchLocation());
                    },
                    child: const Text('Dapatkan Lokasi Saya'),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}