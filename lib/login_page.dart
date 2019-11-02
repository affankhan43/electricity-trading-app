import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mixins/validations.dart';


class LoginPage extends StatefulWidget {
  @override
  __LoginPageState createState() => __LoginPageState();
}

class __LoginPageState extends State<LoginPage> with ValidationMixins{

  bool __isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body : Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Colors.green[600],Colors.white24],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      )
      ),
      child: ListView(
        children: <Widget>[
        headerSection(),
        textSection(),
        buttonSection()
      ],
      ),
      ),
    );
  }

  Container headerSection(){
    return Container(
      alignment: Alignment(0.0,0.0),
      padding: EdgeInsets.only(top: 40.0),
      child: Row(
        children: <Widget>[
          Icon(Icons.battery_charging_full,size: 40.0,color: Colors.black38,),
          Text("Trade Energy",style: TextStyle(color: Colors.black38,fontSize: 30,fontWeight: FontWeight.w900)),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        ),
    );
   }

  Container textSection(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.only(top:30),
      child: Form(
          key: formKey,
          child: Column(
          children: <Widget>[
            txtEmail("Email",Icons.email),
            Container(margin: EdgeInsets.only(top: 15.0),),
            txtPassword("Password",Icons.lock),
            Container(margin: EdgeInsets.only(top: 15.0),),
          ],
        ),
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
            signIn(emailController.text,passwordController.text);
          }
        },
        backgroundColor: Colors.green[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)
        ),
        child: Text("Sign In",style: TextStyle(color: Colors.white70),),
      ),
    );
  }
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  TextFormField txtEmail(String title, IconData icon){
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.black38),
      validator: validateEmail,
      onSaved: (String value){
        email = value;
      },
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icon)
      ),
    );
  }

  TextFormField txtPassword(String title, IconData icon){
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      style: TextStyle(color: Colors.black38),
      validator: validatePassword,
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Colors.white70),
        icon: Icon(icon)
      ),
    );
  }

  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'email': email,
      'password': pass
    };
    var jsonResponse = null;
    var response = await http.post("http://192.168.0.105/ssuet-electric/public/api/login", body: data);
    if(response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        setState(() {
          __isLoading = false;
        });
        if(jsonResponse.containsKey('success')){
          if(jsonResponse['success'] == true){
            print("Hurray!!");
          }
          else{
            print(jsonResponse['message']);
            dialogBox('Login Failed',jsonResponse['message']);
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

  dialogBox(String type, msg){
    return showDialog(
      context: context,
      child: AlertDialog(
        backgroundColor: Colors.green[600],
        title: Row(
          children: <Widget>[
            Icon(Icons.error),
            Text(type, style: TextStyle(color:Colors.black38),)
        ]),
        content: Text(msg, style: TextStyle(color: Colors.black38),),
      )
    );
  }
}