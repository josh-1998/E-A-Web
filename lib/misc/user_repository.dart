import 'package:e_athlete_web/models/class_definitions.dart';
import 'package:e_athlete_web/models/goals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'database.dart';
import '../models/diary_model.dart';
import '../models/user_model.dart';
import 'package:connectivity/connectivity.dart';

/// This class contains logic for the user to log in, as well as containing user
/// info and diary info
class UserRepository extends ChangeNotifier {
  ///instances for login of user
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FacebookLogin _facebookLogin;

  ///information about user that can be accessed by the rest of the app
  List<UserNotification> notifications;
  User user;
  Diary diary;
  List<DiaryModel> diaryItemsToSend = [];
  List<DiaryModel> diaryItemsToDelete = [];

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _facebookLogin = FacebookLogin(),
        user = User(),
        diary = Diary();

  Future<User> signInWithFacebook(bool isDeleted) async {
    final FacebookLoginResult facebookUser =
        await _facebookLogin.logIn(['email']);
    final FacebookAccessToken facebookAccessToken = facebookUser.accessToken;
    final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: facebookAccessToken.token);
    var _authResult = await _firebaseAuth.signInWithCredential(credential);
    FirebaseUser firebaseUser = _authResult.user;
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(firebaseUser.uid == currentUser.uid);
    IdTokenResult idToken = await firebaseUser.getIdToken();
    String jwt = idToken.token;
    user.jwt = jwt;

    if (!isDeleted) await setUserOnSignin();
    return user;
  }

  Future<User> signInWithGoogle(bool isDelete) async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      var _authResult = await _firebaseAuth.signInWithCredential(credential);
      FirebaseUser firebaseUser = _authResult.user;
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(firebaseUser.uid == currentUser.uid);
      IdTokenResult idToken = await firebaseUser.getIdToken();
      String jwt = idToken.token;
      user.jwt = jwt;
      if (!isDelete) await setUserOnSignin();
      return user;
    } catch (e) {
      throw e;
    }
  }

  ///method to be called when a user signs in, which makes calls to api to
  ///get all user info and store it on the device
  Future<void> setUserOnSignin() async {
    await user.getUserInfo(await refreshIdToken());
    // create tables in internal database
    DBHelper.initDb();
    DBHelper.createUserTable();
    DBHelper.createSessionsTable();
    DBHelper.createGeneralDayTable();
    DBHelper.createCompetitionTable();
    DBHelper.createResultsTable();
    DBHelper.createGoalsTable();
    DBHelper.createObjectivesTable();
    DBHelper.saveUser(user);
    // fetch data from server and add it to user model
    diary.sessionList = await getSessionList(user.jwt);
    diary.generalDayList = await getGeneralDayList(user.jwt);
    diary.competitionList = await getCompetitionList(user.jwt);
    diary.resultList = await getResultList(user.jwt);
    diary.performanceObjective = await getObjective(user.jwt, 'Performance');
    diary.hoursWorkedObjective = await getObjective(user.jwt, 'Hours Worked');
    diary.intensityObjective = await getObjective(user.jwt, 'Intensity');
    diary.shortTermGoals = await getGoals(user.jwt, "Short");
    diary.mediumTermGoals = await getGoals(user.jwt, "Medium");
    diary.longTermGoal = await getGoals(user.jwt, "Long");
    diary.finishedGoals = await getGoals(user.jwt, "Finished");
    diary.ultimateGoal = await getGoals(user.jwt, 'Ultimate');
    // store data from user model in the user database
    DBHelper.updateSessionsList(diary.sessionList);
    DBHelper.updateGeneralDayList(diary.generalDayList);
    DBHelper.updateCompetitionsList(diary.competitionList);
    DBHelper.updateResultList(diary.resultList);
    DBHelper.updateObjectives([
      diary.intensityObjective,
      diary.hoursWorkedObjective,
      diary.performanceObjective
    ]);
    DBHelper.updateGoalsList(diary.shortTermGoals +
        diary.mediumTermGoals +
        diary.longTermGoal +
        diary.finishedGoals +
        diary.ultimateGoal);
  }

  Future<void> signInWithCredentials(
      String email, String password, bool isDelete) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final FirebaseUser currentUser = await _firebaseAuth.currentUser();

    IdTokenResult idToken = await currentUser.getIdToken();
    String jwt = idToken.token;
    user.jwt = jwt;
    await user.getUserInfo(await refreshIdToken());
    if (!isDelete) await setUserOnSignin();
  }

  Future<String> refreshIdToken() async {
    try {
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      IdTokenResult idToken = await currentUser.getIdToken();
      String jwt = idToken.token;
      return jwt;
    } catch (e) {
      print(e);
      return 'failed';
    }
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      currentUser.sendEmailVerification();
      IdTokenResult idToken = await currentUser.getIdToken();
    } catch (e) {
      throw e;
    }
//    String jwt= idToken.token;
//    user.jwt = jwt;
//    try{
//    await user.getUserInfo();
//    DBHelper.initDb();
//    DBHelper.createUserTable();
//    DBHelper.saveUser(user);}
//    catch(e){throw e;}
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      DBHelper.dropTables(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<FirebaseUser> getUser() async {
    return (await _firebaseAuth.currentUser());
  }

  Future<void> deleteUser() async {
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    await user.deleteUser(await refreshIdToken());
    currentUser.delete();
  }
}
