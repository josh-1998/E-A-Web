part of 'competition_bloc.dart';

@immutable
abstract class CompetitionEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UpdateDate extends CompetitionEvent{
  final String date;

  UpdateDate(this.date);

  @override
  // TODO: implement props
  List<Object> get props => [date];
}

class UpdateStartTime extends CompetitionEvent{
  final String startTime;

  UpdateStartTime(this.startTime);

  @override
  // TODO: implement props
  List<Object> get props => [startTime];
}

class UpdateAddress extends CompetitionEvent{
  final String address;

  UpdateAddress(this.address);

  @override
  // TODO: implement props
  List<Object> get props => [address];
}

class UpdateName extends CompetitionEvent{
  final String name;

  UpdateName(this.name);

  @override
  // TODO: implement props
  List<Object> get props => [name];
}

class Submit extends CompetitionEvent{}

