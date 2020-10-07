part of 'calendar_bloc.dart';

@immutable
abstract class CalendarState extends Equatable{
  final List currentDayList = [];
  final Map<DateTime, dynamic> competitionMap={};

  @override
  List<Object> get props => [currentDayList, competitionMap];
}

class InitialCalendarState extends CalendarState {
    final List currentDayList;
    final Map<DateTime, dynamic> competitionMap;

  InitialCalendarState(this.currentDayList, this.competitionMap);

}

class NewDayState extends CalendarState{
  final List currentDayList;
  final Map<DateTime, dynamic> competitionMap;

  NewDayState(this.currentDayList, this.competitionMap);
}