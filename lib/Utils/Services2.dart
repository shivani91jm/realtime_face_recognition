import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:realtime_face_recognition/Model/AttendanceModel/AttendanceModelClass.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Service2{
  Future<List<AttendanceModelClass>> ShowAttendanceList(context,String date) async {
     List<AttendanceModelClass> data=[];
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var admin_id= await prefs.getString('admin_id')??"";
      var url= Urls.dailyattendance+"admin_id=${admin_id}&date=${date}";
      print("res body"+url.toString());
      final response = await http.get(Uri.parse(url),);
      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        List<dynamic> datasss=json.decode(response.body);
     //   print("data"+data.toString());
        datasss.map((e) {
          var datass = AttendanceModelClass.fromJson(e);
          data.add(datass);
        }).toList();

      } else {
        print('Error Occurred');
      }
    } catch (e) {
      print('Error Occurred'+e.toString());
    }
    return data;
  }
}