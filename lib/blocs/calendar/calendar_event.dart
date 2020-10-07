part of 'calendar_bloc.dart';

@immutable
abstract class CalendarEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class DeleteItem extends CalendarEvent{
  final entry;

  DeleteItem(this.entry);

  @override
  // TODO: implement props
  List<Object> get props => [entry];
}

class ChangeDay extends CalendarEvent{
  final DateTime currentDay;

  ChangeDay({this.currentDay});

  @override
  List<Object> get props => [currentDay];

}


