import 'package:flutter/material.dart';
import 'homepage_screen.dart' as hp;

class MyTeams extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Coach',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyTeamsPage(title: 'E-Coach'),
      //TODO: search-bar
    );
  }
}

class MyTeamsPage extends StatefulWidget {
  MyTeamsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyTeamsPageState createState() => _MyTeamsPageState();
}

class _MyTeamsPageState extends State<MyTeamsPage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  String searchTerm = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset("lib/images/51012169_padded_logo.png",
                fit: BoxFit.contain, height: 30),
            SizedBox(width: 5),
            Text(widget.title),
            SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(4),
                //border: Border.all(color: Colors.lightBlue),
                color: Colors.grey[100],
              ),
              child: Row(
                children: [
                  Container(
                    width: 300,
                    child: TextField(
                      controller: myController,
                      decoration: const InputDecoration(
                        hintText: '   Search',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.black54),
                      ),
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                  IconButton(
                    hoverColor: Colors.white,
                    highlightColor: Colors.white,
                    focusColor: Colors.white,
                    disabledColor: Colors.white,
                    splashColor: Colors.white,
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchTerm = myController.text;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: <Widget>[
            SizedBox(height: 40),
            SideLayout(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class SideLayout extends StatelessWidget {
  const SideLayout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image(
                  image: AssetImage('lib/images/anon-profile-picture.png'),
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Name Of User',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Role Of User',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 40),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => hp.MyHomePage()),
                    );
                  },
                  //TODO: add overview logo
                  child: Text("Overview",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  color: Colors.grey[100],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyTeams()),
                    );
                  },

                  //TODO: add MyTeams logo
                  child: Text("My Teams",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add My Athletes logo
                  child: Text("My Athletes",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Sessions logo
                  child: Text("Sessions",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Calendar logo
                  child: Text("Calendar",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Leaderboards logo
                  child: Text("Leaderboards",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add My Account logo
                  child: Text("My Account",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 50.0,
                child: FlatButton(
                  onPressed: () {
                    /*...*/
                  },
                  //TODO: add Logout logo
                  child: Text("Logout",
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
