part of 'result_bloc.dart';

@immutable
abstract class ResultEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddTitle extends ResultEvent {
  final String title;

  AddTitle(this.title);
  @override
  List<Object> get props => [title];
}

class AddPosition extends ResultEvent {
  final int position;

  AddPosition(this.position);

  @override
  List<Object> get props => [position];
}

class ChangeDate extends ResultEvent {
  final String date;

  ChangeDate(this.date);

  @override
  List<Object> get props => [date];
}

class AddReflections extends ResultEvent {
  final String reflections;

  AddReflections(this.reflections);
  @override
  List<Object> get props => [reflections];
}

class Submit extends ResultEvent{}