import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:realtime_face_recognition/Activity/DashboardPage.dart';

import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';



class RegistrationController extends GetxController{
  RxBool isLoading=false.obs;
  RxBool isLoading2=false.obs;
  BuildContext? context=Get.context;
  void addStaff(String name,List<dynamic> facemodel, BuildContext context) async
  {
    isLoading2.value=true;
    print("name"+name.toString());
    print("arra"+facemodel.toString());

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        String formattedDate = DateFormat('HH:mm:ss').format(DateTime.now());
        print(""+formattedDate.toString());

var url= Urls.BaseUrls+'facerecognition/get_data.php?name=${name}&face_model=${facemodel}&time=${formattedDate}';
        print("res body"+url.toString());
        final response = await http.get(Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response"+response.body.toString());
        if (response.statusCode == 200) {
          isLoading2.value=false;
          var res = jsonDecode(response.body);
          if(res['success']==true)
            {

              Fluttertoast.showToast(
                  msg: "Registration Successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

              Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) => DashBoard()),);
             // Navigator.pop(context!);
            }

        }
        else if (response.statusCode == 500) {
          isLoading2.value=false;
          print("data" + response.body.toString());
          CustomSnackBar.errorSnackBar("Server Side Error",context!);
        }
        else {
          isLoading2.value=false;
          print("data" + response.body.toString());
          CustomSnackBar.errorSnackBar("Something went wrong..",context!);

        }
      }

    }
    on SocketException catch (_) {
        return  CustomSnackBar.errorSnackBar("No internet connection....",context!);
    }
  }
}