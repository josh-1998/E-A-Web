part of 'goals_bloc.dart';

@immutable
abstract class GoalsState  extends Equatable{
  List<Goal> shortTermGoals;
  List<Goal> mediumTermGoals;
  List<Goal> longTermGoals;
  List<Goal> finishedGoals;
  @override
  List<Object> get props => [];
}

class InitialGoalsState extends GoalsState {
  final List<Goal> shortTermGoals;
  final List<Goal> mediumTermGoals;
  final List<Goal> longTermGoals;
  final List<Goal> finishedGoals;

  InitialGoalsState({this.shortTermGoals, this.mediumTermGoals, this.longTermGoals, this.finishedGoals});


  @override
  List<Object> get props => [shortTermGoals, mediumTermGoals, longTermGoals, finishedGoals];
}