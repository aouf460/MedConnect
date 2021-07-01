import 'dart:convert';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/modals/DoctorAppointmentDetailsClass.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class UserAppointmentDetails extends StatefulWidget {

  String id;
  UserAppointmentDetails(this.id);

  @override
  _UserAppointmentDetailsState createState() => _UserAppointmentDetailsState();
}

class _UserAppointmentDetailsState extends State<UserAppointmentDetails> {

  DoctorAppointmentDetailsClass doctorAppointmentDetailsClass;
  Future getAppointmentDetails;
  bool isErrorInLoading = false;

  fetchAppointmentDetails() async{
    final response = await get("$SERVER_ADDRESS/api/appointmentdetail?id=${widget.id}&type=1")
    .catchError((e){
      setState(() {
        isErrorInLoading = true;
      });
    });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse["success"] == "1"){
        setState(() {
          doctorAppointmentDetailsClass = DoctorAppointmentDetailsClass.fromJson(jsonResponse);
        });
      }else{
        setState(() {
          isErrorInLoading = true;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAppointmentDetails = fetchAppointmentDetails();
    print(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColorLight,
          appBar: AppBar(
            flexibleSpace: header(),
            leading: Container(),
          ),
          body: isErrorInLoading ? Container(
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
          ) : FutureBuilder(
            future: getAppointmentDetails,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: CircularProgressIndicator()));
              }
              else if(snapshot.connectionState == ConnectionState.none){
                return Container();
              }
              else{
                return Stack(
                  children: [
                    appointmentListWidget(doctorAppointmentDetailsClass.data),
                  ],
                );
              }
            },
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
                  imageUrl: list.image,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                  ),),
                  errorWidget: (context,url,err) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                  )),
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
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: EdgeInsets.all(8),
            color: WHITE,
          ),
        ),
        SizedBox(height: 50,),
      ],
    );
  }


  // Widget button(){
  //   return Align(
  //     alignment: Alignment.bottomCenter,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         Container(
  //           height: 50,
  //           margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
  //           child: InkWell(
  //             onTap: (){
  //
  //             },
  //             child: Stack(
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(25),
  //                   child: Image.asset("assets/moreScreenImages/header_bg.png",
  //                     height: 50,
  //                     fit: BoxFit.fill,
  //                     width: MediaQuery.of(context).size.width,
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Text(
  //                     ACCEPT,
  //                     style: Theme.of(context).textTheme.bodyText1.apply(
  //                       color: Theme.of(context).backgroundColor,
  //                       fontSizeDelta: 2
  //                     )
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 10,),
  //         Container(
  //           height: 50,
  //           margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
  //           child: InkWell(
  //             onTap: (){
  //
  //             },
  //             child: Stack(
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(25),
  //                   child: Image.asset("assets/moreScreenImages/header_bg.png",
  //                     height: 50,
  //                     fit: BoxFit.fill,
  //                     width: MediaQuery.of(context).size.width,
  //                   ),
  //                 ),
  //                 Center(
  //                   child: Text(
  //                       CANCEL,
  //                       style: Theme.of(context).textTheme.bodyText1.apply(
  //                         color: Theme.of(context).backgroundColor,
  //                         fontSizeDelta: 2
  //                       )
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }



}


