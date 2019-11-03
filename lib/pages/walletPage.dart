import 'package:flutter/services.dart';
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
        title: Text("Wallet", style: TextStyle(color: Colors.white)),
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
        child: ListView(children: <Widget>[
          _buildHeader(context),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
        ],)
        //child: Center(child: Text(name.name)),
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

  Container _buildHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      height: 230.0,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 30.0, left: 25.0, right: 25.0, bottom: 10.0),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
              elevation: 5.0,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 60.0,),
                  Text("Balance", style: TextStyle(fontSize: 27.0,fontWeight: FontWeight.w700,color: Colors.black87),),
                  SizedBox(height: 5.0,),
                  Text("6500 PKR", style: TextStyle(fontSize: 19.0,color: Colors.black38),),
                  SizedBox(height: 14.0,),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Expanded(
                        //   child: ListTile(
                        //     title: Text("302",
                        //       textAlign: TextAlign.center,
                        //       style: TextStyle(fontWeight: FontWeight.bold),),
                        //     subtitle: Text("Posts".toUpperCase(),
                        //       textAlign: TextAlign.center,
                        //       style: TextStyle(fontSize: 12.0) ),
                        //   ),
                        // ),
                        Container(
                          width: 180.0,
                          height: 35.0,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: FloatingActionButton(
                            onPressed: (){
                              print("Deposit");
                            },
                            backgroundColor: Colors.green[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Text("Deposit",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16.0),),
                          ),
                        ),
                        
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Material(
                elevation: 5.0,
                shape: CircleBorder(),
                child: CircleAvatar(
                  radius: 45.0,
                  backgroundColor: Colors.green[700],
                  backgroundImage: AssetImage('images/wallet.png'),),
              ),
            ],
          ),
        ],
      ),
    );
  }

  cryptoPortfolioItem(IconData icon, String name, double amount, double rate,
            String percentage) =>
        Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: InkWell(
            onTap: () => print("tapped"),
            child: Container(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0, right: 15.0),
              decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(25.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 15.0),
                    child: Icon(icon, color: Colors.grey),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              name,
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            Text("\$$amount",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("$rate BTC",
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.normal)),
                            Text("+ \$$percentage",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.red[500],
                                ))
                          ],
                        )
                      ],
                    ),
                    flex: 3,
                  ),
                ],
              ),
            ),
          ),
        );
}