import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/misc/database.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';
import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/goals.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'objective_update_event.dart';

part 'objective_update_state.dart';

class ObjectiveUpdateBloc
    extends Bloc<ObjectiveUpdateEvent, ObjectiveUpdateState> {
  final String objectiveType;
  final UserRepository userRepository;
  Objective _newObjective;

  ObjectiveUpdateBloc(
      {this.objectiveType, Objective newObjective, this.userRepository})
      : _newObjective = newObjective;

  @override
  ObjectiveUpdateState get initialState {
    _newObjective = Objective();
    _newObjective.objectiveType = objectiveType;
    _newObjective.average = 1;
    _newObjective.startDate = currentDay;
    _newObjective.endDate = currentDay;
    return InitialObjectiveUpdateState();
  }

  @override
  Stream<ObjectiveUpdateState> mapEventToState(
      ObjectiveUpdateEvent event) async* {
    if (event is UpdateAverage) {
      _newObjective.average = event.average;
      yield InitialObjectiveUpdateState();
    }
    if (event is UpdateLength) {
      print('event.length length: ');
      print(event.length);
      _newObjective.hoursOfWork = event.length;
    }
    if (event is UpdateDeadlineDate) {
      _newObjective.endDate = event.deadlineDate;
    }
    if (event is SubmitResponse) {
      _newObjective.id = 'x${DateTime.now().millisecondsSinceEpoch}';
      _newObjective.addToQueue(userRepository);
      if (_newObjective.objectiveType == 'Performance') {
        if (userRepository.diary.performanceObjective != null) {
          userRepository.diary.performanceObjective.isFinished = 'true';
          DBHelper.updateObjectiveValue(
              [userRepository.diary.performanceObjective]);
          userRepository.diary.finishedObjectives
              .add(userRepository.diary.performanceObjective);
          userRepository.diary.performanceObjective
              .deleteObjective(userRepository);
        }
        //  DBHelper.updateObjectives([_newObjective]);
        userRepository.diary.performanceObjective =
            await _newObjective.uploadObjective(userRepository);
      } else if (_newObjective.objectiveType == 'Hours Worked') {
        if (userRepository.diary.hoursWorkedObjective != null) {
          userRepository.diary.hoursWorkedObjective.isFinished = 'true';
          DBHelper.updateObjectiveValue(
              [userRepository.diary.hoursWorkedObjective]);
          userRepository.diary.finishedObjectives
              .add(userRepository.diary.hoursWorkedObjective);
          userRepository.diary.hoursWorkedObjective
              .deleteObjective(userRepository);
        }
        // DBHelper.updateObjectives([_newObjective]);
        userRepository.diary.hoursWorkedObjective =
            await _newObjective.uploadObjective(userRepository);
      } else if (_newObjective.objectiveType == 'Intensity') {
        if (userRepository.diary.intensityObjective != null) {
          userRepository.diary.intensityObjective.isFinished = 'true';
          DBHelper.updateObjectiveValue(
              [userRepository.diary.intensityObjective]);
          userRepository.diary.finishedObjectives
              .add(userRepository.diary.intensityObjective);
          userRepository.diary.intensityObjective
              .deleteObjective(userRepository);
        }
        //DBHelper.updateObjectives([_newObjective]);

        userRepository.diary.intensityObjective =
            await _newObjective.uploadObjective(userRepository);
      }
      yield Submitted();
    }
  }
}
