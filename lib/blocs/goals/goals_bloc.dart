import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/common_widgets/goal_widgets.dart';
import 'package:e_athlete_web/misc/database.dart';
import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/goals.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'goals_event.dart';

part 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final UserRepository userRepository;

  GoalsBloc({this.userRepository});

  @override
  GoalsState get initialState {
    return InitialGoalsState(
      shortTermGoals: userRepository.diary.shortTermGoals,
      mediumTermGoals: userRepository.diary.mediumTermGoals,
      longTermGoals: userRepository.diary.longTermGoal,
      finishedGoals: userRepository.diary.finishedGoals,
    );
  }

  @override
  Stream<GoalsState> mapEventToState(GoalsEvent event) async* {
    if (event is ChangeGoalsList) {
      deleteFromPreviousGoalList(event.goal);
      Goal _goal = event.goal;
      _goal.goalType = event.newList;
      _goal = await _goal.uploadGoal(userRepository);
      addToNewGoalList(event.newList, _goal);
//      DBHelper.updateGoalValue([_goal]);
    }
    if (event is GoalAchieved) {
      deleteFromPreviousGoalList(event.goal);
      Goal goal = event.goal;
      goal.achieved = 'true';
      goal.goalType = 'Finished';
      print(goal.id);
      userRepository.diary.finishedGoals.add(goal);
      goal.uploadGoal(userRepository);
      // DBHelper.updateGoalValue([goal]);
    }
    if (event is GoalNotAchieved) {
      deleteFromPreviousGoalList(event.goal);
      Goal goal = event.goal;
      goal.achieved = 'false';
      goal.goalType = 'Finished';
      userRepository.diary.finishedGoals.add(event.goal);
      goal.uploadGoal(userRepository);
      // DBHelper.updateGoalValue([goal]);
    }
    if (event is GoalDeleted) {
      deleteFromPreviousGoalList(event.goal);
      event.goal.deleteGoal(userRepository);
      //     DBHelper.deleteGoal([event.goal]);
    }
  }

  void deleteFromPreviousGoalList(Goal eventGoal) {
    bool isLong = false;
    bool isMedium = false;
    bool isShort = false;
    bool isUltimate = false;
    bool isFinished = false;
    for (Goal goal in userRepository.diary.shortTermGoals) {
      if (eventGoal.id == goal.id) isShort = true;
    }
    for (Goal goal in userRepository.diary.mediumTermGoals) {
      if (eventGoal.id == goal.id) isMedium = true;
    }
    for (Goal goal in userRepository.diary.longTermGoal) {
      if (eventGoal.id == goal.id) isLong = true;
    }
    for (Goal goal in userRepository.diary.ultimateGoal) {
      if (eventGoal.id == goal.id) isUltimate = true;
    }
    for (Goal goal in userRepository.diary.finishedGoals) {
      if (eventGoal.id == goal.id) isFinished = true;
    }
    if (isShort == true)
      userRepository.diary.shortTermGoals
          .removeWhere((element) => element.id == eventGoal.id);
    if (isMedium == true)
      userRepository.diary.mediumTermGoals
          .removeWhere((element) => element.id == eventGoal.id);
    if (isLong == true)
      userRepository.diary.longTermGoal
          .removeWhere((element) => element.id == eventGoal.id);
    if (isUltimate == true)
      userRepository.diary.ultimateGoal
          .removeWhere((element) => element.id == eventGoal.id);
    if (isFinished == true)
      userRepository.diary.finishedGoals
          .removeWhere((element) => element.id == eventGoal.id);
  }

  void addToNewGoalList(String newList, Goal newGoal) {
    if (newList == 'Short Term') {
      newGoal.goalType = 'Short Term';
      userRepository.diary.shortTermGoals.add(newGoal);
    }
    if (newList == 'Medium Term') {
      newGoal.goalType = 'Medium Term';
      userRepository.diary.mediumTermGoals.add(newGoal);
    }
    if (newList == 'Long Term') {
      newGoal.goalType = 'Long Term';
      userRepository.diary.longTermGoal.add(newGoal);
    }
    DBHelper.updateGoalValue([newGoal]);
  }
}
