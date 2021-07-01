import 'dart:convert';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/views/Doctor/DoctorTabScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAsDoctor extends StatefulWidget {
  @override
  _RegisterAsDoctorState createState() => _RegisterAsDoctorState();
}

class _RegisterAsDoctorState extends State<RegisterAsDoctor> {

  String name = "";
  String phoneNumber = "";
  String email = "";
  String password = "";
  String confirmPassword = "";
  String phnNumberError = "";
  bool isPhoneNumberError = false;
  bool isNameError = false;
  bool isEmailError = false;
  bool isPassError = false;
  String token = "";
  String error = "";


  storeToken() async{
    dialog();
    await FirebaseMessaging().getToken().then((value) async{
      //Toast.show(value, context, duration: 2);
      print(value);
      setState(() {
        token =value;
      });

      final response = await post(
          "$SERVER_ADDRESS/api/savetoken",
          body: {
            "token":token,
            "type": "1",
          }
      ).catchError((e){
        Navigator.pop(context);
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      });
      if(response.statusCode == 200){
        Navigator.pop(context);
        final jsonResponse = jsonDecode(response.body);
        if(jsonResponse['success'] == "1"){
          SharedPreferences.getInstance().then((pref){
            pref.setBool("isTokenExist", true);
            print("token stored");
          });
          //Navigator.pop(context);
          registerUser();
        }
      }
      else{
        Navigator.pop(context);
        print("token not stored");
        messageDialog(ERROR, response.body.toString());
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (context) => TabsScreen())
        // );
      }

    }).catchError((e){
      Navigator.pop(context);
      print("token not accessed");
      messageDialog(ERROR, UNABLE_TO_SAVE_TOKEN_TO_SERVER);
    });
    setState(() {
      token ="";
    });
  }


  registerUser() async {
    if (name.isEmpty) {
      setState(() {
        isNameError = true;
      });
    }
    else if (phoneNumber.length < PHONE_NUMBER_LENGTH) {
      setState(() {
        isPhoneNumberError = true;
        phnNumberError = ENTER_VALID_MOBILE_NUMBER;
      });
    }
    else if (EmailValidator.validate(email) == false) {
      setState(() {
        isEmailError = true;
      });
    }
    else if (password != confirmPassword || password.length == 0) {
      setState(() {
        isPassError = true;
      });
    }else if(token == null || token.isEmpty){
      storeToken();
    }
    else {
      dialog();
      //Toast.show("Creating account please wait", context);
      String url = "$SERVER_ADDRESS/api/doctorregister?name=$name&email=$email&phone=$phoneNumber&password=$password&token=$token";
      var response = await post(url, body: {
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'password': password,
        'token': token
      }).catchError((e){
        Navigator.pop(context);
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      });
      try {
        print(response.statusCode);
        print(response.body);
        var jsonResponse = await jsonDecode(response.body);
        if (jsonResponse['success'] == "0") {
          setState(() {
            Navigator.pop(context);
            error = jsonResponse['register'];
            messageDialog(ERROR, error);
            //isPhoneNumberError = true;
          });
        }
        else {
          await SharedPreferences.getInstance().then((pref) {
            pref.setBool("isLoggedInAsDoctor", true);
            pref.setString(
                "userId", jsonResponse['register']['doctor_id'].toString());
            pref.setString("name", jsonResponse['register']['name']);
            pref.setString("phone", jsonResponse['register']['phone']);
            pref.setString("email", jsonResponse['register']['email']);
            pref.setString("token", token.toString());
          });
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DoctorTabsScreen())
          );
        }
      }catch(e){
        Navigator.pop(context);
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      }
    }
  }

  getToken() async{
    await SharedPreferences.getInstance().then((pref) async{
      if(pref.getBool("isTokenExist") ?? false) {
        String tokenLocal = await FirebaseMessaging().getToken();
        setState(()  {
          print("1-> token retrieved");
          token = tokenLocal;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            bottom(),
            SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  registerForm(),
                ],
              ),
            ),
            header(),
          ],
        ),
      ),
    );
  }

  Widget header(){
    return Stack(
      children: [
        Image.asset("assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 15,),
              InkWell(
                onTap: (){

                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                REGISTER_AS_DOCTOR,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: WHITE,
                    fontSize: 22
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bottom(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ALREADY_HAVE_AN_ACCOUNT,
              style: GoogleFonts.poppins(
                color: BLACK,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text(" $LOGIN_NOW",
                style: GoogleFonts.poppins(
                  color: AMBER,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget registerForm(){
    return Container(
    height: MediaQuery.of(context).size.height - 150,
    decoration: BoxDecoration(
      color: WHITE,
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
    ),
    child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: ENTER_NAME,
            labelStyle: GoogleFonts.poppins(
                color: LIGHT_GREY_TEXT,
                fontWeight: FontWeight.w400
            ),
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: LIGHT_GREY_TEXT)
            ),
            errorText: isNameError ? ENTER_NAME : null,
          ),
          style: GoogleFonts.poppins(
              color: BLACK,
              fontWeight: FontWeight.w500
          ),
          onChanged: (val){
            setState(() {
              name = val;
              isNameError = false;
            });
          },
        ),
        SizedBox(height: 3,),
        TextField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              labelText: ENTER_MOBILE_NUMBER,
              labelStyle: GoogleFonts.poppins(
                  color: LIGHT_GREY_TEXT,
                  fontWeight: FontWeight.w400
              ),
              errorText: isPhoneNumberError ? phnNumberError : null,
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: LIGHT_GREY_TEXT)
              )
          ),
          style: GoogleFonts.poppins(
              color: BLACK,
              fontWeight: FontWeight.w500
          ),
          onChanged: (val){
            setState(() {
              phoneNumber = val;
              isPhoneNumberError = false;
            });
          },
        ),
        SizedBox(height: 3,),
        TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              labelText: ENTER_YOUR_EMAIL,
              labelStyle: GoogleFonts.poppins(
                  color: LIGHT_GREY_TEXT,
                  fontWeight: FontWeight.w400
              ),
              errorText: isEmailError ? ENTER_VALID_EMAIL_ADDRESS : null,
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: LIGHT_GREY_TEXT)
              )
          ),
          style: GoogleFonts.poppins(
              color: BLACK,
              fontWeight: FontWeight.w500
          ),
          onChanged: (val){
            setState(() {
              email = val;
              isEmailError = false;
            });
          },
        ),
        SizedBox(height: 3,),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
              labelText: PASSWORD,
              labelStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400
              ),
              errorText: isPassError ? PASSWORD_DOES_NOT_MATCH : null,
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)
              )
          ),
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500
          ),
          onChanged: (val){
            setState(() {
              password = val;
              isPassError = false;
            });
          },
        ),
        SizedBox(height: 3,),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
              labelText: CONFIRM_PASSWORD,
              labelStyle: GoogleFonts.poppins(
                  color: LIGHT_GREY_TEXT,
                  fontWeight: FontWeight.w400
              ),
              errorText: isPassError ? PASSWORD_DOES_NOT_MATCH : null,
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: LIGHT_GREY_TEXT)
              )
          ),
          style: GoogleFonts.poppins(
              color: BLACK,
              fontWeight: FontWeight.w500
          ),
          onChanged: (val){
            setState(() {
              confirmPassword = val;
              isPassError = false;
            });
          },
        ),
        SizedBox(height: 3,),
        SizedBox(
          height: 20,
        ),
        Container(
          height: 50,
          //width: MediaQuery.of(context).size.width,
          child: InkWell(
            onTap: (){
              registerUser();
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset("assets/moreScreenImages/header_bg.png",
                    height: 50,
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Center(
                  child: Text(
                    REGISTER,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: WHITE,
                        fontSize: 18
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 10,),
      ],
    ),
    ),
    );
  }

  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(CREATING_ACCOUNT,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(PLEASE_WAIT_WHILE_CREATING_ACCOUNT,
                      style: GoogleFonts.poppins(
                          fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: GoogleFonts.poppins(
                  fontSize: 14,
                ),)
              ],
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                color: Theme.of(context).accentColor,
                child: Text(OK,style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: BLACK,
                ),),
              ),
            ],
          );
        }
    );
  }

}
