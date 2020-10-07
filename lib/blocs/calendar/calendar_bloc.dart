import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import '../../misc/user_repository.dart';

part 'calendar_event.dart';

part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final UserRepository userRepository;
  Map<DateTime, List> _competitionMap = {};
  Map<DateTime, List> eventsMap = {};
  DateTime currentDay;

  CalendarBloc({this.userRepository}) {}

  void getIndividualDays() {
    _competitionMap = {};
    eventsMap = {};
    for (Competition currentCompetition
        in userRepository.diary.competitionList) {
      DateTime date = DateTime.parse(currentCompetition.date);
      _competitionMap.update(date, (List existingValue) {
        existingValue.add(currentCompetition);
        return existingValue;
      }, ifAbsent: () => [currentCompetition]);
      eventsMap.update(date, (List existingValue) {
        existingValue.add(currentCompetition);
        return existingValue;
      }, ifAbsent: () => [currentCompetition]);
    }
    for (Result result in userRepository.diary.resultList) {
      DateTime date = DateTime.parse(result.date);
      _competitionMap.update(date, (List existingValue) {
        existingValue.add(result);
        return existingValue;
      }, ifAbsent: () => [result]);
      eventsMap.update(date, (existingValue) {
        existingValue.add(result);
        return existingValue;
      }, ifAbsent: () => [result]);
    }
    for (GeneralDay generalDay in userRepository.diary.generalDayList) {
      print('This is a general day');
      DateTime date = DateTime.parse(generalDay.date);
      eventsMap.update(date, (existingValue) {
        existingValue.add(generalDay);
        return existingValue;
      }, ifAbsent: () => [generalDay]);
    }
    for (Session session in userRepository.diary.sessionList) {
      DateTime date = DateTime.parse(session.date);
      eventsMap.update(date, (existingValue) {
        existingValue.add(session);
        return existingValue;
      }, ifAbsent: () => [session]);
    }
  }

//   _eventsMap[DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)]
  @override
  CalendarState get initialState {
    getIndividualDays();
    return InitialCalendarState(
        eventsMap[DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)] ==
                null
            ? []
            : eventsMap[DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)],
        _competitionMap);
  }

  @override
  Stream<CalendarState> mapEventToState(CalendarEvent event) async* {
    if (event is ChangeDay) {
      currentDay = event.currentDay;
      yield NewDayState(
          eventsMap[event.currentDay] != null
              ? eventsMap[event.currentDay]
              : [],
          _competitionMap);
    }
    if (event is DeleteItem) {
      if (event.entry is Competition) {}
      if (event.entry is Result) {}
    }
  }
}
