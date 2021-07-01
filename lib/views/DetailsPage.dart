
import 'dart:convert';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/modals/DoctorDetailsClass.dart';
import 'package:book_appointment/views/MakeAppointment.dart';
import 'package:book_appointment/views/MapWidget.dart';
import 'package:book_appointment/views/ReviewsScreen.dart';
import 'package:book_appointment/views/loginAsUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {

  String id;

  DetailsPage(this.id);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
 
  DoctorDetailsClass doctorDetailsClass;
  bool isLoading = true;
  bool isLoggedIn;
  bool isErrorInLoading = false;
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDoctorDetails();
    print(widget.id);
    SharedPreferences.getInstance().then((pref){
      setState(() {
        isLoggedIn = pref.getBool("isLoggedIn") ?? false;
      });
    });
  }
  
  fetchDoctorDetails() async{
    setState(() {
      isLoading = true;
    });
    final response = await get("$SERVER_ADDRESS/api/viewdoctor?doctor_id=${widget.id}")
    .catchError((e){
      print("ERROR ${e.toString()}");
      setState(() {
        isErrorInLoading = true;
      });
    });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        doctorDetailsClass = DoctorDetailsClass.fromJson(jsonResponse);
        print(doctorDetailsClass.data.avgratting);
        print(widget.id);
        setState(() {
          isLoading = false;
          //doctorDetailsClass.data.avgratting = '3';
        });
      }

  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        body: Stack(
          children: [
            isErrorInLoading ? Container(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 100,
                      color: LIGHT_GREY_TEXT,
                    ),
                    SizedBox(height: 20,),
                    Text(
                      UNABLE_TO_LOAD_DATA_FORM_SERVER,
                    )
                  ],
                ),
              ),
            ) : !isLoading
                ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
              child: Column(
                      children: [
                        header(),
                        appointmentListWidget(),
                        doctorDetails(),
                        SizedBox(height: 80,),
                      ],
              ),
            ),
                    ),
                    button(),
                  ],
                )
                : Center(
              child: CircularProgressIndicator(),
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
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                DOCTOR_DETAILS,
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

  Widget appointmentListWidget() {
    return Container(
      //height: 110,
      margin: EdgeInsets.fromLTRB(10,10,10,10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: WHITE,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: doctorDetailsClass.data.image,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).primaryColorLight,
                child: Center(
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                ),

              ),
              errorWidget: (context,url,err) => Container(
                color: Theme.of(context).primaryColorLight,
                child: Center(
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                ),
              ),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctorDetailsClass.data.name,
                  style: GoogleFonts.poppins(
                      color: BLACK,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(height: 2,),
                Text(doctorDetailsClass.data.departmentName,
                  style: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  ),
                ),
                SizedBox(height: 4,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass.data.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass.data.avgratting >= 1
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass.data.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass.data.avgratting >= 2
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass.data.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass.data.avgratting >= 3
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass.data.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass.data.avgratting >= 4
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass.data.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass.data.avgratting >= 5
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5,)
                              ],
                            ),
                          ),
                          Text(" (${doctorDetailsClass.data.totalReview} $REVIEWS)",
                            style: GoogleFonts.poppins(
                                color: LIGHT_GREY_TEXT,
                                fontSize: 8,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          SizedBox(
                            width: 10,),
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(doctorDetailsClass.data.id.toString())));
                            },
                            child: Text("$SEE_ALL_REVIEW",
                              style: GoogleFonts.poppins(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,)
                        ],
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 5,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget doctorDetails(){
    return Container(
      //height: MediaQuery.of(context).size.height - 300,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WHITE,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PHONE_NUMBER,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: BLACK,
                        fontSize: 14
                    ),
                  ),
                  //SizedBox(height: 8,),
                  Text(
                    doctorDetailsClass.data.phoneno,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: LIGHT_GREY_TEXT,
                        fontSize: 10
                    ),
                  ),
                ],
              ),

             /*
              InkWell(
                onTap: (){
                  launch("tel://${doctorDetailsClass.data.phoneno}");
                },
                child: Image.asset(
                 "assets/detailScreenImages/phone_button.png",
                height: 50,
                  width: 50,
                ),
              ),

              */
            ],
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorDetailsClass.data.aboutus==null?" ":ABOUT_US,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              //SizedBox(height: 8,),
              Text(
                doctorDetailsClass.data.aboutus??" ",
                 style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: LIGHT_GREY_TEXT,
                    fontSize: 10
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          doctorDetailsClass.data.address==null?
                          Container():
                          Image.asset(
                            "assets/detailScreenImages/location_pin.png",
                            height: 15,
                            width: 15,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            doctorDetailsClass.data.address==null? " " :ADDRESS,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: BLACK,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          doctorDetailsClass.data.address??" ",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: LIGHT_GREY_TEXT,
                              fontSize: 10
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          doctorDetailsClass.data.workingTime==null?
                          Container():Image.asset(
                            "assets/detailScreenImages/time.png",
                            height: 15,
                            width: 15,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            doctorDetailsClass.data.workingTime==null?" " :WORKING_TIME,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: BLACK,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          doctorDetailsClass.data.workingTime?? " ",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: LIGHT_GREY_TEXT,
                              fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 50,),
                Expanded(
                  flex: 2,

                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          //width: 100,
                          /*
                          child: InkWell(
                            onTap: (){
                              openMap(double.parse(doctorDetailsClass.data.lat), double.parse(doctorDetailsClass.data.lon));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  doctorDetailsClass.data.address==null?
                                      Container()
                                      :Image.asset(
                                    "assets/detailScreenImages/map_icon.png",
                                    height: 110,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          */
                        ),
                      ],
                    ),
                  )


                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorDetailsClass.data.services==null?" ":SERVICES,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                    fontSize: 15
                ),
              ),
              //SizedBox(height: 8,),
              Text(
                doctorDetailsClass.data.services ?? " ",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: LIGHT_GREY_TEXT,
                    fontSize: 10
                ),
              ),
              SizedBox(height: 8,),
              Text(
                doctorDetailsClass.data.healthcare==null?" ":HEALTH_CARE,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                    fontSize: 15
                ),
              ),
              //SizedBox(height: 8,),
              Text(
                doctorDetailsClass.data.healthcare??" ",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: LIGHT_GREY_TEXT,
                    fontSize: 10
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 50,
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                isLoggedIn
                    ? MakeAppointment(widget.id, doctorDetailsClass.data.name)
                    : LoginAsUser())
            );
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
                  isLoggedIn ? MAKE_AN_APPOINTMENT : LOGIN_TO_BOOK_APPOINTMENT,
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
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    print("opening map");
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      print("Could not open the map");
      throw 'Could not open the map.';
    }
  }

  _launchMaps() async {
    print('launching maps');
    String googleUrl =
        'comgooglemaps://?center=${doctorDetailsClass.data.lat},${doctorDetailsClass.data.lon}';
    String appleUrl =
        'https://maps.apple.com/?sll=${doctorDetailsClass.data.lat},${doctorDetailsClass.data.lon}';
    if (await canLaunch("comgooglemaps://")) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      print('launching apple url');
      await launch(appleUrl);
    } else {
      print('launching apple url');
      throw 'Could not launch url';
    }
  }

}
