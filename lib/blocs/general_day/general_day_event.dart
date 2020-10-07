part of 'general_day_bloc.dart';

@immutable
abstract class GeneralDayEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class UpdateRested extends GeneralDayEvent{
  final int rested;

  UpdateRested(this.rested);

  @override
  List<Object> get props => [rested];

}

class UpdateNutrition extends GeneralDayEvent{
  final int nutrition;

  UpdateNutrition(this.nutrition);

  @override
  List<Object> get props => [nutrition];
}

class UpdateConcentration extends GeneralDayEvent{
  final int concentration;

  UpdateConcentration(this.concentration);

  @override
  List<Object> get props => [concentration];
}

class UpdateReflections extends GeneralDayEvent{
  final String reflections;

  UpdateReflections(this.reflections);

  @override
  List<Object> get props => [reflections];
}

class Submit extends GeneralDayEvent{}

class ChangeDateForwards extends GeneralDayEvent{}

class ChangeDateBackwards extends GeneralDayEvent{}