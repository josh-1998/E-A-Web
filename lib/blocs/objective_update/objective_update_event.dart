part of 'objective_update_bloc.dart';

@immutable
abstract class ObjectiveUpdateEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateLength extends ObjectiveUpdateEvent{
  final int length;

  UpdateLength(this.length);
  @override
  List<Object> get props => [length];
}

class UpdateAverage extends ObjectiveUpdateEvent{
  final int average;

  UpdateAverage(this.average);
  @override
  List<Object> get props => [average];
}

class UpdateDeadlineDate extends ObjectiveUpdateEvent{
  final DateTime deadlineDate;

  UpdateDeadlineDate(this.deadlineDate);
  @override
  List<Object> get props => [deadlineDate];
}

class SubmitResponse extends ObjectiveUpdateEvent{}
