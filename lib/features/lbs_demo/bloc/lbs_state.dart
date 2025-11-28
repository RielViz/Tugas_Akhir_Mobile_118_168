// -----------------------------------------
// lib/features/lbs_demo/bloc/lbs_state.dart
// -----------------------------------------

part of 'lbs_bloc.dart';

abstract class LbsState extends Equatable {
  const LbsState();
  @override
  List<Object> get props => [];
}

class LbsInitial extends LbsState {}

class LbsLoading extends LbsState {}

class LbsLoaded extends LbsState {
  final Position position;
  const LbsLoaded({required this.position});
  @override
  List<Object> get props => [position];
}

class LbsError extends LbsState {
  final String message;
  const LbsError({required this.message});
  @override
  List<Object> get props => [message];
}