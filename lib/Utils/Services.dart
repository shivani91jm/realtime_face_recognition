
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Services{
  Future<StaffListModel> ShowStaffList(context) async {
    late StaffListModel data;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var admin_id= await prefs.getString('admin_id')??"";
      var url= Urls.staffListUrl+"admin_id=${admin_id}";
        print("res body"+url.toString());
      final response = await http.get(Uri.parse(url),);
      if (response.statusCode == 200) {
        final item = json.decode(response.body);

        data = StaffListModel.fromJson(item);// Mapping json response to our data model
      } else {
        print('Error Occurred');
      }
    } catch (e) {
      print('Error Occurred'+e.toString());
    }
    return data;
  }
  Future<StaffListModel> attendaneDateWiseStaffList(context) async {
    late StaffListModel data;
    try {
      final response = await http.get(Uri.parse(Urls.staffListUrl),);
      if (response.statusCode == 200) {
        final item = json.decode(response.body);
            final datamodel=item['data'];
        data = StaffListModel.fromJson(item);// Mapping json response to our data model
      } else {
        print('Error Occurred');
      }
    } catch (e) {
      print('Error Occurred'+e.toString());
    }
    return data;
  }





}