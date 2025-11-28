// -----------------------------------------
// lib/logic/search_bloc.dart
// -----------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/anime_model.dart';
import '../repositories/anime_repository.dart';
import '../repositories/search_history_repository.dart';

// --- EVENTS ---
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged({required this.query});
  @override
  List<Object> get props => [query];
}

class LoadRecentSearches extends SearchEvent {}

class ClearRecentSearches extends SearchEvent {}

// EVENT BARU: Hapus 1 item history
class RemoveSpecificSearch extends SearchEvent {
  final String term;
  const RemoveSpecificSearch({required this.term});
  @override
  List<Object> get props => [term];
}

// --- STATES ---
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> recentSearches;
  const SearchInitial({this.recentSearches = const []});
  @override
  List<Object> get props => [recentSearches];
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<AnimeModel> results;
  const SearchLoaded({required this.results});
  @override
  List<Object> get props => [results];
}

class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});
  @override
  List<Object> get props => [message];
}

// Helper Debounce
EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) {
    return events.debounce(duration).switchMap(mapper);
  };
}

// --- BLOC ---
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final AnimeRepository animeRepository;
  final SearchHistoryRepository searchHistoryRepository;

  SearchBloc({
    required this.animeRepository,
    required this.searchHistoryRepository,
  }) : super(const SearchInitial(recentSearches: [])) {
    
    on<LoadRecentSearches>((event, emit) {
      try {
        final history = searchHistoryRepository.getSearchHistory();
        emit(SearchInitial(recentSearches: history));
      } catch (e) {
        emit(const SearchInitial(recentSearches: []));
      }
    });

    on<SearchQueryChanged>(
      (event, emit) async {
        if (event.query.isEmpty) {
          final history = searchHistoryRepository.getSearchHistory();
          emit(SearchInitial(recentSearches: history));
          return;
        }

        emit(SearchLoading());
        try {
          final results = await animeRepository.searchAnime(event.query);
          await searchHistoryRepository.addSearchTerm(event.query);
          emit(SearchLoaded(results: results));
        } catch (e) {
          emit(SearchError(
              message: e.toString().replaceFirst("Exception: ", "")));
        }
      },
      transformer: _debounce(const Duration(milliseconds: 500)),
    );

    // HANDLER HAPUS SEMUA
    on<ClearRecentSearches>((event, emit) async {
      await searchHistoryRepository.clearSearchHistory();
      emit(const SearchInitial(recentSearches: []));
    });

    // HANDLER BARU: HAPUS 1 ITEM
    on<RemoveSpecificSearch>((event, emit) async {
      await searchHistoryRepository.deleteSearchTerm(event.term);
      // Reload history setelah dihapus
      final updatedHistory = searchHistoryRepository.getSearchHistory();
      emit(SearchInitial(recentSearches: updatedHistory));
    });
  }
}