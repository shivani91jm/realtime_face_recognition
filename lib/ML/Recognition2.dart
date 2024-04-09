import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Controller/AttendanceController.dart';
import 'package:realtime_face_recognition/DB/FirebaseService.dart';
import 'package:realtime_face_recognition/ML/FaceRecognitionApi.dart';
import 'package:realtime_face_recognition/ML/UserData.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Model/usermodel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../DB/DatabaseHelper.dart';
import 'Recognition.dart';
import 'package:http/http.dart' as http;


class Recognizer222 {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  double threshold = 1.5;
  final dbHelper = DatabaseHelper();
  Map<String, Recognition> registered = Map();

  @override
  String get modelName => 'assets/mobile_face_net.tflite';
  final FirebaseService firebaseService = FirebaseService();
  List<UserData> users=[];
  List<double>? predictedArray;

  Recognizer222({int? numThreads}) {
   initDB();
    fetchstaffList();

  }
  initDB() async {
    await dbHelper.init();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var admin_id = await prefs.getString('admin_id') ?? "";
        var url = Urls.staffListUrl + "admin_id=${admin_id}";
        print("res body" + url.toString());
        final response = await http.get(
          Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response" + response.body.toString());
        if (response.statusCode == 200) {
          StaffListModel res = StaffListModel.fromJson(
              jsonDecode(response.body));
          print("vdbvsbd" + res.toString());
          if (res != null) {
            var info = res.success;
            if (info == true) {
             var   users = res.data;
             final allRows = await dbHelper.queryAllRows();
             print("allrows"+allRows.length.toString()+"user"+allRows.isEmpty.toString());

              if(allRows.isEmpty) {
                print("worng is value");
                for (int i = 0; i < users!.length; i++) {
                  String name = users![i].name.toString();
                  var url = users![i].faceModel;
                  String modifiedUrl = url.replaceFirst(
                      '\/home\/hqcj8lltjqyi\/public_html\/', '');
                  print(modifiedUrl);
                  http.Response response = await http.get(Uri.parse("https://"+modifiedUrl));
                  if (response.statusCode == 200) {
                    // Convert the image bytes to Base64
                    String image1 = base64Encode(response.bodyBytes);
                    print('Base64 encoded image: $image1');
                    Map<String, dynamic> row = {
                      DatabaseHelper.columnName: name,
                      DatabaseHelper.columnEmbedding: image1,
                      DatabaseHelper.columnStaffId: users![i].id
                    };
                    final id = await dbHelper.insert(row);
                    print('inserted row id: $id');
                  } else {
                    print('Failed to fetch image: ${response.statusCode}');
                  }


                }
              }

            else
              {
                if(allRows.length!=users!.length)
                  {
                    print("false is value");
                    for (int i = 0; i < users!.length; i++) {
                      String name = users![i].name.toString();
                      var url = users![i].faceModel;
                      String modifiedUrl = url.replaceFirst(
                          '\/home\/hqcj8lltjqyi\/public_html\/', '');
                      print(modifiedUrl);
                      http.Response response = await http.get(Uri.parse("https://"+modifiedUrl));
                      if (response.statusCode == 200) {
                        // Convert the image bytes to Base64
                        String image1 = base64Encode(response.bodyBytes);
                        print('Base64 encoded image: $image1');
                        Map<String, dynamic> row = {
                          DatabaseHelper.columnName: name,
                          DatabaseHelper.columnEmbedding: image1,
                          DatabaseHelper.columnStaffId: users![i].id
                        };
                        final id = await dbHelper.insert(row);
                        print('inserted row id: $id');
                      } else {
                        print('Failed to fetch image: ${response.statusCode}');
                      }
                    }
                  }
                else
                  {
                    print("true is value");
                  }
              }
            }
          }
        }
        else if (response.statusCode == 401) {
          print("data" + response.body.toString());

          // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
        }
        else if (response.statusCode == 500) {
          print("data" + response.body.toString());
        }
        else {
          print("data" + response.body.toString());
        }
      }
    }
    on SocketException catch (_) {

    }
  //  fetchstaffList();
  }
  //TODO convert CameraImage to InputImage
  InputImage getInputImage(CameraImage frame,CameraDescription description) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = description;
    final imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat = InputImageFormatValue.fromRawValue(frame!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = frame!.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }
  fetchstaffList() async{
    await dbHelper.init();
    final allRows = await dbHelper.queryAllRows();
    if(allRows.isNotEmpty) {
      for (final row in allRows) {
        //  debugPrint(row.toString());
        print(row[DatabaseHelper.columnName]);
        String name = row[DatabaseHelper.columnName];
        String url = row[DatabaseHelper.columnEmbedding];
        String id = row[DatabaseHelper.columnStaffId];
        print(url);

        UserData data = UserData(name, "", id, url);
        users.add(data);

      }
    }
  }

}




