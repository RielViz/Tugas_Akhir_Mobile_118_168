// ---------------------------------------------------------
// lib/logic/my_list_bloc.dart
// ---------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/my_anime_entry_model.dart';
import '../repositories/my_list_repository.dart';

// --- EVENTS ---
abstract class MyListEvent extends Equatable {
  const MyListEvent();
  @override
  List<Object> get props => [];
}

class LoadMyList extends MyListEvent {}

class RemoveFromMyList extends MyListEvent {
  final int animeId;
  const RemoveFromMyList({required this.animeId});
  @override
  List<Object> get props => [animeId];
}

class AddOrUpdateEntry extends MyListEvent {
  final MyAnimeEntryModel entry;
  const AddOrUpdateEntry({required this.entry});
  @override
  List<Object> get props => [entry];
}

// UPDATE: Tambah parameter maxEpisodes untuk logika status otomatis
class UpdateEpisodeProgress extends MyListEvent {
  final int animeId;
  final int newProgress;
  final int maxEpisodes; 

  const UpdateEpisodeProgress({
    required this.animeId, 
    required this.newProgress,
    required this.maxEpisodes,
  });

  @override
  List<Object> get props => [animeId, newProgress, maxEpisodes];
}

// --- STATES ---
abstract class MyListState extends Equatable {
  const MyListState();
  @override
  List<Object> get props => [];
}

class MyListLoading extends MyListState {}

class MyListLoaded extends MyListState {
  final List<MyAnimeEntryModel> myList;
  const MyListLoaded({required this.myList});
  @override
  List<Object> get props => [myList];
}

// --- BLOC ---
class MyListBloc extends Bloc<MyListEvent, MyListState> {
  final MyListRepository myListRepository;

  MyListBloc({required this.myListRepository}) : super(MyListLoading()) {
    
    // Load Data
    on<LoadMyList>((event, emit) {
      try {
        final list = myListRepository.getMyList();
        emit(MyListLoaded(myList: list));
      } catch (e) {
        emit(const MyListLoaded(myList: []));
      }
    });

    // Add / Update Data
    on<AddOrUpdateEntry>((event, emit) async {
      await myListRepository.addOrUpdateAnime(event.entry);
      add(LoadMyList()); // Reload UI setelah update
    });

    // Remove Data
    on<RemoveFromMyList>((event, emit) async {
      await myListRepository.deleteAnime(event.animeId);
      add(LoadMyList());
    });

    // HANDLER UPDATE: Logika Otomatisasi Status
    on<UpdateEpisodeProgress>((event, emit) async {
      final entry = myListRepository.getEntry(event.animeId);
      
      if (entry != null) {
        // Update progress
        entry.episodesWatched = event.newProgress;
        
        // Logika 1: Jika progress menyentuh max -> Completed
        if (event.maxEpisodes > 0 && entry.episodesWatched >= event.maxEpisodes) {
          entry.status = 'Completed';
        } 
        // Logika 2: Jika progress bertambah (>0) dari Planning -> Watching
        else if (entry.episodesWatched > 0 && entry.status == 'Planning') {
          entry.status = 'Watching';
        }

        await entry.save(); 
        add(LoadMyList());
      }
    });
  }
}