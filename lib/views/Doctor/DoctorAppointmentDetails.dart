import 'dart:convert';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/modals/DoctorAppointmentDetailsClass.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorAppointmentDetails extends StatefulWidget {

  String id;
  DoctorAppointmentDetails(this.id);

  @override
  _DoctorAppointmentDetailsState createState() => _DoctorAppointmentDetailsState();
}

class _DoctorAppointmentDetailsState extends State<DoctorAppointmentDetails> {

  DoctorAppointmentDetailsClass doctorAppointmentDetailsClass;
  Future getAppointmentDetails;
  bool areChangesMade = false;
  bool isCompleteError = false;


  fetchAppointmentDetails() async{
    print(widget.id);
    final response = await get("$SERVER_ADDRESS/api/appointmentdetail?id=${widget.id}&type=2");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse["success"] == "1"){
        setState(() {
          doctorAppointmentDetailsClass = DoctorAppointmentDetailsClass.fromJson(jsonResponse);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.id);
    getAppointmentDetails = fetchAppointmentDetails();
  }

  Future<bool> _willPopScope() async {
    Navigator.pop(context, areChangesMade);
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
          onWillPop: _willPopScope,
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColorLight,
            appBar: AppBar(
              flexibleSpace: header(),
              leading: Container(),
            ),
            body: FutureBuilder(
              future: getAppointmentDetails,
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: CircularProgressIndicator()));
                }else{
                  return Stack(
                    children: [
                      appointmentListWidget(doctorAppointmentDetailsClass.data),
                      button(),
                    ],
                  );
                }
              },
            ),
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
                  APPOINTMENT,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                  //style: Theme.of(context).textTheme.headline5.apply(color: Theme.of(context).backgroundColor)
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget appointmentListWidget(var list) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(15)
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: Uri.encodeFull(list.image) ?? " ",
                  height: 75,
                  width: 75,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(list.name,
                            style: Theme.of(context).textTheme.bodyText2.apply(
                                fontWeightDelta: 5,
                              fontSizeDelta: 2
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).primaryColorLight
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/detailScreenImages/time.png",
                            height: 13,
                            width: 13,
                          ),
                          SizedBox(width: 5,),
                          Text(list.status, style: Theme.of(context).textTheme.caption.apply(
                            fontSizeDelta: 0.5,
                            fontWeightDelta: 2,
                          ),),
                          SizedBox(width: 5,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/homeScreenImages/calender.png",
                    height: 17,
                    width: 17,
                  ),
                  SizedBox(height: 5,),
                  Text(
                      list.date.toString().substring(8)+"-"+list.date.toString().substring(5,7)+"-"+list.date.toString().substring(0,4),
                      style: Theme.of(context).textTheme.caption
                  ),
                  Text(list.slot,
                      style: Theme.of(context).textTheme.bodyText1.apply(
                          fontWeightDelta: 2
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: EdgeInsets.all(8),
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(PHONE_NUMBER,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          fontWeightDelta: 1,
                          fontSizeDelta: 1.5
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(list.phone,
                        style: Theme.of(context).textTheme.caption.apply(
                          fontWeightDelta: 2,
                          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                /*
                  InkWell(
                    onTap: (){
                      launch("tel:"+list.phone);
                    },
                    child: Image.asset(
                        "assets/detailScreenImages/phone_button.png",
                      height: 45,
                      width: 45,
                   ),
                  ),
                  */
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(EMAIL_ADDRESS,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          fontWeightDelta: 1,
                          fontSizeDelta: 1.5
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(list.email,
                        style: Theme.of(context).textTheme.caption.apply(
                          fontWeightDelta: 2,
                          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                /*
                  InkWell(
                    onTap: (){
                      print("pressed");
                      launch(Uri(
                        scheme: 'mailto',
                        path: list.email,
                        // queryParameters: {
                        //   'subject': 'Example Subject & Symbols are allowed!'
                        // }
                      ).toString());
                    },
                    child: Image.asset(
                        "assets/detailScreenImages/email_btn.png",
                      height: 45,
                     width: 45,
                    ),
                  ),

                  */
                ],
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DESCRIPTION,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          fontWeightDelta: 1,
                          fontSizeDelta: 1.5
                        ),
                      ),
                      SizedBox(height: 5,),
                      Container(
                        width: 300,
                        child: Text(list.description,
                          style: Theme.of(context).textTheme.caption.apply(
                            fontWeightDelta: 2,
                            color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child:
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: WHITE,)),
        SizedBox(height: 150,),
      ],
    );
  }


  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: doctorAppointmentDetailsClass.data.status == "Received"
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: InkWell(
              onTap: (){
                changeStatus("3");
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
                      ACCEPT,
                      style: Theme.of(context).textTheme.bodyText1.apply(
                        color: Theme.of(context).backgroundColor,
                        fontSizeDelta: 2
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: (){
                changeStatus("5");
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
                        CANCEL,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          color: Theme.of(context).backgroundColor,
                          fontSizeDelta: 2
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      )
          : doctorAppointmentDetailsClass.data.status == "In Process"
              ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: InkWell(
              onTap: (){
                if(doctorAppointmentDetailsClass.data.date == DateTime.now().toString().substring(0,10)){
                  print("yes");
                  changeStatus("4");
                }else{
                  print("no");
                  setState(() {
                    isCompleteError = true;
                  });
                  messageDialog(ERROR, "Appointment is on ${doctorAppointmentDetailsClass.data.date}. You can't mark it as Completed today");
                }
                // print(doctorAppointmentDetailsClass.data.date);
                // print(DateTime.now().toString().substring(0,10));
                //changeStatus("4");
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
                        COMPLETE,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                            color: Theme.of(context).backgroundColor,
                            fontSizeDelta: 2
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: (){
                changeStatus("0");
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
                        ABSENT,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                            color: Theme.of(context).backgroundColor,
                            fontSizeDelta: 2
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ) : Container(),
    );
  }

  changeStatus(status) async{
    dialog();
    final response = await post("$SERVER_ADDRESS/api/appointmentstatuschange?app_id=${widget.id}&status=$status");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'] == "1"){
        Navigator.pop(context);
        //messageDialog(SUCCESSFUL, jsonResponse['msg']);
        setState(() {
          getAppointmentDetails = fetchAppointmentDetails();
          areChangesMade = true;
        });
      }
    }
  }


  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(PROCESSING,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(PLEASE_WAIT_WHILE_PROCESSING,
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
                onPressed: (){
                  if(isCompleteError){
                    Navigator.pop(context);
                  }else {
                    setState(() {
                      getAppointmentDetails = fetchAppointmentDetails();
                    });
                  }
                },
                color: Theme.of(context).primaryColor,
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


