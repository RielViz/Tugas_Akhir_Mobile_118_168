import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/anime_model.dart';
import '../models/my_anime_entry_model.dart';
import '../repositories/anime_repository.dart';
import '../repositories/my_list_repository.dart';

// --- EVENTS ---
abstract class AnimeDetailEvent extends Equatable {
  const AnimeDetailEvent();
  @override
  List<Object> get props => [];
}

class LoadAnimeDetail extends AnimeDetailEvent {
  final int animeId;
  const LoadAnimeDetail({required this.animeId});
  @override
  List<Object> get props => [animeId];
}

class AddOrUpdateMyList extends AnimeDetailEvent {
  final int animeId;
  final String title;
  final String coverImageUrl;
  final String status;

  const AddOrUpdateMyList({
    required this.animeId,
    required this.title,
    required this.coverImageUrl,
    required this.status,
  });

  @override
  List<Object> get props => [animeId, title, coverImageUrl, status];
}

class RemoveFromMyList extends AnimeDetailEvent {
  final int animeId;
  const RemoveFromMyList({required this.animeId});
  @override
  List<Object> get props => [animeId];
}

// --- STATES ---
abstract class AnimeDetailState extends Equatable {
  const AnimeDetailState();
  @override
  List<Object?> get props => [];
}

class AnimeDetailLoading extends AnimeDetailState {}

class AnimeDetailError extends AnimeDetailState {
  final String message;
  const AnimeDetailError({required this.message});
  @override
  List<Object> get props => [message];
}

class AnimeDetailLoaded extends AnimeDetailState {
  final AnimeModel anime;
  final bool isInMyList;
  final MyAnimeEntryModel? entry;

  const AnimeDetailLoaded({
    required this.anime,
    required this.isInMyList,
    this.entry,
  });

  @override
  List<Object?> get props => [anime, isInMyList, entry];

  AnimeDetailLoaded copyWith({
    AnimeModel? anime,
    bool? isInMyList,
    MyAnimeEntryModel? entry,
  }) {
    return AnimeDetailLoaded(
      anime: anime ?? this.anime,
      isInMyList: isInMyList ?? this.isInMyList,
      entry: entry,
    );
  }
}

// --- BLOC ---
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
        final MyAnimeEntryModel? entry = isInList ? myListRepository.getEntry(event.animeId) : null;

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
        emit(currentState.copyWith(isInMyList: true, entry: newEntry));
      }
    });

    on<RemoveFromMyList>((event, emit) async {
      if (state is AnimeDetailLoaded) {
        final currentState = state as AnimeDetailLoaded;
        await myListRepository.deleteAnime(event.animeId);
        emit(currentState.copyWith(isInMyList: false, entry: null));
      }
    });
  }
}