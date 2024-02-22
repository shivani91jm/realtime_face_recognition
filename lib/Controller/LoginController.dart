import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:realtime_face_recognition/Activity/DashboardPage.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class LoginController extends GetxController{
  RxBool isPasswordVisible = true.obs;
  BuildContext? context=Get.context;
  RxBool isLoading2=false.obs;
  togglePasswordVisibility() async{
    isPasswordVisible.value=!isPasswordVisible.value;
  }


  void login(String email , String password,BuildContext context) async
  {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isLoading2.value=true;
        var url= Urls.loginUrl;
        var body = jsonEncode(<String, String>{
          'email':email,
          'password':password,
          'login':'yes'
        });

        final map = <String, dynamic>{};
        map['email'] = email;
        map['password'] = password;
        map['login'] = 'yes';

        print("res body"+url.toString()+"gffgh"+map.toString());
        http.Response response = await http.post(Uri.parse(url),
          headers: <String, String>{
            "Content-Type": "application/x-www-form-urlencoded",

        },
          body:map
        );
        print("response"+response.body.toString());
        if (response.statusCode == 200) {
          isLoading2.value=false;
          var res = jsonDecode(response.body);
          if(res['success']==true)
          {
            var admin_id=res['uid'];
            var email=res['email'];
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('admin_id',admin_id);
            await prefs.setString('email',email);
            Fluttertoast.showToast(
                msg: "Login Successfully",
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