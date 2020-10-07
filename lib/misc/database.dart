import 'dart:async';
import 'dart:io' as io;

import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:e_athlete_web/models/goals.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/diary_model.dart';
import '../models/user_model.dart';

class DBHelper {
  static Database _db;

  static Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  static initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "user.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  static Future<void> dropTables() async {
    var dbClient = await db;
    await dbClient.execute("DROP TABLE IF EXISTS User");
    await dbClient.execute("DROP TABLE IF EXISTS Sessions");
    await dbClient.execute("DROP TABLE IF EXISTS GeneralDays");
    await dbClient.execute("DROP TABLE IF EXISTS Competitions");
    await dbClient.execute("DROP TABLE IF EXISTS Results");
    await dbClient.execute("DROP TABLE IF EXISTS Goals");
    await dbClient.execute("DROP TABLE IF EXISTS Objectives");
  }

  static void deleteDataFromTable(String tableName) async {
    var dbClient = await db;
    await dbClient.execute("DELETE FROM $tableName");
  }

  static void createUserTable() async {
    var dbClient = await db;

    await dbClient.execute(
        "CREATE TABLE User(id TEXT PRIMARY KEY, firstName TEXT, " +
            "lastName TEXT, dOB TEXT, profilePhoto TEXT, sex TEXT, " +
            "height INTEGER, weight INTEGER, sport TEXT, shortTermGoal TEXT, " +
            "mediumTermGoal TEXT, longTermGoal TEXT, jwt TEXT )");
    print("Created User table");
  }

  //There may be an error at some point where sql tries to create 2 tables

  // Creating a table name User with fields
  static void _onCreate(Database db, int version) async {}

  static Future<String> getJwt() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM User');
    return list[0]['jwt'];
  }

  static Future<List> getUser(User user) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM User');
    Map userMap = list[0];

    user.firstName = userMap['firstName'];
    user.lastName = userMap['lastName'];
    user.dOB = userMap['dOB'];
    user.profilePhoto = userMap['profilePhoto'];
    user.sex = userMap['sex'];
    user.height = userMap['height'];
    user.weight = userMap['weight'];
    user.sport = userMap['sport'];
    user.shortTermGoal = userMap['shortTermGoal'];
    user.mediumTermGoal = userMap['mediumTermGoal'];
    user.longTermGoal = userMap['longTermGoal'];
    user.jwt = userMap['jwt'];

    return list;
  }

  static void updateUser(User user) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawUpdate('UPDATE User ' +
          "SET " +
          "firstName = '${user.firstName}'," +
          "lastName = '${user.lastName}'," +
          "dOB = '${user.dOB}'," +
          "profilePhoto = '${user.profilePhoto}'," +
          "sex = '${user.sex}'," +
          "height = ${user.height}," +
          "weight = ${user.weight}," +
          "sport = '${user.sport}'," +
          "shortTermGoal = '${user.shortTermGoal}'," +
          "mediumTermGoal = '${user.mediumTermGoal}'," +
          "longTermGoal = '${user.longTermGoal}'" +
          "WHERE id = 1;");
    });
  }

  static void saveUser(User user) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert('INSERT INTO User (firstName,' +
          'lastName,' +
          'dOB,' +
          'profilePhoto,' +
          'sex,' +
          'height,' +
          'weight,' +
          'sport,' +
          'shortTermGoal,' +
          'mediumTermGoal,' +
          'longTermGoal,' +
          'jwt)'
              'VALUES ('
              "'${user.firstName}'," +
          "'${user.lastName}'," +
          "'${user.dOB}'," +
          "'${user.profilePhoto}'," +
          "'${user.sex}'," +
          "${user.height}," +
          "${user.weight}," +
          "'${user.sport}'," +
          "'${user.shortTermGoal}'," +
          "'${user.mediumTermGoal}'," +
          "'${user.longTermGoal}'," +
          "'${user.jwt}'" +
          ');');
    });
  }

  /// Used for  querying the internal memory and adding sessionList to the
  /// UserRepository model. Only called when app is opened and user is logged in
  static Future<List<Session>> getSessions() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Sessions');
    List<Session> sessionsList = [];
    for (var session in list) {
      Session newSession = Session();
      newSession.id = session['id'];
      newSession.title = session['title'];
      newSession.date = session['date'];
      newSession.lengthOfSession = session['lengthOfSession'];
      newSession.intensity = session['intensity'];
      newSession.performance = session['performance'];
      newSession.feeling = session['feeling'];
      newSession.target = session['target'];
      newSession.reflections = session['reflections'];
      sessionsList.add(newSession);
    }
    return sessionsList;
  }

  static void createSessionsTable() async {
    var dbClient = await db;

    await dbClient.execute(
        "CREATE TABLE Sessions (id TEXT PRIMARY KEY, title TEXT, " +
            "date TEXT, lengthOfSession INTEGER, intensity INTEGER, performance INTEGER, " +
            "feeling TEXT, target TEXT, reflections TEXT" +
            ")");
    print("Created Sessions table");
  }

  ///Adds the current sessionList to the sqflite internal memory
  static void updateSessionsList(List<Session> sessions) async {
    var dbClient = await db;
    for (Session session in sessions) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO  Sessions' +
                "(id, title, date, lengthOfSession, intensity, performance," +
                "feeling, target, reflections) VALUES(" +
                "?, ?, ?, ?, ?, ?, ?, ?, ?)",
            [
              session.id,
              session.title,
              session.date,
              session.lengthOfSession,
              session.intensity,
              session.performance,
              session.feeling,
              session.target,
              session.reflections
            ]);
      });
    }
  }

  static void deleteSession(List<Session> sessions) async {
    var dbClient = await db;
    for (Session session in sessions) {
      await dbClient.transaction((txn) async {
        return await txn
            .rawDelete('DELETE FROM Sessions WHERE id = ?', [session.id]);
      });
    }
  }

  static void updateSessionValue(List<Session> sessions) async {
    var dbClient = await db;
    for (Session session in sessions) {
      await dbClient.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE Sessions' +
                ' SET title = ?, date = ?, lengthOfSession = ?, intensity = ?, performance = ?, ' +
                'feeling = ?, target = ?, reflections = ?'
                    ' WHERE id = ?',
            [
              session.title,
              session.date,
              session.lengthOfSession,
              session.intensity,
              session.performance,
              session.feeling,
              session.target,
              session.reflections,
              session.id
            ]);
      });
    }
  }

  /// creates generalDayTable, when user logs in. This can then be populated
  static void createGeneralDayTable() async {
    var dbClient = await db;

    await dbClient.execute("CREATE TABLE GeneralDays (id TEXT PRIMARY KEY, " +
        "date TEXT, rested INTEGER, nutrition INTEGER, concentration INTEGER, " +
        "reflections TEXT" +
        ")");
    print("Created GeneralDays table");
  }

  /// Used for  querying the internal memory and adding generalDayList to the
  /// UserRepository model. Only called when app is opened and user is logged in
  static Future<List<GeneralDay>> getGeneralDay() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM GeneralDays');
    List<GeneralDay> generalDayList = [];
    for (var generalDay in list) {
      GeneralDay newGeneralDay = GeneralDay();
      newGeneralDay.id = generalDay['id'];
      newGeneralDay.date = generalDay['date'];
      newGeneralDay.rested = generalDay['rested'];
      newGeneralDay.nutrition = generalDay['nutrition'];
      newGeneralDay.concentration = generalDay['concentration'];
      newGeneralDay.reflections = generalDay['reflections'];
      generalDayList.add(newGeneralDay);
    }
    return generalDayList;
  }

  static void updateGeneralDayList(List<GeneralDay> generalDays) async {
    var dbClient = await db;
    for (GeneralDay generalDay in generalDays) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO  GeneralDays' +
                "(id, date, rested, nutrition, concentration," +
                "reflections) VALUES(" +
                "?, ?, ?, ?, ?, ?)",
            [
              generalDay.id,
              generalDay.date,
              generalDay.rested,
              generalDay.nutrition,
              generalDay.concentration,
              generalDay.reflections
            ]);
      });
    }
  }

  static void updateGeneralDayValue(List<GeneralDay> generalDays) async {
    var dbClient = await db;
    for (GeneralDay generalDay in generalDays) {
      await dbClient.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE GeneralDays' +
                ' SET date = ?, rested = ?, nutrition = ?, concentration = ?, reflections = ?' +
                ' WHERE id = ?',
            [
              generalDay.date,
              generalDay.rested,
              generalDay.nutrition,
              generalDay.concentration,
              generalDay.reflections,
              generalDay.id
            ]);
      });
    }
  }

  static void deleteGeneralDayItem(List<GeneralDay> generalDays) async {
    var dbClient = await db;
    for (GeneralDay generalDay in generalDays) {
      await dbClient.transaction((txn) async {
        return await txn
            .rawDelete('DELETE FROM GeneralDays WHERE id = ?', [generalDay.id]);
      });
    }
  }

  static void createCompetitionTable() async {
    var dbClient = await db;

    await dbClient.execute(
        "CREATE TABLE Competitions(id TEXT PRIMARY KEY, name TEXT, " +
            "date TEXT, startTime TEXT, address TEXT)");
    print("Created Competitions table");
  }

  /// Used for  querying the internal memory and adding generalDayList to the
  /// UserRepository model. Only called when app is opened and user is logged in
  static Future<List<Competition>> getCompetitions() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Competitions');
    List<Competition> competitionList = [];
    for (var competition in list) {
      Competition newCompetition = Competition();
      newCompetition.id = competition['id'];
      newCompetition.date = competition['date'];
      newCompetition.name = competition['name'];
      newCompetition.address = competition['address'];
      newCompetition.startTime = competition['startTime'];
      competitionList.add(newCompetition);
    }
    return competitionList;
  }

  static void updateCompetitionsList(List<Competition> competitions) async {
    var dbClient = await db;
    for (Competition competition in competitions) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO  Competitions' +
                "(id, date, name, address, startTime" +
                ") VALUES(" +
                "?, ?, ?, ?, ?)",
            [
              competition.id,
              competition.date,
              competition.name,
              competition.address,
              competition.startTime
            ]);
      });
    }
  }

  static void deleteCompetition(List<Competition> competitions) async {
    var dbClient = await db;
    for (Competition competition in competitions) {
      await dbClient.transaction((txn) async {
        return await txn.rawDelete(
            'DELETE FROM Competitions WHERE id = ?', [competition.id]);
      });
    }
  }

  static void updateCompetitionValue(List<Competition> competitions) async {
    var dbClient = await db;
    for (Competition competition in competitions) {
      await dbClient.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE Competitions' +
                ' SET date = ?, name = ?, address = ?, startTime = ?' +
                ' WHERE id = ?',
            [
              competition.date,
              competition.name,
              competition.address,
              competition.startTime,
              competition.id
            ]);
      });
    }
  }

  static void createResultsTable() async {
    var dbClient = await db;

    await dbClient.execute(
        "CREATE TABLE Results(id TEXT PRIMARY KEY, name TEXT, " +
            "date TEXT, position INTEGER, reflections TEXT)");
    print("Created Results table");
  }

  /// Used for  querying the internal memory and adding generalDayList to the
  /// UserRepository model. Only called when app is opened and user is logged in
  static Future<List<Result>> getResults() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Results');
    List<Result> resultList = [];
    for (var result in list) {
      Result newResult = Result();
      newResult.id = result['id'];
      newResult.date = result['date'];
      newResult.name = result['name'];
      newResult.position = result['position'];
      newResult.reflections = result['reflections'];
      resultList.add(newResult);
    }
    return resultList;
  }

  static void updateResultList(List<Result> results) async {
    var dbClient = await db;
    for (Result result in results) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO  Results' +
                "(id, date, name, position, reflections" +
                ") VALUES(" +
                "?, ?, ?, ?, ?)",
            [
              result.id,
              result.date,
              result.name,
              result.position,
              result.reflections
            ]);
      });
    }
  }

  static void deleteResult(List<Result> results) async {
    var dbClient = await db;
    for (Result result in results) {
      await dbClient.transaction((txn) async {
        return await txn
            .rawDelete('DELETE FROM Results WHERE id = ?', [result.id]);
      });
    }
  }

  static void updateResultValue(List<Result> results) async {
    var dbClient = await db;
    for (Result result in results) {
      await dbClient.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE Results' +
                ' SET date = ?, name = ?, position = ?, reflections = ?' +
                ' WHERE id = ?',
            [
              result.date,
              result.name,
              result.position,
              result.reflections,
              result.id
            ]);
      });
    }
  }

  static void createGoalsTable() async {
    var dbClient = await db;

    await dbClient.execute(
        "CREATE TABLE Goals(id TEXT PRIMARY KEY, content TEXT, " +
            "setOnDate TEXT, deadlineDate TEXT, goalType TEXT, achieved TEXT)");
    print("Created Goals table");
  }

  static Future<List<Goal>> getShortTermGoals() async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Goals WHERE goalType = \'Short Term\'');
    List<Goal> goalList = [];
    for (var goal in list) {
      Goal newGoal = Goal();
      newGoal.id = goal['id'];
      newGoal.deadlineDate = goal['deadlineDate'];
      newGoal.content = goal['content'];
      newGoal.setOnDate = goal['setOnDate'];
      newGoal.goalType = goal['goalType'];
      newGoal.achieved = goal['achieved'];
      if (newGoal.id != null && newGoal.id[0] != 'd') {
        print('newGoal');
        print(newGoal.id);
        goalList.add(newGoal);
      }
    }
    return goalList;
  }

  static Future<List<Goal>> getMediumTermGoals() async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Goals WHERE goalType = \'Medium Term\'');
    print(list);
    List<Goal> goalList = [];
    for (var goal in list) {
      Goal newGoal = Goal();
      newGoal.id = goal['id'];
      newGoal.deadlineDate = goal['deadlineDate'];
      newGoal.content = goal['content'];
      newGoal.setOnDate = goal['setOnDate'];
      newGoal.goalType = goal['goalType'];
      newGoal.achieved = goal['achieved'];
      if (newGoal.id != null && newGoal.id[0] != 'd') {
        goalList.add(newGoal);
      }
    }
    return goalList;
  }

  static Future<List<Goal>> getLongTermGoals() async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Goals WHERE goalType = \'Long Term\'');
    print(list);
    List<Goal> goalList = [];
    for (var goal in list) {
      Goal newGoal = Goal();
      newGoal.id = goal['id'];
      newGoal.deadlineDate = goal['deadlineDate'];
      newGoal.content = goal['content'];
      newGoal.setOnDate = goal['setOnDate'];
      newGoal.goalType = goal['goalType'];
      newGoal.achieved = goal['achieved'];
      if (newGoal.id != null && newGoal.id[0] != 'd') {
        goalList.add(newGoal);
      }
    }
    return goalList;
  }

  static Future<List<Goal>> getUltimateGoal() async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Goals WHERE goalType = \'Ultimate\'');
    List<Goal> goalList = [];
    for (var goal in list) {
      Goal newGoal = Goal();
      newGoal.id = goal['id'];
      newGoal.deadlineDate = goal['deadlineDate'];
      newGoal.content = goal['content'];
      newGoal.setOnDate = goal['setOnDate'];
      newGoal.goalType = goal['goalType'];
      newGoal.achieved = goal['achieved'];
      if (newGoal.id != null && newGoal.id[0] != 'd') {
        goalList.add(newGoal);
      }
    }
    return goalList;
  }

  static Future<List<Goal>> getFinishedTermGoals() async {
    var dbClient = await db;
    List<Map> list = await dbClient
        .rawQuery('SELECT * FROM Goals WHERE goalType = \'Finished\'');
    print(list);
    List<Goal> goalList = [];
    for (var goal in list) {
      Goal newGoal = Goal();
      newGoal.id = goal['id'];
      newGoal.deadlineDate = goal['deadlineDate'];
      newGoal.content = goal['content'];
      newGoal.setOnDate = goal['setOnDate'];
      newGoal.goalType = goal['goalType'];
      newGoal.achieved = goal['achieved'];
      if (newGoal.id != null && newGoal.id[0] != 'd') {
        goalList.add(newGoal);
      }
    }
    return goalList;
  }

  static void updateGoalsList(List<Goal> goals) async {
    var dbClient = await db;
    for (Goal goal in goals) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO  Goals' +
                "(id, deadlineDate, setOnDate, content, goalType, achieved" +
                ") VALUES(" +
                "?, ?, ?, ?, ?, ?)",
            [
              goal.id,
              goal.deadlineDate,
              goal.setOnDate,
              goal.content,
              goal.goalType,
              goal.achieved
            ]);
      });
    }
    print('updated goals list');
  }

  static void deleteGoal(List<Goal> goals) async {
    print('starting local delete');
    var dbClient = await db;
    for (Goal goal in goals) {
      print(goal.id);
      await dbClient.transaction((txn) async {
        return await txn.rawDelete('DELETE FROM Goals WHERE id = ?', [goal.id]);
      });
    }
  }

  static void updateGoalValue(List<Goal> goals) async {
    var dbClient = await db;
    for (Goal goal in goals) {
      await dbClient.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE Goals' +
                ' SET deadlineDate = ?, setOnDate = ?, content = ?, goalType = ?, achieved = ?' +
                ' WHERE id = ?',
            [
              goal.deadlineDate,
              goal.setOnDate,
              goal.content,
              goal.goalType,
              goal.achieved,
              goal.id
            ]);
      });
    }
    print('goal updated');
  }

  static void createObjectivesTable() async {
    var dbClient = await db;

    await dbClient.execute(
        "CREATE TABLE Objectives(id TEXT PRIMARY KEY, average INTEGER, " +
            "startDate TEXT, endDate TEXT, objectiveType TEXT, isFinished TEXT, hoursOfWork INTEGER)");
    print("Created Objectives table");
  }

  static Future<void> getObjectives(UserRepository _userRepository) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Objectives');
    print(1);
    for (var objective in list) {
      Objective newObjective = Objective();
      newObjective.id = objective['id'];

      newObjective.average = objective['average'];

      newObjective.endDate = DateTime.parse(objective['endDate']);

      newObjective.hoursOfWork = objective['hoursOfWork'];

      newObjective.startDate = DateTime.parse(objective['startDate']);

      newObjective.objectiveType = objective['objectiveType'];

      newObjective.isFinished = objective['isFinished'];

      if (newObjective.isFinished == 'true') {
        _userRepository.diary.finishedObjectives.add(newObjective);
      } else if (newObjective.objectiveType == 'Hours Worked') {
        _userRepository.diary.hoursWorkedObjective = newObjective;
      } else if (newObjective.objectiveType == 'Intensity') {
        _userRepository.diary.intensityObjective = newObjective;
      } else if (newObjective.objectiveType == 'Performance') {
        _userRepository.diary.performanceObjective = newObjective;
      }
    }
  }

  static void updateObjectives(List<Objective> objectives) async {
    var dbClient = await db;
    for (Objective objective in objectives) {
      await dbClient.transaction((txn) async {
        return await txn.rawInsert(
            'INSERT INTO  Objectives' +
                "(id, endDate, hoursOfWork, average, startDate, objectiveType, isFinished" +
                ") VALUES(" +
                "?, ?, ?, ?, ?, ?, ?)",
            [
              objective.id,
              objective.endDate.toIso8601String(),
              objective.hoursOfWork,
              objective.average,
              objective.startDate.toIso8601String(),
              objective.objectiveType,
              objective.isFinished
            ]);
      });
    }
    print('updated objectives list');
  }

  static void deleteObjective(List<Objective> objectives) async {
    var dbClient = await db;
    for (Objective objective in objectives) {
      await dbClient.transaction((txn) async {
        return await txn
            .rawDelete('DELETE FROM Objectives WHERE id = ?', [objective.id]);
      });
    }
  }

  static void updateObjectiveValue(List<Objective> objectives) async {
    var dbClient = await db;
    for (Objective objective in objectives) {
      await dbClient.transaction((txn) async {
        return await txn.rawUpdate(
            'UPDATE Objectives' +
                ' SET endDate = ?, hoursOfWork = ?, average = ?, startDate = ?, objectiveType = ?,' +
                ' isFinished = ? WHERE id = ?',
            [
              objective.endDate.toIso8601String(),
              objective.hoursOfWork,
              objective.average,
              objective.startDate.toIso8601String(),
              objective.objectiveType,
              objective.isFinished,
              objective.id
            ]);
      });
    }
    print('objective updated');
  }
}
