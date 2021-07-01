import 'dart:async';
import 'dart:convert';

import 'package:book_appointment/main.dart';
import 'package:book_appointment/views/Doctor/DoctorTabScreen.dart';
import 'package:book_appointment/views/HomeScreen.dart';
import 'package:book_appointment/views/loginAsUser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Doctor/DoctorAppointmentDetails.dart';
import 'UserAppointmentDetails.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isTokenAvailable = false;
  String token;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  getToken() async{
    SharedPreferences.getInstance().then((pref){
      if(pref.getBool("isTokenExist") ?? false){
        Timer(Duration(seconds: 2), (){

          if(pref.getBool("isLoggedInAsDoctor") ?? false) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DoctorTabsScreen())
            );
          }
          else if(pref.getBool("isLoggedIn") ?? false) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          }
          else{
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          }

        });
      }else{
        print("value is null");
        Timer(Duration(seconds: 2),(){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TabsScreen())
          );
        });
      }
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
  }

  storeToken() async{
    final response = await post(
        "$SERVER_ADDRESS/api/savetoken",
      body: {
          "token":token,
         "type": "1",
      }
    ).catchError((e){
      Timer(Duration(seconds: 2),(){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TabsScreen())
        );
      });
    });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'] == "1"){
        Timer(Duration(seconds: 2), (){
          SharedPreferences.getInstance().then((pref){
            pref.setBool("isTokenExist", true);
            print("token stored");
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          });
        });
      }
    }
    else{
      print("token not stored");
      Timer(Duration(seconds: 2),(){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TabsScreen())
        );
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
              "assets/splash_bg.png",
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Padding(
            padding: const EdgeInsets.all(85),
            child: Center(
              child: Image.asset(
                  "assets/splash_icon.png",
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

}


// FirebaseMessaging().getToken().then((value){
//   //Toast.show(value, context, duration: 2);
//   print(value);
//   setState(() {
//     token = value;
//   });
//
// }).catchError((e){
//   print("token not generated "+ e.toString());
//   Timer(Duration(seconds: 2),(){
//     Navigator.pushReplacement(context,
//         MaterialPageRoute(builder: (context) => TabsScreen())
//     );
//   });
// });
