part of 'goal_update_bloc.dart';

@immutable
abstract class GoalUpdateState extends Equatable{
  String goalType;
  @override
  List<Object> get props => [];
}

class InitialGoalUpdateState extends GoalUpdateState {
  final String goalType;

  InitialGoalUpdateState(this.goalType);

  @override
  List<Object> get props => [goalType];
}

class IncompleteInformation extends GoalUpdateState{}

class InformationSubmitted extends GoalUpdateState{}
