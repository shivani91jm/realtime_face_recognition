import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';

class StaffListController extends GetxController {
  RxBool isLoading=false.obs;
  RxList<Data> userList=<Data>[].obs;
  void showStaffListController() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
         var url= Urls.staffListUrl;
         print("res body"+url.toString());
        final response = await http.get(Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response"+response.body.toString());
        if (response.statusCode == 200) {
          isLoading.value=false;
          StaffListModel res =StaffListModel.fromJson(jsonDecode(response.body));
          print("vdbvsbd"+res.toString());
           if(res!=null)
           {
             var info= res.success;

             if(info==true)
             {
               userList!=res.data.obs;
               refresh();
               update();
             }


           }
        }
        else if (response.statusCode == 401) {
          isLoading.value=false;
          print("data" + response.body.toString());

          // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
        }
        else if (response.statusCode == 500) {
          isLoading.value=false;
          print("data" + response.body.toString());
        }
        else {
          isLoading.value=false;
          print("data" + response.body.toString());

        }
      }

    }
    on SocketException catch (_) {}
  }
}