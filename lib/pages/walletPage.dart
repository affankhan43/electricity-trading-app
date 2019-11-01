import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../models/userModel.dart';
import 'package:http/http.dart' as http;
import '../models/walletModel.dart';
import '../models/TxModel.dart';
import 'txList.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}
 
class _WalletPageState extends State<WalletPage> {
  UserModel name = new UserModel(0,"","");
  WalletModel wallet = new WalletModel("",0,[]);
  SharedPreferences sharedPreferences;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();
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
    fetchWallet();
  }
  Future<UserModel> getName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var data = new UserModel(sharedPreferences.getInt("id"), sharedPreferences.getString("name"), sharedPreferences.getString("email"));
    // Map array;
    // array['name'] = sharedPreferences.getString("name");
    // array['email'] = sharedPreferences.getString("email");
    return data;
  }

  void fetchWallet() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String auth = "Bearer"+ sharedPreferences.getString("token");
    final response =
      await http.post(
        'http://ec2-3-15-209-246.us-east-2.compute.amazonaws.com/ssuet-electric/public/api/getWallet',
        headers: {"authorization":auth,"Content-Type": "application/json","Accept": "application/json"}
      );
      
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      setState((){
        wallet = WalletModel.fromJson(json.decode(response.body));
      });  
    } else if(response.statusCode == 401){
      sharedPreferences.clear();
      sharedPreferences.commit();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushReplacementNamed('/LoginScreen');
    }
  }

  Future<void> _refresh() async{
    getName().then((val)=>setState((){
      name.name = val.name;
      name.email = val.email;
      name.id = val.id;
    }));
    print('refreshing ...');
    fetchWallet();
    return null;
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
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child:ListView(
            children: <Widget>[
              _buildHeader(context),
              TxList(wallet.txs),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
          // cryptoPortfolioItem((Icons.attach_money), "Buy", 20.0, 20.0,"50%"),
        ],),
        )
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
                title: Text("Trade Settings"),
                onTap: (){
                  Navigator.of(context).pushNamed('/TradePage');
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
                  Text( wallet.balance.toString()+" PKR", style: TextStyle(fontSize: 19.0,color: Colors.black38),),
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
                              dialogBox("Deposit Address",wallet.address);
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

    dialogBox(String type, address){
      return showDialog(
        context: context,
        child: AlertDialog(
          backgroundColor: Colors.green[600],
          title: Row(
            children: <Widget>[
              Icon(Icons.beenhere),
              Text(type, style: TextStyle(color:Colors.black38),)
          ]),
          content: Text(address, style: TextStyle(color: Colors.black38),),
        )
      );
    }

    Container lister(WalletModel wlt){
      return Container(
        child:ListView.builder(
        itemCount: wlt.txs.length,
        itemBuilder: (context, int index){
          return cryptoPortfolioItem((Icons.compare_arrows), wlt.txs[index].tx_type,wlt.txs[index].amount.toDouble() , 0.0,
            "as");
        },
      ));
    }
}