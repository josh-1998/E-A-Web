import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/blocs/competition/competition_bloc.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';
import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'result_event.dart';

part 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final UserRepository _userRepository;
  final Result _result;
  final bool _isCompetitionConverter;
  final Competition competition;
  //0:title, 1:position,
  List<bool> conditions = [false, false];

  ResultBloc(this._userRepository,
      {Result result, bool isCompetitionConverter, this.competition})
      : _result = result ?? Result(),
        _isCompetitionConverter = isCompetitionConverter ?? false;

  @override
  ResultState get initialState => InitialResultState(_result);

  @override
  Stream<ResultState> mapEventToState(ResultEvent event) async* {
    if (event is AddTitle) {
      _result.name = event.title;
      yield UpdatedResultState(_result);
    } else if (event is AddPosition) {
      _result.position = event.position;
      yield UpdatedResultState(_result);
    } else if (event is ChangeDate) {
      _result.date = event.date;
      yield UpdatedResultState(_result);
    } else if (event is AddReflections) {
      _result.reflections = event.reflections;
      yield UpdatedResultState(_result);
    } else if (event is Submit) {
      yield IsSubmitting(_result);
      if (_result.position == null) _result.position = 50;
      if (_result.date == null)
        _result.date =
            '${currentDay.year}-${timeToString(currentDay.month)}-${timeToString(currentDay.day)}';
      if (_result.name == null) _result.name = 'Unnamed Competition';

      try {
        Result _newResult = await _result.uploadResult(_userRepository);
        if (_isCompetitionConverter) {
          await deleteCompetition(
              await _userRepository.refreshIdToken(), competition);
          _userRepository.diary.competitionList =
              await getCompetitionList(await _userRepository.refreshIdToken());
        }
        if (_result.id == null || _result.id[0] == 'x')
          _userRepository.diary.resultList.add(_newResult);
        yield SubmissionSuccessful(_result);
      } catch (e) {
        print(e);
        yield SubmissionFailed(_result);
      }
    }
  }
}
