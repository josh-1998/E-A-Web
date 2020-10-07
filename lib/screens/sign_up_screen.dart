import 'package:e_athlete_web/blocs/authentification/authentification_bloc.dart';
import 'package:e_athlete_web/blocs/log_in/log_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../misc/user_repository.dart';
import 'package:e_athlete_web/common_widgets/common_widgets.dart';

import 'package:e_athlete_web/screens/homepage_screen.dart';

class SignUpPage extends StatefulWidget {
  static const String id = 'login page';
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogInBloc, LogInState>(
      listener: (BuildContext context, LogInState state) {
        if (state is SuccessfulLogin) {
          AuthenticationBloc _authentificationBloc = AuthenticationBloc(
              userRepository:
                  Provider.of<UserRepository>(context, listen: false));
          _authentificationBloc.add(LoggedIn());
          Navigator.pop(context);
          Navigator.popAndPushNamed(context, MyHomePage.id);
          //TODO: Navigator.pushNamed(context, ProfileEditPage.id);
        }
      },
      child: BlocBuilder(
          bloc: BlocProvider.of<LogInBloc>(context),
          builder: (context, LogInState state) {
            if (state is SuccessfulLogin) {}
            return Scaffold();
          }),
    );
  }
}
