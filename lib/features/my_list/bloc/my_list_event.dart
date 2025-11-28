// --------------------------------------------
// lib/features/my_list/bloc/my_list_event.dart
// --------------------------------------------

part of 'my_list_bloc.dart';

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