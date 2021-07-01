
import 'package:book_appointment/views/Doctor/loginAsDoctor.dart';
import 'package:book_appointment/views/HomeScreen.dart';
import 'package:book_appointment/views/MoreScreen.dart';
import 'package:book_appointment/views/SplashScreen.dart';
import 'package:book_appointment/views/UserPastAppointments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:book_appointment/CustomAds.dart';

import 'en.dart';

const String SERVER_ADDRESS = "https://medicalguidedb.com";
//const String SERVER_ADDRESS = "https://priorit.co.in";
//const String SERVER_ADDRESS = "https://drliveplus.co.in";
//const String SERVER_ADDRESS = "https://admin.mojezdravlje.me";

const LANGUAGE = "en";
int PHONE_NUMBER_LENGTH = 10;
const String ADMOB_ID = "ca-app-pub-7803172892594923/5172476997";
const String FACEBOOK_AD_ID = "727786934549239_727793487881917";

const bool ENABLE_ADS = false;
//true -> enable
//false -> disable

const int AD_TYPE = 1;
//0 -> facebook // not working in ios that's why we removed it
//1 -> admob

int LANGUAGE_TYPE = 0;
//0 ---> English
//1 ---> Arabic

Color WHITE = Colors.white;
Color BLACK = Colors.black;
Color LIGHT_GREY_SCREEN_BACKGROUND = Colors.grey.shade200;
Color LIGHT_GREY_TEXT = Colors.grey.shade500;
Color AMBER = Colors.amber.shade700;

//final nativeAdController = NativeAdmobController();
String LANGUAGE_FILE = "en";
CustomAds customAds = CustomAds();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // nativeAdController.setNonPersonalizedAds(true);
  // nativeAdController.setTestDeviceIds(["0B43A6DF92B4C06E3D9DBF00BA6DA410"]);
  // nativeAdController.stateChanged.listen((event) {
  //   print(event);
  // });

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
      MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          timePickerTheme: TimePickerThemeData(
            dayPeriodTextColor: Colors.cyanAccent.shade700,
            //hourMinuteColor: Colors.cyanAccent.shade700,
            helpTextStyle: GoogleFonts.poppins(),
          ),
          accentColor: Colors.cyanAccent.shade700,
          primaryColor: Colors.cyanAccent,
          backgroundColor: Colors.white,
          primaryColorDark: Colors.grey.shade700,
          primaryColorLight: Colors.grey.shade200,
          //highlightColor: Colors.amber.shade700,
          textTheme: TextTheme(
            headline1: GoogleFonts.poppins(),
            headline2: GoogleFonts.poppins(),
            headline3: GoogleFonts.poppins(),
            headline4: GoogleFonts.poppins(),
            headline5: GoogleFonts.poppins(),
            headline6: GoogleFonts.poppins(),
            subtitle1: GoogleFonts.poppins(),
            subtitle2: GoogleFonts.poppins(),
            caption: GoogleFonts.poppins(
              fontSize: 10,
            ),
            bodyText1: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500
            ),
            bodyText2: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w300
            ),
            button: GoogleFonts.poppins(),
          ),
        ),
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English, no country code
          const Locale('he', ''), // Hebrew, no country code
          const Locale('ar', ''), // Hebrew, no country code
          const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
          // ... other locales the app supports
        ],
      )
  );
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {

  List<Widget> screens = [
    HomeScreen(),
    UserPastAppointments(),
    LoginAsDoctor(),
    MoreScreen()
  ];

  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // nativeAdController.setNonPersonalizedAds(true);
    // nativeAdController.setTestDeviceIds(["0B43A6DF92B4C06E3D9DBF00BA6DA410"]);
    // nativeAdController.stateChanged.listen((event) {
    //   print(event);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
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
                label: HOME,
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
                label: APPOINTMENT,
              ),

              BottomNavigationBarItem(
                icon: Image.asset(
                  index==2
                      ? "assets/homeScreenImages/d_l_active.png"
                      : "assets/homeScreenImages/d_l_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: DOCTOR_LOGIN,
              ),

              BottomNavigationBarItem(
                icon: Image.asset(
                  index==3
                      ? "assets/homeScreenImages/more_active.png"
                      : "assets/homeScreenImages/more_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: MORE,
              ),
            ],
            selectedLabelStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 8,
            ),
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 7,
            ),
            unselectedItemColor: Colors.grey.shade500,
            selectedItemColor: Colors.black,
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

}

