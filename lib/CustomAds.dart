//import 'package:facebook_audience_network/ad/ad_native.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
class CustomAds{

  final String ADMOB_ID = "ca-app-pub-7803172892594923/5172476997";
  final String FACEBOOK_AD_ID = "727786934549239_727793487881917";

  final nativeAdController = NativeAdmobController();

  Widget nativeAds({@required int id}){

    return
      //id==0
      //    ?
      Container(
      height: 60,
      margin: EdgeInsets.all(10),
      child: NativeAdmob(
        // Your ad unit id
        adUnitID: ADMOB_ID,
        controller: nativeAdController,
        type: NativeAdmobType.banner,
      ),
    );
    //   FacebookNativeAd(
    //     placementId: FACEBOOK_AD_ID,
    //     adType: NativeAdType.NATIVE_BANNER_AD,
    //     bannerAdSize: NativeBannerAdSize.HEIGHT_50,
    //     width: double.infinity,
    //     backgroundColor: Colors.blue,
    //     titleColor: Colors.white,
    //     descriptionColor: Colors.white,
    //     buttonColor: Colors.deepPurple,
    //     buttonTitleColor: Colors.white,
    //     buttonBorderColor: Colors.white,
    //     listener: (result, value) {
    //       print("Native Ad: $result --> $value");
    //     },
    //   );
  }
}