// ---------------------------------------------------
// lib/features/anime_detail/bloc/anime_detail_state.dart
// ---------------------------------------------------

part of 'anime_detail_bloc.dart';

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