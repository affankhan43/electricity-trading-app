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
  Future<Map> stats;
  SharedPreferences sharedPreferences;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();
  //String name = "";

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance
    //   .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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

  Future<Map> fetchStats() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String auth = "Bearer"+ sharedPreferences.getString("token");
    final response =
      await http.post(
        'http://ec2-3-15-209-246.us-east-2.compute.amazonaws.com/ssuet-electric/public/api/getStats',
        headers: {"authorization":auth,"Content-Type": "application/json","Accept": "application/json"}
      );
      
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      Map data = json.decode(response.body);
      return json.decode(json.encode(data['stats']));
    } else if(response.statusCode == 401){
      sharedPreferences.clear();
      sharedPreferences.commit();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
}
  Future<void> _refresh() async{
    getName().then((val)=>setState((){
      name.name = val.name;
      name.email = val.email;
      name.id = val.id;
    }));
    print('refreshing stocks...');
    stats =  fetchStats();
    return null;
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
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600],Colors.white24],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
        ),
        child: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.only(top:30.0,bottom: 35.0),
            children:<Widget>[
              Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.only(top: 18.0, bottom: 18.0, right: 15.0),
                    decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.blueAccent)
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Icon(Icons.assessment, color: Colors.black38,size: 23.0,),
                            Text("Stats",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 23.0,color: Colors.black38),),
                        ],
                    ),
                  ),
                ),
              ),
              FutureBuilder<Map>(
                future: stats,
                builder: (context, snapshot){
                  if (snapshot.hasData) {
                    bool voltage = snapshot.data.containsKey("Voltage");
                    bool mainpower = snapshot.data.containsKey("MainPower");
                    bool gtpower = snapshot.data.containsKey("GridTiePower");
                    bool loadpower = snapshot.data.containsKey("LoadPower");
                    bool maincurrent = snapshot.data.containsKey("MainCurrent");
                    bool gtcurrent = snapshot.data.containsKey("GridTieCurrent");
                    bool loadcurrent = snapshot.data.containsKey("LoadCurrent");
                    bool last_update = snapshot.data.containsKey("LastUpdated");
                    return Container(child:Column(children:<Widget>[
                      //statsList("Status","Disabled"),
                      voltage? statsList("Voltage", snapshot.data['Voltage'].toString()):Center(),
                      mainpower? statsList("Main Power", snapshot.data['MainPower'].toString()):Center(),
                      gtpower? statsList("GridTie Power", snapshot.data['GridTiePower'].toString()):Center(),
                      loadpower? statsList("Load Power", snapshot.data['LoadPower'].toString()):Center(),
                      maincurrent? statsList("Main Current", snapshot.data['MainCurrent'].toString()):Center(),
                      gtcurrent? statsList("GridTie Current", snapshot.data['GridTieCurrent'].toString()):Center(),
                      loadcurrent? statsList("LoadCurrent", snapshot.data['LoadCurrent'].toString()):Center(),
                      last_update? statsList("Last Updated At", snapshot.data['LastUpdated'].toString()):Center(),
                      ]));
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Center(child:CircularProgressIndicator(),);
            },
            ),
            ],
          ),
          ),
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
                title: Text("Trade Settings"),
                onTap: (){
                  Navigator.of(context).pushNamed('/TradePage');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  statsList(String title,String value)=>
    Card(
      color: Colors.transparent,
      elevation: 0.0,
      child: InkWell(
        child: Container(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0, right: 15.0),
          decoration: BoxDecoration(
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: Colors.blueAccent[200])
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                  Text(title+":  ",style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w600,color: Colors.black38)),
                  Text(value)
              ],
          ),
        ),
      ),
    );
}