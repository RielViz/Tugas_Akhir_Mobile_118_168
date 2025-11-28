// ---------------------------------------------------
// lib/features/anime_detail/bloc/anime_detail_event.dart
// ---------------------------------------------------

part of 'anime_detail_bloc.dart';

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