import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/stats_page.dart';
import 'pages/splashScreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  var splashScreen = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Trade Energy",
      routes: <String,WidgetBuilder>{
        "/LoginScreen": (BuildContext context) => LoginPage(),
        "/StatsPage"  : (BuildContext context) => MainPage(),
      },
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        accentColor: Colors.white70
      ),
    );
  }
  }