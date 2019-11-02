import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
 String name="";
class _MainPageState extends State<MainPage> {

  SharedPreferences sharedPreferences;
  //String name = "";

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    getName().then((val)=>setState((){
      name = val;
    }));
  }

  Future<String> getName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("name");
  }
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }
  }

  @override
  Widget build(BuildContext context){
    checkLoginStatus();
    return Scaffold(
      appBar: AppBar(
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
      body: Center(child: Text(name)),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
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
    );
  }
}