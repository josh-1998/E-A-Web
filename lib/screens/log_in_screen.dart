import 'package:e_athlete_web/blocs/authentification/authentification_bloc.dart';
import 'package:e_athlete_web/blocs/log_in/log_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../misc/user_repository.dart';
import 'package:e_athlete_web/common_widgets/common_widgets.dart';

import 'package:e_athlete_web/screens/homepage_screen.dart';
import 'package:e_athlete_web/screens/sign_up_screen.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            LogInBloc(Provider.of<UserRepository>(context, listen: false)),
        child: Scaffold(body: Builder(builder: (BuildContext context) {
          return BlocListener<LogInBloc, LogInState>(
              listener: (context, state) {
            if (state is SuccessfulLogin) {
              AuthenticationBloc _authentificationBloc = AuthenticationBloc(
                  userRepository:
                      Provider.of<UserRepository>(context, listen: false));
              _authentificationBloc.add(LoggedIn());
              if (Provider.of<UserRepository>(context, listen: false)
                      .user
                      .firstName ==
                  '') {
                Navigator.popAndPushNamed(context, MyHomePage.id);
                //Navigator.pushNamed(context, ProfileEditPage.id);
              } else {
                Navigator.popAndPushNamed(context, MyHomePage.id);
              }
            }
            if (state is LoginFailure) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.error),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Login Failure'),
                  ],
                )));
            }
          }, child: BlocBuilder<LogInBloc, LogInState>(
                  builder: (BuildContext context, LogInState state) {
            if (state is IsSubmitting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Scaffold(
                body: Center(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: 500.0,
                  height: 600.0,
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset("lib/images/51012169_padded_logo.png",
                              fit: BoxFit.contain, height: 30),
                          Text(
                            "E-Coach",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(children: [
                          Text(
                            "Welcome Back!",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text("Login to continue"),
                        ]),
                      ),
                      SizedBox(height: 50),
                      AppStyledTextField(
                        onChanged: (value, context) =>
                            changeEmail(context, value),
                        icon: Icon(Icons.alternate_email,
                            color: Color(0xff828289)),
                        fieldName: 'Email Address',
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 5),
                      AppStyledTextField(
                        onChanged: (value, context) =>
                            changePassword(context, value),
                        icon: Icon(
                          Icons.lock_outline,
                          color: Color(0xff828289),
                        ),
                        fieldName: 'Password',
                        obscured: true,
                      ),
                      SizedBox(height: 20),
                      ButtonTheme(
                        buttonColor: Colors.blue[200],
                        minWidth: 200.0,
                        child: RaisedButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            submit(context);
                          },
                          child: Text("Submit"),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          SocialMediaButton(
                            image: Image.asset('lib/images/facebook_logo.png'),
                            text: 'Facebook',
                            onPressed: (context) {
                              LogInBloc loginBloc =
                                  BlocProvider.of<LogInBloc>(context);
                              loginBloc.add(FacebookLoginAttempt(false));
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SocialMediaButton(
                            image: Image.asset('lib/images/google_logo.png'),
                            text: 'Google',
                            onPressed: (context) {
                              print('Google');
                              LogInBloc loginBloc =
                                  BlocProvider.of<LogInBloc>(context);
                              loginBloc.add(GoogleLogin(false));
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      ButtonTheme(
                        buttonColor: Colors.blue[200],
                        minWidth: 200.0,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text("Sign Up"),
                        ),
                      ),
                    ],
                  )),
            )
                //TODO: Implement the look of the login page
                );
          }));
        })));
  }
}

void changeEmail(BuildContext context, String value) {
  LogInBloc loginBloc = BlocProvider.of<LogInBloc>(context);
  loginBloc.add(EmailChanged(value));
}

void changePassword(BuildContext context, String value) {
  LogInBloc loginBloc = BlocProvider.of<LogInBloc>(context);
  loginBloc.add(PasswordChanged(value));
}

void submit(BuildContext context) {
  LogInBloc loginBloc = BlocProvider.of<LogInBloc>(context);
  loginBloc.add(Submitted(false));
}

void facebookLogin(BuildContext context) {
  LogInBloc loginBloc = BlocProvider.of<LogInBloc>(context);
  loginBloc.add(FacebookLoginAttempt(false));
}

void googleLogin(BuildContext context) {
  LogInBloc loginBloc = BlocProvider.of<LogInBloc>(context);
  loginBloc.add(GoogleLogin(false));
}

void signUp(BuildContext context) {
  LogInBloc loginBloc = BlocProvider.of<LogInBloc>(context);
  loginBloc.add(SignUp());
}
