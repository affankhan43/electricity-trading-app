import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../models/userModel.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}
 
class _WalletPageState extends State<WalletPage> {
  UserModel name = new UserModel(0,"","");
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

  @override
  Widget build(BuildContext context){
    checkLoginStatus();
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
        child: Center(child: Text(name.name)),
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