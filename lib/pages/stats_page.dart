import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../models/userModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
 
class _MainPageState extends State<MainPage> {
  UserModel name = new UserModel(0,"","");
  Future<String> stats;
  SharedPreferences sharedPreferences;
  //String name = "";

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    getName().then((val)=>setState((){
      name.name = val.name;
      name.email = val.email;
      name.id = val.id;
    }));
    stats =  fetchStats();
  }
  Future<UserModel> getName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var data = new UserModel(sharedPreferences.getInt("id"), sharedPreferences.getString("name"), sharedPreferences.getString("email"));
    // Map array;
    // array['name'] = sharedPreferences.getString("name");
    // array['email'] = sharedPreferences.getString("email");
    return data;
  }
  
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }
  }

  Future<String> fetchStats() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String auth = "Bearer"+ sharedPreferences.getString("token");
    final response =
      await http.post(
        'http://ec2-3-15-209-246.us-east-2.compute.amazonaws.com/ssuet-electric/public/api/getStats',
        headers: {"authorization":auth,"Content-Type": "application/json","Accept": "application/json"}
      );
      
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return (json.encode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("Stats", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600],Colors.white24],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
        ),
        child: FutureBuilder<String>(
          future: stats,
          builder: (context, snapshot){
            if (snapshot.hasData) {
              return Text(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.green[600]
        ),
        child: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top:30.0,bottom:30.0),
                alignment: Alignment(0.0,0.0),
                child: Column(
                  children: <Widget>[
                    Text(name.name,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20.0)),
                    Text(name.email,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14.0)),
                  ],
                ),
              ),
              Divider(
                color:Colors.black38,
                thickness: 7.0,
                indent: 7.0,
                endIndent: 7.0,
              ),
              ListTile(
                title: Text("Wallet"),
                onTap: (){
                  Navigator.of(context).pushNamed('/WalletPage');
                },
              ),
              ListTile(
                title: Text("Name"),
                onTap: (){
                  print(sharedPreferences.getString("name"));
                },
              ),
              ListTile(
                title: Text("Token"),
                onTap: (){
                  print(sharedPreferences.getString("token"));
                },
              ),
              ListTile(
                title: Text("Email"),
                onTap: (){
                  print(sharedPreferences.getString("email"));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}