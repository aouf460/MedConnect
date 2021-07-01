import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/notificationHelper.dart';
import 'package:book_appointment/views/Doctor/DoctorDashboard.dart';
import 'package:book_appointment/views/Doctor/DoctorPastAppointments.dart';
import 'package:book_appointment/views/Doctor/DoctorProfile.dart';
import 'package:book_appointment/views/Doctor/LogoutScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppointmentScreen.dart';
import '../HomeScreen.dart';
import '../UserAppointmentDetails.dart';
import 'DoctorAppointmentDetails.dart';


class DoctorTabsScreen extends StatefulWidget {
  @override
  _DoctorTabsScreenState createState() => _DoctorTabsScreenState();
}

class _DoctorTabsScreenState extends State<DoctorTabsScreen> {

  List<Widget> screens = [
    DoctorDashboard(),
    DoctorPastAppointments(),
    DoctorProfile(),
    LogOutScreen(),
  ];

  int index = 0;
  NotificationHelper notificationHelper = NotificationHelper();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationHelper.initialize();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        print("\n\n"+message.toString());
        notificationHelper.showNotification(title: message['notification']['title'],body: message['notification']['body'] ,payload: "${message['data']['type']}:${message['data']['order_id']}", id: "124", context2: context);
      },
      //onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        print("\n\n"+message.toString());
        if(message['data']['type'] == "user_id"){
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserAppointmentDetails(message['data']['order_id'].toString())),
          );
        }
        else if(message['data']['type'] == "doctor_id"){
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => DoctorAppointmentDetails(message['data']['order_id'].toString())),
          );
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        print("\n\n"+message['data'].toString());
        if(message['data']['type'] == "user_id"){
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => UserAppointmentDetails(message['data']['order_id'].toString())),
          );
        }
        else if(message['data']['type'] == "doctor_id"){
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => DoctorAppointmentDetails(message['data']['order_id'].toString())),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: LIGHT_GREY_SCREEN_BACKGROUND,
          //borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==0
                      ? "assets/homeScreenImages/home_active.png"
                      : "assets/homeScreenImages/home_unactive.png",
                  height: 25,
                  width: 25,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==1
                      ? "assets/homeScreenImages/appointment_active.png"
                      : "assets/homeScreenImages/appointment_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Appointment",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==2
                      ? "assets/homeScreenImages/user_active.png"
                      : "assets/homeScreenImages/user_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Edit profile",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==3
                      ? "assets/loginScreenImages/logout-(1).png"
                      : "assets/loginScreenImages/logout.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Logout",
              ),
            ],
            selectedLabelStyle: GoogleFonts.poppins(
              color: BLACK,
              fontSize: 8,
            ),
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.poppins(
              color: BLACK,
              fontSize: 7,
            ),
            unselectedItemColor: LIGHT_GREY_TEXT,
            selectedItemColor: BLACK,
            onTap: (i){
              setState(() {
                index = i;
              });
            },
            currentIndex: index,
          ),
        ),
      ),
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        barrierDismissible: false,
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
                onPressed: () async{
                  await SharedPreferences.getInstance().then((pref){
                    pref.setBool("isLoggedInAsDoctor", false);
                  });
                },
                color: Theme.of(context).primaryColor,
                child: Text(YES,style: GoogleFonts.poppins(
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

