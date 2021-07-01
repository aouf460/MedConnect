import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/modals/NearbyDoctorClass.dart';
import 'package:book_appointment/views/AllAppointments.dart';
import 'package:book_appointment/views/AllNearby.dart';
import 'package:book_appointment/views/DetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_admob/flutter_native_admob.dart';
// import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart';
import 'package:loadmore/loadmore.dart';
import 'package:paging/paging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../main.dart';


class HomeScreenNearby extends StatefulWidget {

  ScrollController scrollController;


  HomeScreenNearby(this.scrollController);

  @override
  _HomeScreenNearbyState createState() => _HomeScreenNearbyState();
}

class _HomeScreenNearbyState extends State<HomeScreenNearby> {

  bool isErrorInNearby = false;
  bool isNearbyLoading = true;
  List<NearbyData> list = List();
  bool isLoadingMore = false;
  String nextUrl = "";
  String lat = "";
  String lon = "";
  NearbyDoctorsClass nearbyDoctorsClass;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocationStart();
    widget.scrollController.addListener(() {
      //print(_scrollController.position.pixels);
      if(widget.scrollController.position.pixels == widget.scrollController.position.maxScrollExtent) {
        print("Loadmore");
        _loadMoreFunc();
      }
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _getAdContainer() {
    return Container(
      // height: 60,
      // margin: EdgeInsets.all(10),
      // child: NativeAdmob(
      //   // Your ad unit id
      //   adUnitID: ADMOB_ID,
      //   controller: nativeAdController,
      //   type: NativeAdmobType.banner,
      // ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return isErrorInNearby ? Container() : Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 10,),
            nearByDoctors(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(NEARBY_DOCTORS,
                  style: Theme.of(context).textTheme.bodyText2.apply(
                      fontWeightDelta: 3
                  )
              ),
              TextButton(onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AllNearby()),
                );
              }, child: Text(SEE_ALL,
                  style: Theme.of(context).textTheme.bodyText1.apply(
                    color: Theme.of(context).accentColor,
                  )
              ),)
            ],
          ),
        ),
      ],
    );
  }

  Widget nearByDoctors(){
    return Container(
      margin: EdgeInsets.fromLTRB(12, 10, 100, 5),
      child: Column(
        children: [
          isNearbyLoading ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(height: 150,),
                CircularProgressIndicator(),
              ],
            ),
          ) :
          list == null
              ? isErrorInNearby ? Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(TURN_ON_LOCATION_AND_RETRY,
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ) : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
              strokeWidth: 2,
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: list.length > 4 ? (list.length/4).ceil() : 1,
            itemBuilder: (context, i){
              print((list.length/4).floor());
              print((list.length/4).ceil());
              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemCount: 4,
                    itemBuilder: (BuildContext ctx, index) {
                        return index + (i*4) > list.length - 1 ? Container() : nearByGridWidget(
                          list[index + (i*4)].image,
                          list[index + (i*4)].name,
                          list[index + (i*4)].departmentName,
                          list[index + (i*4)].id,
                        );
                    },
                  ),
                  ENABLE_ADS ? customAds.nativeAds(id: AD_TYPE) : Container(height: 10,),
                ],
              );
            },
          ),
          nextUrl== "null" ? Container() : Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
          isLoadingMore ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: LinearProgressIndicator(),
          ) : Container(
            height: 50,
          )
        ],
      ),
    );
  }



  Widget nearByGridWidget(img, name, dept, id) {
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(id.toString())),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: img,
                  fit: BoxFit.cover,
                  width: 250,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 50, width: 50,),
                    ),
                  ),
                  errorWidget: (context,url,err) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 50, width: 50,),
                    ),
                    //child: Padding(
                    //   padding: const EdgeInsets.all(20.0),
                    // )
                    //
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              ),
            ),
            Text(dept,
              style: GoogleFonts.poppins(
                  color: LIGHT_GREY_TEXT,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500
              ),
            ),



          ],
        ),
      ),


    );
  }

  void _getLocationStart() async {

    setState(() {
      isErrorInNearby = false;
      isNearbyLoading = true;
    });
    print('Started');
    //Toast.show("loading", context);
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .catchError((e){
      //Toast.show(e.toString(), context,duration: 3);
      print(e);
      messageDialog(PERMISSION_NOT_GRANTED, e.toString());
      if(mounted){
        setState(() {
          isErrorInNearby = true;
        });
      }
    });

    if(position.latitude != null) {
      final response = await get(
          "$SERVER_ADDRESS/api/nearbydoctor?lat=${position
              .latitude}&lon=${position.longitude}")
          .catchError((e) {
        setState(() {
          isErrorInNearby = true;
        });
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      });
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse.toString());
      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        //print([0].name);
        setState(() {
          lat = position.latitude.toString();
          lon = position.longitude.toString();
          nearbyDoctorsClass = NearbyDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          list.addAll(nearbyDoctorsClass.data.nearbyData);
          nextUrl = nearbyDoctorsClass.data.nextPageUrl;
          print(nextUrl);
          isNearbyLoading = false;
        });
      } else {
        setState(() {
          isErrorInNearby = true;
        });
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      }
    }
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: Theme.of(context).textTheme.bodyText1),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: Theme.of(context).textTheme.bodyText1,)
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () async{
                    var status = await Permission.location.status;
                    if (!status.isGranted && s1 == PERMISSION_NOT_GRANTED) {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.location,
                        Permission.storage,
                      ].request();
                      _getLocationStart();
                      // We didn't ask for permission yet or the permission has been denied before but not permanently.
                    }

//
                    Navigator.pop(context);
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text(OK,style: Theme.of(context).textTheme.bodyText1)
              ),
            ],
          );
        }
    );
  }


  Future<bool> _loadMoreFunc() async {
    if (nextUrl != "null") {
      print('loading');
      final response = await get(
          "$nextUrl&lat=${lat}&lon=${lon}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        //print([0].name);
        setState(() {
          nearbyDoctorsClass = NearbyDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          nextUrl = nearbyDoctorsClass.data.nextPageUrl;
          print(nextUrl);
          list.addAll(nearbyDoctorsClass.data.nearbyData);
        });
      }
    }
  }



}
