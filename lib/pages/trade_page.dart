import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../models/userModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../mixins/validations.dart';

class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}
 
class _TradePageState extends State<TradePage> with ValidationMixins{
  UserModel name = new UserModel(0,"","");
  Future<int> rate;
  String frate = "";
  bool __isLoading = false;
  final formKey = GlobalKey<FormState>();
  SharedPreferences sharedPreferences;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();
  //String name = "";

  @override
  void initState() {
    super.initState();
    formKey.currentState?.reset();
    // WidgetsBinding.instance
    //   .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    checkLoginStatus();
    getName().then((val)=>setState((){
      name.name = val.name;
      name.email = val.email;
      name.id = val.id;
    }));
    rate =  fetchRate();
  }
  Future<UserModel> getName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var data = new UserModel(sharedPreferences.getInt("id"), sharedPreferences.getString("name"), sharedPreferences.getString("email"));
    return data;
  }
  
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }
  }

  Future<int> fetchRate() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String auth = "Bearer"+ sharedPreferences.getString("token");
    final response =
      await http.post(
        'http://ec2-3-15-209-246.us-east-2.compute.amazonaws.com/ssuet-electric/public/api/getRate',
        headers: {"authorization":auth,"Content-Type": "application/json","Accept": "application/json"}
      );
      
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      var data = json.decode(response.body);
      return data['rate'];
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
    rate =  fetchRate();
    formKey.currentState?.reset();
    return null;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text("Trade Settings", style: TextStyle(color: Colors.white)),
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
            padding: EdgeInsets.only(top:20.0),
            children:<Widget>[
              __isLoading? Center(child: CircularProgressIndicator()) : Center(),
              Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(25.0)
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            Icon(Icons.settings, color: Colors.black38,size: 23.0,),
                            Text(" Trade Settings",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 23.0,color: Colors.black38),),
                        ],
                    ),
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: rate,
                builder: (context, snapshot){
                  if (snapshot.hasData) {
                    return Container(child:Column(children:<Widget>[
                      statsList("Current Rate",snapshot.data.toString()),
                    ]));
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Center(child:CircularProgressIndicator(),);
                },
              ),
              Form(
                key: formKey,
                child: Container(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    children: <Widget>[
                      Container(margin: EdgeInsets.only(top: 24.0),),
                      fieldRate("Unit Rate",Icons.attach_money),
                      Container(margin: EdgeInsets.only(top: 15.0),),
                    ],
                  ),
                ),
              ),
              buttonSection(),
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
                title: Text("Stats"),
                onTap: (){
                  Navigator.of(context).pushNamed('/StatsPage');
                },
              ),
              ListTile(
                title: Text("Wallet"),
                onTap: (){
                  Navigator.of(context).pushNamed('/WalletPage');
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
              borderRadius: BorderRadius.circular(25.0)
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                  Text(title+":",style: TextStyle(),),
                  Text(value)
              ],
          ),
        ),
      ),
    );

    TextFormField fieldRate(String title, IconData icon){
      return TextFormField(
        keyboardType: TextInputType.number,
        controller: rateController,
        style: TextStyle(color: Colors.black38),
        validator: validateRate,
        onSaved: (String value){
          frate = value;
        },
        decoration: InputDecoration(
          hintText: title,
          hintStyle: TextStyle(color: Colors.white70),
          icon: Icon(icon)
        ),
      );
    }

    Container buttonSection(){
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 40.0,
        margin: EdgeInsets.only(top: 30.0),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton(
          onPressed: (){
            if(formKey.currentState.validate()){
              formKey.currentState.save();
              setState(() {
                __isLoading = true;
              });
              updateRate(rateController.text);
            }
          },
          backgroundColor: Colors.green[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: Text("Update Rate",style: TextStyle(color: Colors.white70),),
        ),
      );
    }
    TextEditingController rateController = new TextEditingController();

    updateRate(String formrate) async {
      sharedPreferences = await SharedPreferences.getInstance();
      String auth = 'Bearer'+sharedPreferences.getString('token');
      Map data = {
        "rate": int.parse(formrate),
      };
      var jsonResponse = null;
      var response = await http.post("http://ec2-3-15-209-246.us-east-2.compute.amazonaws.com/ssuet-electric/public/api/updateRate", body: json.encode(data),
        headers: {"authorization":auth,"Accept": "application/json","Content-type":"application/json"}
      );

      if(response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        if(jsonResponse != null) {
          setState(() {
            __isLoading = false;
          });
          if(jsonResponse.containsKey('success')){
            if(jsonResponse['success'] == true){
              _refresh();
              print("Hurray!!");
            }
            else{
              print(jsonResponse['message']);
              //dialogBox('Login Failed',jsonResponse['message']);
            }
          }
          else{
            print("Not Found");
          }
          //sharedPreferences.setString("token", jsonResponse['token']);
          //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MainPage()), (Route<dynamic> route) => false);
        }
      }
      else {
        setState(() {
          __isLoading = false;
        });
        print(response.body);
      }
    }
}