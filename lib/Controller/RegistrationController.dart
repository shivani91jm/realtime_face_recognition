import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController{
  RxBool isLoading=false.obs;
  BuildContext? context=Get.context;
  void addStaff(String name,List<dynamic> facemodel) async
  {
    print("name"+name.toString());
    print("arra"+facemodel.toString());

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {


var url= Urls.BaseUrls+'facerecognition/get_data.php?name=${name}&face_model=${facemodel}';
        print("res body"+url.toString());
        final response = await http.get(Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},

        );
        print("response"+response.body.toString());
        if (response.statusCode == 200) {
          isLoading.value=false;
       //   LeaveCatAddModel res =LeaveCatAddModel.fromJson(jsonDecode(response.body));
         // print("vdbvsbd"+res.response.toString());
         //  if(res!=null)
         //  {
         //    var info= res.response;
         //    var msg=res.msg;
         //    if(info=="true")
         //    {
         //      // Fluttertoast.showToast(
         //      //     msg:" Add Successfully",
         //      //     toastLength: Toast.LENGTH_SHORT,
         //      //     gravity: ToastGravity.CENTER,
         //      //     timeInSecForIosWeb: 1,
         //      //     backgroundColor: AppColors.drakColorTheme,
         //      //     textColor: AppColors.white,
         //      //     fontSize: AppSize.medium
         //      // );
         //      // Navigator.pushNamed(context!, RoutesNamess.businessmandashboard);
         //      // showStaffLeaveCat();
         //    }
         //    else
         //    {
         //      // Fluttertoast.showToast(
         //      //     msg: ""+msg.toString(),
         //      //     toastLength: Toast.LENGTH_SHORT,
         //      //     gravity: ToastGravity.CENTER,
         //      //     timeInSecForIosWeb: 1,
         //      //     backgroundColor: AppColors.drakColorTheme,
         //      //     textColor: AppColors.white,
         //      //     fontSize: AppSize.medium
         //      // );
         //
         //    }
         //
         //  }
        }

        else if (response.statusCode == 500) {
          isLoading.value=false;
          print("data" + response.body.toString());
          CustomSnackBar.errorSnackBar("Server Side Error",context!);
        }
        else {
          isLoading.value=false;
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