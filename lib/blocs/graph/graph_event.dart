part of 'graph_bloc.dart';

@immutable
abstract class GraphEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class ChangeGraph1 extends GraphEvent{
  final String valueName;

  ChangeGraph1(this.valueName);

  @override
  List<Object> get props => [valueName];
}
class ChangeGraph2 extends GraphEvent{
  final String valueName;

  ChangeGraph2(this.valueName);

  @override
  List<Object> get props => [valueName];
}

class MoveWeekForward extends GraphEvent{}

class MoveWeekBack extends GraphEvent{}

class ChangeTimeViewBack extends GraphEvent{}

class ChangeTimeViewForward extends GraphEvent{}

class ChangeTimeViewTimeFrame extends GraphEvent{}
