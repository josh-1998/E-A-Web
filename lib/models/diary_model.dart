import 'dart:convert';
import 'package:e_athlete_web/blocs/goals/goals_bloc.dart';
import 'package:e_athlete_web/misc/useful_functions.dart';
import 'package:e_athlete_web/models/user_model.dart';
import '../misc/constants.dart';
import 'package:http/http.dart' as http;
import '../misc/database.dart';
import '../misc/exceptions.dart';
import '../misc/user_repository.dart';
import 'goals.dart';

abstract class DiaryModel {
  Future<DiaryModel> upload(UserRepository userRepository);

  Future<String> delete(UserRepository userRepository);
}

class Session extends DiaryModel {
  String date;
  int lengthOfSession;
  String title;
  int intensity;
  int performance;
  String feeling;
  String target;
  String reflections;
  String id;

  Session({
    this.date,
    this.lengthOfSession,
    this.title,
    this.intensity,
    this.performance,
    this.feeling,
    this.target,
    this.reflections,
    this.id,
  });

  /// Uploads current instance of session to server.
  /// If there is no internet connection then save it to a list ready to be
  /// uploaded when internet connection comes back
  Future<Session> upload(UserRepository _userRepository) async {
    Map body = {};
    if (this.lengthOfSession != null)
      body['time'] = this.lengthOfSession.toString();
    if (this.title != null) body['title'] = this.title;
    if (this.intensity != null) body['intensity'] = this.intensity.toString();
    if (this.performance != null)
      body['performance'] = this.performance.toString();
    if (this.feeling != null) body['feeling'] = this.feeling;
    if (this.target != null) body['target'] = this.target;
    if (this.reflections != null) body['reflections'] = this.reflections;
    if (this.date != null) body['date'] = this.date.substring(0, 10);
    var response;
    String tempid = this.id.substring(1);
    if (this.id[0] == "e") {
      response = await http.patch(kAPIAddress + '/api/session/$tempid/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    } else {
      response = await http.post(kAPIAddress + '/api/session/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    }
    Map responseBody = jsonDecode(response.body);
    print(responseBody);
    if ((response.statusCode / 100).floor() != 2) {
      throw ServerErrorException;
    }
    Session _newSession = Session()
      ..title = responseBody['title']
      ..date = responseBody['date']
      ..lengthOfSession = responseBody['time']
      ..intensity = responseBody['intensity']
      ..performance = responseBody['performance']
      ..feeling = responseBody['feeling']
      ..target = responseBody['target']
      ..reflections = responseBody['reflections']
      ..id = responseBody['id'].toString();

    if (response.statusCode == 201) {
      _userRepository.diary.sessionList.remove(this);
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteSession([this]);
      this.id = _newSession.id;
      DBHelper.updateSessionValue([this]);
      _userRepository.diary.sessionList.add(_newSession);
    } else if (response.statusCode == 200) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteSession([this]);
      this.id = _newSession.id;
      DBHelper.updateSessionsList([this]);
    }

    for (Session item in await DBHelper.getSessions()) {
      if (item.id == null) {
        DBHelper.deleteSession([item]);
      }
    }

    return _newSession;
  }

  Future<Session> uploadSession(UserRepository _userRepository) async {
    Session _newSession = Session(
        title: title ?? 'Session',
        date: date,
        lengthOfSession: lengthOfSession,
        intensity: intensity,
        performance: performance,
        feeling: feeling,
        target: target,
        reflections: reflections,
        id: id);
    if (this.id == null || this.id == "x") {
      this.id = "x${DateTime.now().millisecondsSinceEpoch}";
      _userRepository.diary.sessionList.add(this);
      DBHelper.updateSessionsList([this]);
    }
    String temp_id = "";
    if (this.id != null) {
      if (this.id[0] != 'e' && this.id[0] != 'x') {
        DBHelper.deleteSession([this]);
        temp_id = "e" + this.id;
        this.id = temp_id;
        DBHelper.updateSessionsList([this]);
      }
    }
    _userRepository.diaryItemsToSend.add(this);

    if (await hasInternetConnection()) {
      _newSession = await upload(_userRepository);
    }
    return _newSession;
  }

  Future<String> delete(UserRepository _userRepository) async {
    Session session = this;
    //store id without 'd' in temp_id string to interact with the server
    String temp_id = "";
    if (session.id[0] == "d") {
      temp_id = session.id.substring(1);
    } else {
      temp_id = this.id;
    }
    //delete from server
    var response = await http.delete(kAPIAddress + '/api/session/$temp_id/',
        headers: {
          'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
        });
    //if status code correct, delete from local db and delete list
    if (response.statusCode == 204) {
      //delete from local db
      DBHelper.deleteSession([session]);
      //delete from to delete list
      var toRemove = [];
      int found = 0;
      for (DiaryModel item in _userRepository.diaryItemsToDelete) {
        if (this == item) {
          found = 1;
        }
      } //for
      if (found == 1) {
        _userRepository.diaryItemsToDelete.remove(this);
      }
    } //status code
  } //deleteSession

  Future<Session> deleteSession(UserRepository _userRepository) async {
    if (this.id[0] != 'd') {
      this.id = "d" + this.id;
    }
    //add to delete list
    int found = 0;
    for (DiaryModel item in _userRepository.diaryItemsToDelete) {
      if (item == this) {
        found = 1;
      }
    }
    if (found == 0) {
      _userRepository.diaryItemsToDelete.add(this);
    }
    if (await hasInternetConnection()) {
      this.delete(_userRepository);
    }
  }
}

Future<List<Session>> getSessionList(String jwt) async {
  var response = await http.get(kAPIAddress + '/api/session/',
      headers: {'Authorization': 'JWT ' + jwt});
  assert(response.statusCode == 200);
  List body = jsonDecode(response.body);
  List<Session> sessions = [];
  for (var session in body) {
    Session newSession = Session()
      ..title = session['title']
      ..date = session['date']
      ..lengthOfSession = session['time']
      ..intensity = session['intensity']
      ..performance = session['performance']
      ..feeling = session['feeling']
      ..target = session['target']
      ..reflections = session['reflections']
      ..id = session['id'].toString();

    sessions.add(newSession);
  }
  return sessions;
}

class GeneralDay extends DiaryModel {
  String date;
  int rested;
  int nutrition;
  int concentration;
  String reflections;
  String id;

  GeneralDay(
      {this.date,
      this.rested,
      this.nutrition,
      this.concentration,
      this.reflections,
      this.id});

  /// Updates the server with a new general day and then adds this to the onboard
  /// sql table*
  Future<GeneralDay> upload(UserRepository _userRepository) async {
    Map body = {};
    if (this.date != null) body['date'] = this.date;
    if (this.rested != null) body['rested'] = this.rested.toString();
    if (this.nutrition != null) body['nutrition'] = this.nutrition.toString();
    if (this.concentration != null)
      body['concentration'] = this.concentration.toString();
    if (this.reflections != null) body['reflections'] = this.reflections;
    if (this.date != null) body['date'] = this.date.substring(0, 10);

    var response;
    String tempid = this.id.substring(1);
    if (this.id[0] == "e") {
      response = await http.patch(kAPIAddress + '/api/general-day/$tempid/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    } else {
      response = await http.post(kAPIAddress + '/api/general-day/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    }

    Map responseBody = jsonDecode(response.body);
    print(responseBody.toString());
    //checks that the upload has been successful
    if ((response.statusCode / 100).floor() != 2) {
      print(response.statusCode / 100);
      throw ServerErrorException;
    }
    //uploads the new general day to the DB
    GeneralDay _newGeneralDay = GeneralDay()
      ..date = responseBody['date']
      ..rested = responseBody['rested']
      ..nutrition = responseBody['nutrition']
      ..concentration = responseBody['concentration']
      ..reflections = responseBody['reflections']
      ..id = responseBody['id'].toString();

    if (response.statusCode == 201) {
      _userRepository.diary.generalDayList.remove(this);
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteGeneralDayItem([this]);
      DBHelper.updateGeneralDayList([_newGeneralDay]);
      _userRepository.diary.generalDayList.add(_newGeneralDay);
    } else if (response.statusCode == 200) {
      _userRepository.diary.generalDayList.remove(this);
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteGeneralDayItem([this]);
//      DBHelper.updateGeneralDayList([this]);
      _userRepository.diary.generalDayList.add(this);
    }
    print("4");
    for (GeneralDay item in await DBHelper.getGeneralDay()) {
      print(item.id);
    }
    return this;
  }

  Future<GeneralDay> uploadGeneralDay(UserRepository _userRepository) async {
    GeneralDay _newGeneralDay = GeneralDay(
        id: id,
        date: date,
        rested: rested,
        nutrition: nutrition,
        concentration: concentration,
        reflections: reflections);
    GeneralDay foundgd = GeneralDay();

    int exists = 0;
    for (GeneralDay gd in await DBHelper.getGeneralDay()) {
      print("gd: " +
          gd.date.substring(0, 10) +
          " ... now: " +
          DateTime.now().toString().substring(0, 10));
      if (gd.date.toString().substring(0, 10) ==
          DateTime.now().toString().substring(0, 10)) {
        exists = 1;
        foundgd = gd;
      }
    }
    if (exists == 0) {
      if (this.id == null || this.id[0] == 'x') {
        this.id = 'x${DateTime.now().millisecondsSinceEpoch}';
        DBHelper.updateGeneralDayList([this]);
        _userRepository.diary.generalDayList.add(this);
      }
    } else {
      this.id = foundgd.id;
    }
    if (this.id != null) {
      if (this.id[0] != 'e') {
        if (this.id[0] != 'x') {
          _userRepository.diary.generalDayList.remove(this);
          DBHelper.deleteGeneralDayItem([this]);
          this.id = 'e' + this.id;
          DBHelper.updateGeneralDayList([this]);
          _userRepository.diary.generalDayList.add(this);
        }
      }
    }
    _userRepository.diaryItemsToSend.add(this);

    if (await hasInternetConnection()) {
      _newGeneralDay = await upload(_userRepository);
    }
    return _newGeneralDay;
  }

  Future<String> delete(UserRepository _userRepository) async {
    String tempid = "";
    if (this.id[0] == "d") {
      tempid = this.id.substring(1);
    } else {
      tempid = this.id;
    }
    //delete from server
    var response = await http.delete(kAPIAddress + '/api/general-day/$tempid/',
        headers: {
          'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
        });
    //if status correct, delete from to delete list
    if (response.statusCode == 204) {
      _userRepository.diaryItemsToDelete.remove(this);
    }
  }

  Future<void> deleteGeneralDayItem(UserRepository _userRepository) async {
    //delete from local db
    DBHelper.deleteGeneralDayItem([this]);

    if (this.id[0] != 'd') {
      this.id = 'd' + this.id;
    }
    //add to delete list
    int found = 0;
    for (DiaryModel item in _userRepository.diaryItemsToDelete) {
      if (item == this) {
        found = 1;
      }
    }
    if (found == 0) {
      _userRepository.diaryItemsToDelete.add(this);
    }
    if (await hasInternetConnection()) {
      this.delete(_userRepository);
    }
  }
}

Future<List<GeneralDay>> getGeneralDayList(String jwt) async {
  var response = await http.get(kAPIAddress + '/api/general-day/',
      headers: {'Authorization': 'JWT ' + jwt});
  List body = jsonDecode(response.body);
  List<GeneralDay> generalDays = [];
  for (var day in body) {
    GeneralDay newDay = GeneralDay()
      ..date = day['date']
      ..rested = day['rested']
      ..nutrition = day['nutrition']
      ..concentration = day['concentration']
      ..reflections = day['reflections']
      ..id = day['id'].toString();
    generalDays.add(newDay);
  }

  return generalDays;
}

class Competition extends DiaryModel {
  String date;
  String name;
  String address;
  String startTime;
  String id;

  Competition({this.date, this.name, this.address, this.startTime, this.id});

  Future<Competition> upload(UserRepository _userRepository) async {
    Map body = {};
    if (this.date != null) body['date'] = this.date;
    if (this.name != null) body['name'] = this.name;
    if (this.address != null) body['address'] = this.address;
    if (this.startTime != null) body['start_time'] = this.startTime;
    if (this.date != null) body['date'] = this.date.substring(0, 10);

    var response;

    String tempid = this.id.substring(1);
    if (this.id[0] == "e") {
      response = await http.patch(kAPIAddress + '/api/competition/$tempid/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    } else {
      response = await http.post(kAPIAddress + '/api/competition/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    }

    Map responseBody = jsonDecode(response.body);
    if ((response.statusCode / 100).floor() != 2) {
      throw ServerErrorException;
    }
    Competition _newCompetition = Competition()
      ..name = responseBody['name']
      ..date = responseBody['date']
      ..address = responseBody['address']
      ..startTime = responseBody['start_time']
      ..id = responseBody['id'].toString();

    if (response.statusCode == 201) {
      _userRepository.diary.competitionList.remove(this);
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteCompetition([this]);
      DBHelper.updateCompetitionsList([_newCompetition]);
      _userRepository.diary.competitionList.add(_newCompetition);
    } else if (response.statusCode == 200) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteCompetition([this]);
      // DBHelper.updateCompetitionsList([this]);
    }

    print("now");
    for (Competition a in await DBHelper.getCompetitions()) {
      print(a.id);
    }
    return this;
  }

  Future<Competition> uploadCompetition(UserRepository _userRepository) async {
    Competition _newCompetition = Competition(
        name: name, date: date, address: address, startTime: startTime, id: id);

    if (this.id == null) {
      this.id = 'x${DateTime.now().millisecondsSinceEpoch}';
      DBHelper.updateCompetitionsList([this]);
    }
    if (this.id != null) {
      if (this.id[0] != 'e' && this.id[0] != 'x') {
        DBHelper.deleteCompetition([this]);
        this.id = 'e' + this.id;
        DBHelper.updateCompetitionsList([this]);
      }
    }
    _userRepository.diaryItemsToSend.add(this);
    if (await hasInternetConnection()) {
      _newCompetition = await upload(_userRepository);
    }
    return _newCompetition;
  }

  Future<String> delete(UserRepository _userRepository) async {
    String tempid = "";
    if (this.id[0] == "d") {
      tempid = this.id.substring(1);
    } else {
      tempid = this.id;
    }
    //delete from server
    var response = await http.delete(kAPIAddress + '/api/competition/$tempid/',
        headers: {
          'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
        });
    //if status correct, delete from to delete list
    if (response.statusCode == 204) {
      _userRepository.diaryItemsToDelete.remove(this);
    }
  }

  Future<void> deleteComp(UserRepository _userRepository) async {
    //delete from local db
    DBHelper.deleteCompetition([this]);
    if (this.id[0] != 'd') {
      this.id = "d" + this.id;
    }
    //add to delete list
    int found = 0;
    for (DiaryModel item in _userRepository.diaryItemsToDelete) {
      if (item == this) {
        found = 1;
      }
    }
    if (found == 0) {
      _userRepository.diaryItemsToDelete.add(this);
    }

    if (await hasInternetConnection()) {
      this.delete(_userRepository);
    }
  }
}

Future<void> deleteCompetition(String jwt, Competition competition) async {
  String id = competition.id;
  var response = await http.delete(kAPIAddress + '/api/competition/$id/',
      headers: {'Authorization': 'JWT ' + jwt});
  DBHelper.deleteCompetition([competition]);
}

Future<List<Competition>> getCompetitionList(String jwt) async {
  var response = await http.get(kAPIAddress + '/api/competition/',
      headers: {'Authorization': 'JWT ' + jwt});
  List body = jsonDecode(response.body);
  List<Competition> competitions = [];
  for (var competition in body) {
    Competition newComp = Competition()
      ..date = competition['date']
      ..name = competition['name']
      ..address = competition['address']
      ..startTime = competition['start_time']
      ..id = competition['id'].toString();

    competitions.add(newComp);
  }
  return competitions;
}

class Result extends DiaryModel {
  String id;
  String date;
  String name;
  int position;
  String reflections;

  Result({this.id, this.date, this.name, this.position, this.reflections});

//photo?

  Future<Result> upload(UserRepository _userRepository) async {
    Map body = {};
    if (this.date != null) body['date'] = this.date;
    if (this.name != null) body['name'] = this.name;
    if (this.position != null) body['position'] = this.position.toString();
    if (this.reflections != null) body['reflections'] = this.reflections;
    var response;
    String tempid = this.id.substring(1);
    if (this.id[0] == "e") {
      response = await http.patch(kAPIAddress + '/api/result/$tempid/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    } else {
      response = await http.post(kAPIAddress + '/api/result/',
          headers: {
            'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
          },
          body: body);
    }
    Map responseBody = jsonDecode(response.body);
    if ((response.statusCode / 100).floor() != 2) {
      throw ServerErrorException;
    }
    Result _newResult = Result()
      ..name = responseBody['name']
      ..date = responseBody['date']
      ..position = responseBody['position']
      ..reflections = responseBody['reflections']
      ..id = responseBody['id'].toString();

    if (response.statusCode == 201) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteResult([this]);
      DBHelper.updateResultList([_newResult]);
    } else if (response.statusCode == 200) {
      _userRepository.diaryItemsToSend.remove(this);
      DBHelper.deleteResult([this]);
      DBHelper.updateResultList([_newResult]);
    }

    return _newResult;
  }

  Future<Result> uploadResult(UserRepository _userRepository) async {
    Result _newResult = Result(
        name: name,
        date: date,
        position: position,
        reflections: reflections,
        id: id);

    if (this.id == null) {
      this.id = 'x${DateTime.now().millisecondsSinceEpoch}';
      DBHelper.updateResultList([this]);
    }
    if (this.id != null) {
      if (this.id[0] != 'e' && this.id[0] != 'x') {
        DBHelper.deleteResult([this]);
        this.id = 'e' + this.id;
        DBHelper.updateResultList([this]);
      }
    }
    _userRepository.diaryItemsToSend.add(this);
    if (await hasInternetConnection()) {
      _newResult = await upload(_userRepository);
    }
    return _newResult;
  }

  Future<String> delete(UserRepository _userRepository) async {
    String tempid = "";
    if (this.id[0] == "d") {
      tempid = this.id.substring(1);
    } else {
      tempid = this.id;
    }
    //delete from server
    var response = await http.delete(kAPIAddress + '/api/result/$tempid/',
        headers: {
          'Authorization': 'JWT ' + await _userRepository.refreshIdToken()
        });
    //if status correct, delete from to delete list
    if (response.statusCode == 204) {
      _userRepository.diaryItemsToDelete.remove(this);
    }
  }

  Future<String> deleteRes(UserRepository _userRepository) async {
    if (this.id[0] != 'd') {
      this.id = "d" + this.id;
    }
    //delete from local db
    DBHelper.deleteResult([this]);
    //add to delete list
    int found = 0;
    for (DiaryModel item in _userRepository.diaryItemsToDelete) {
      if (item == this) {
        found = 1;
      }
    }
    if (found == 0) {
      _userRepository.diaryItemsToDelete.add(this);
    }
    if (await hasInternetConnection()) {
      this.delete(_userRepository);
    }
  }
}

Future<List<Result>> getResultList(String jwt) async {
  var response = await http.get(kAPIAddress + '/api/result/',
      headers: {'Authorization': 'JWT ' + jwt});
  List body = jsonDecode(response.body);
  List<Result> results = [];
  for (var result in body) {
    Result newResult = Result()
      ..date = result['date']
      ..name = result['name']
      ..position = result['position']
      ..reflections = result['reflections']
      ..id = result['id'].toString();

    results.add(newResult);
  }
  print(results);
  return results;
}

Future<void> deleteResult(String jwt, Result result) async {
  String id = result.id;
  var response = await http.delete(kAPIAddress + '/api/result/$id/',
      headers: {'Authorization': 'JWT ' + jwt});
  DBHelper.deleteResult([result]);
}

class Diary {
  List<Session> sessionList = [];
  List<Competition> competitionList = [];
  List<GeneralDay> generalDayList = [];
  List<Result> resultList = [];
  List<Goal> ultimateGoal = [];
  List<Goal> longTermGoal = [];
  List<Goal> mediumTermGoals = [];
  List<Goal> shortTermGoals = [];
  List<Goal> finishedGoals = [];
  List<Objective> finishedObjectives = [];
  Objective intensityObjective;
  Objective hoursWorkedObjective;
  Objective performanceObjective;
}

/// add it to these lists
/// add it to the database
