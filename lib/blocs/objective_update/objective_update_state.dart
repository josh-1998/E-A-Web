part of 'objective_update_bloc.dart';

@immutable
abstract class ObjectiveUpdateState extends Equatable{
  @override
  List<Object> get props => [];
}

class InitialObjectiveUpdateState extends ObjectiveUpdateState {}

class Submitted extends ObjectiveUpdateState{}