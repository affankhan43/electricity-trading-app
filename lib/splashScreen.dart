import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'platformScaffold.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() =>  _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int splashDuration = 2;

  startTime() async {
    return Timer(
        Duration(seconds: splashDuration),
            () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pushReplacementNamed('/LoginScreen');
        }
    );
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(gradient: LinearGradient(
              colors: [Colors.green[600],Colors.white24],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )),
            child: Column(
              children: <Widget>[
                titleSection(),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          )
        );
      }

  Container titleSection(){
    return Container(
      alignment: Alignment(0.0,0.0,),
      padding: EdgeInsets.only(top: 40.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.battery_charging_full,size: 49.0,color: Colors.black38,),
          Text("Trade Energy",style: TextStyle(color: Colors.black38,fontSize: 42,fontWeight: FontWeight.w900)),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        ),
    );
  }
  
  }