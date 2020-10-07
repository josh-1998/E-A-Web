import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';
import 'package:e_athlete_web/models/diary_model.dart';
import 'package:e_athlete_web/models/goals.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import '../../misc/database.dart';
import '../../misc/user_repository.dart';
import 'package:connectivity/connectivity.dart';
part 'authentification_event.dart';
part 'authentification_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Loading();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  /// called when app is started
  /// if user logged in then check for internet connection, if exists check JWT,
  /// if no internet then log in but don't do all api calls
  Stream<AuthenticationState> _mapAppStartedToState() async* {
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      for (Session item in await DBHelper.getSessions()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (GeneralDay item in await DBHelper.getGeneralDay()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Result item in await DBHelper.getResults()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Competition item in await DBHelper.getCompetitions()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Goal item in await DBHelper.getShortTermGoals()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Goal item in await DBHelper.getMediumTermGoals()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Goal item in await DBHelper.getLongTermGoals()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Goal item in await DBHelper.getFinishedTermGoals()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }
      for (Goal item in await DBHelper.getUltimateGoal()) {
        print(item.id);
        if (item.id[0] == "e" || item.id[0] == "x") {
          _userRepository.diaryItemsToSend.add(item);
        }
        if (item.id[0] == "d") {
          _userRepository.diaryItemsToDelete.add(item);
        }
      }

      if (await hasInternetConnection()) {
        processDiaryItems(_userRepository);
        try {
          await _userRepository.refreshIdToken().timeout(Duration(seconds: 6),
              onTimeout: () {
            return 'Connection Slow';
          });

          ///update user profile from server if internet connection exists
          await DBHelper.getUser(_userRepository.user);
          try {
            await _userRepository.user
                .getUserInfo(await _userRepository.refreshIdToken());
            _userRepository.diary.sessionList = await DBHelper.getSessions();
            _userRepository.diary.generalDayList =
                await DBHelper.getGeneralDay();
            _userRepository.diary.competitionList =
                await DBHelper.getCompetitions();
            _userRepository.diary.resultList = await DBHelper.getResults();
            _userRepository.diary.ultimateGoal =
                await DBHelper.getUltimateGoal();
            _userRepository.diary.shortTermGoals =
                await DBHelper.getShortTermGoals();
            _userRepository.diary.mediumTermGoals =
                await DBHelper.getMediumTermGoals();
            _userRepository.diary.longTermGoal =
                await DBHelper.getLongTermGoals();
            _userRepository.diary.finishedGoals =
                await DBHelper.getFinishedTermGoals();
            await DBHelper.getObjectives(_userRepository);
            yield Authenticated();
          } catch (e) {
            _userRepository.signOut();
            yield Unauthenticated();
          }
        } catch (e) {
          _userRepository.signOut();
          yield Unauthenticated();
          print(e);
        }
      }

      ///login without checking user info and just loading sessions from internal
      ///DB
      else {
        await DBHelper.getUser(_userRepository.user);
        _userRepository.diary.sessionList = await DBHelper.getSessions();
        _userRepository.diary.generalDayList = await DBHelper.getGeneralDay();
        _userRepository.diary.competitionList =
            await DBHelper.getCompetitions();
        _userRepository.diary.resultList = await DBHelper.getResults();
        yield Authenticated();
      }
    }

    ///if user is not signed in then yield unauthenticated
    else {
      yield Unauthenticated();
    }
  }

  /// When user signs in
  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated();
  }

  /// When user signs out
  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    await _userRepository.signOut();
    yield Unauthenticated();
  }
}
