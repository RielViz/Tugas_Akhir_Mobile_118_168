// -----------------------------------------
// lib/features/lbs_demo/bloc/lbs_event.dart
// -----------------------------------------

part of 'lbs_bloc.dart';

abstract class LbsEvent extends Equatable {
  const LbsEvent();
  @override
  List<Object> get props => [];
}

class FetchLocation extends LbsEvent {}