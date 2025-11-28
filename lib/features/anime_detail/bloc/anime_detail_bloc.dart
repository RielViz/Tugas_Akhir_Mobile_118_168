// ---------------------------------------------------
// lib/features/anime_detail/bloc/anime_detail_bloc.dart
// ---------------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ta_teori/data/models/anime_model.dart';
import 'package:ta_teori/data/models/my_anime_entry_model.dart';
import 'package:ta_teori/data/repositories/anime_repository.dart';
import 'package:ta_teori/data/repositories/my_list_repository.dart';

part 'anime_detail_event.dart';
part 'anime_detail_state.dart';

class AnimeDetailBloc extends Bloc<AnimeDetailEvent, AnimeDetailState> {
  final AnimeRepository animeRepository;
  final MyListRepository myListRepository;

  AnimeDetailBloc({
    required this.animeRepository,
    required this.myListRepository,
  }) : super(AnimeDetailLoading()) {
    
    on<LoadAnimeDetail>((event, emit) async {
      emit(AnimeDetailLoading());
      try {
        final anime = await animeRepository.getAnimeDetail(event.animeId);

        final bool isInList = myListRepository.isInList(event.animeId);
        MyAnimeEntryModel? entry;
        if (isInList) {
          entry = myListRepository.getEntry(event.animeId);
        }

        emit(AnimeDetailLoaded(
          anime: anime,
          isInMyList: isInList,
          entry: entry,
        ));
      } catch (e) {
        emit(AnimeDetailError(message: e.toString().replaceFirst("Exception: ", "")));
      }
    });

    on<AddOrUpdateMyList>((event, emit) async {
      if (state is AnimeDetailLoaded) {
        final currentState = state as AnimeDetailLoaded;

        final newEntry = MyAnimeEntryModel(
          animeId: event.animeId,
          title: event.title,
          coverImageUrl: event.coverImageUrl,
          status: event.status,
        );

        await myListRepository.addOrUpdateAnime(newEntry);
        emit(currentState.copyWith(
          isInMyList: true,
          entry: newEntry,
        ));
      }
    });

    on<RemoveFromMyList>((event, emit) async {
      if (state is AnimeDetailLoaded) {
        final currentState = state as AnimeDetailLoaded;

        await myListRepository.deleteAnime(event.animeId);

        emit(currentState.copyWith(
          isInMyList: false,
          entry: null,
        ));
      }
    });
  }
}