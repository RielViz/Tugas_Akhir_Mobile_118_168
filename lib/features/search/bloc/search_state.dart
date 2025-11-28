// ------------------------------------------
// lib/features/search/bloc/search_state.dart
// ------------------------------------------

part of 'search_bloc.dart';

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
  // State sukses
  final List<AnimeModel> results;
  const SearchLoaded({required this.results});
  @override
  List<Object> get props => [results];
}

class SearchError extends SearchState {
  // State error
  final String message;
  const SearchError({required this.message});
  @override
  List<Object> get props => [message];
}