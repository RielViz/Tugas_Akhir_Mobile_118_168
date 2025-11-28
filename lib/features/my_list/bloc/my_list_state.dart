// --------------------------------------------
// lib/features/my_list/bloc/my_list_state.dart
// --------------------------------------------

part of 'my_list_bloc.dart';

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