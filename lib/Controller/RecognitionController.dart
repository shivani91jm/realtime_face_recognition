import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/ML/UserData.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:http/http.dart' as http;
class RecognitionController extends GetxController{
  RxBool loading=false.obs;
BuildContext? context=Get.context;
  final AudioPlayer _audioPlayer = AudioPlayer();
  void fetchImageAndConvertToBase64(String imageUrl, String image2, String name, String id) async {
    loading.value=true;
    var  body=jsonEncode(<String, String>{
      'image1': imageUrl,
      'image2': image2,
    });
    var url = Urls.faceurl;
    print("res body" + url.toString());
    final responsess = await http.post(
        Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'X-RapidAPI-Key':Urls.rapid_key,
      'X-RapidAPI-Host': Urls.rapid_host
    },body: body);
    print("response" + responsess.body.toString());
    if (responsess.statusCode == 200) {
      print("vdbvsbd" );
      // var res = jsonDecode(response.body);
      var res = json.decode(responsess.body);
      print("vdbvsbd" + res.toString());
      if (res != null) {
        var info = res['data']['result'];
        loading.value=false;
        print("ghfdhfd"+info.toString());
        if(info!="image2: is null!" || info!="image2: no face detected!") {
          if (info == "same") {
         //   UserData user = UserData(name, "", id);
            _audioPlayer
              ..stop()
              ..setReleaseMode(ReleaseMode.release)
              ..play(AssetSource("sucessAttendance.m4r"));
            // Navigator.pushReplacement(context!, MaterialPageRoute(
            //     builder: (context) =>
            //         UserDetailsView(user: user,)),
            //);
          }
          else {
            loading.value = false;
            CustomSnackBar.successSnackBar("No User Found", context!);
          }
        }else
          {
            CustomSnackBar.errorSnackBar("Face not found..", context!);
          }


      }
    }
    else if (responsess.statusCode == 401) {
      loading.value=false;
      print("data" + responsess.body.toString());

      // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
    }
    else if (responsess.statusCode == 500) {
      loading.value=false;
      print("data" + responsess.body.toString());
    }
    else {
      loading.value=false;
      print("data" + responsess.body.toString());
    }

  }
}