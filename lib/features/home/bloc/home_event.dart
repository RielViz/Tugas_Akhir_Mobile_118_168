// --------------------------------------
// lib/features/home/bloc/home_event.dart
// --------------------------------------

part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchHomeData extends HomeEvent {
  final bool isRefresh;

  const FetchHomeData({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}