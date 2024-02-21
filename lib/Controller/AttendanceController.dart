import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:realtime_face_recognition/Activity/DashboardPage.dart';

import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';

import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:realtime_face_recognition/main.dart';

class AttendanceController extends GetxController {
  RxBool isLoading=false.obs;
  RxList<Data> userList=<Data>[].obs;
  BuildContext? context=Get.context;
  void attendanceController(String staff_id,BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String formattedDate = DateFormat('HH:mm:ss').format(DateTime.now());
        print(""+formattedDate.toString());
         var url= Urls.emp_attendanceUrl;
         print("res body"+url.toString());
         var body = jsonEncode(<String, String>{
           'employee_id':staff_id,
           'date':date,
           'time': formattedDate
         });
        final response = await http.post(Uri.parse(url),
            headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
          body:body
        );
        print("response"+response.body.toString());
        if (response.statusCode == 201) {
          isLoading.value=false;
          var res = jsonDecode(response.body);
          print("vdbvsbd"+res.toString());
           if(res['message']=="Attendance recorded successfully")
           {

              Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) => DashBoard()),);
           }
        }

        else if (response.statusCode == 500) {
          isLoading.value=false;
          var res = jsonDecode(response.body);
          if(res['message']=="Already exists attendance")
          {

            Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) => DashBoard()),);
            CustomSnackBar.errorSnackBar("Already Punch Out...",context!);
          }
        }
        else {
          isLoading.value=false;
          print("data" + response.body.toString());
          CustomSnackBar.errorSnackBar("Something went wrong...",context!);

        }
      }

    }
    on SocketException catch (_) {
      return  CustomSnackBar.errorSnackBar("No internet connection....",context!);
    }
  }
}