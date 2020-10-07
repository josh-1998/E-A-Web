import 'package:e_athlete_web/misc/message_handler.dart';
import 'package:e_athlete_web/misc/network_handler.dart';
import 'package:e_athlete_web/screens/homepage_screen.dart';
// import 'package:e_athlete_web/screens/goals.dart';
// import 'package:e_athlete_web/screens/loading_screen.dart';

import 'package:e_athlete_web/screens/log_in_screen.dart';
// import 'package:e_athlete_web/screens/main_page.dart';

// import 'package:e_athlete_web/screens/new_graph.dart';
import 'package:e_athlete_web/screens/new_loading_screen.dart';
// import 'package:e_athlete_web/screens/notifications.dart';
// import 'package:e_athlete_web/screens/profile_edit_page.dart';
// import 'package:e_athlete_web/screens/settings.dart';
// import 'package:e_athlete_web/screens/sign_up_screen.dart';
// import 'package:e_athlete_web/screens/test_stuff.dart';
// import 'package:e_athlete_web/screens/timer.dart';
import 'package:e_athlete_web/misc/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/core.dart';

import 'blocs/authentification/authentification_bloc.dart';
import 'blocs/goals/goals_bloc.dart';
import 'models/class_definitions.dart';
import 'misc/simple_bloc_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  SyncfusionLicense.registerLicense(
      "NT8mJyc2IWhia31hfWN9Z2ZoYmF8YGJ8ampqanNiYmlmamlmanMDHmgjOzo/OiM+MiEgO2JmYRM0PjI6P30wPD4=");
  int pageNumber = 1;
  runApp(ProxyProvider0(
    update: (a, b) => PageNumber(),
    child: ListenableProvider<UserRepository>(
      create: (context) => UserRepository(),
      child: BlocProvider(
          create: (context) => AuthenticationBloc(
              userRepository:
                  Provider.of<UserRepository>(context, listen: false))
            ..add(AppStarted()),
          child: MyApp(userRepository: userRepository)),
    ),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return NetworkHandler(
      child: MyMessageHandler(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            buttonColor: Colors.grey,
            primarySwatch: Colors.grey,
          ),
          routes: {
            LoginPage.id: (context) => LoginPage(),
            //SignUpPage.id: (context) => SignUpPage(),
            MyHomePage.id: (context) => MyHomePage(),
            //ProfileEditPage.id: (context) => ProfileEditPage(),
            //TimerPageActual.id: (context) => TimerPageActual(),
            //Notifications.id: (context) => Notifications(),
            //Settings.id: (context) => Settings(),
          },
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              Provider.of<PageNumber>(context).pageNumber = 0;
              if (state is Loading) {
                return NewLoadingScreen();
              }
              if (state is Uninitialized) {
                return LoginPage();
              }
              if (state is Authenticated) {
                return MyHomePage(
                  pageNumber: Provider.of<PageNumber>(context).pageNumber,
                );
              }
              if (state is Unauthenticated) {
                return LoginPage();
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
