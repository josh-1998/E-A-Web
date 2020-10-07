part of 'goal_update_bloc.dart';

@immutable
abstract class GoalUpdateEvent extends Equatable{
  @override
  List<Object> get props => [];
}

///user changes goal date
class UpdateGoalDate extends GoalUpdateEvent{
  final DateTime deadline;
  UpdateGoalDate(this.deadline);
  @override
  List<Object> get props => [deadline];
}

///user changes goal content
class UpdateGoalContent extends GoalUpdateEvent{
  final String content;
  UpdateGoalContent(this.content);
  @override
  List<Object> get props => [content];
}

///user submits goal
class Submit extends GoalUpdateEvent{}

class SubmitFromHomePage extends GoalUpdateEvent{}