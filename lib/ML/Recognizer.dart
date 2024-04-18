import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:realtime_face_recognition/Controller/AttendanceController.dart';
import 'package:realtime_face_recognition/DB/FirebaseService.dart';
import 'package:realtime_face_recognition/Model/StaffList/Data.dart';
import 'package:realtime_face_recognition/Model/StaffList/StaffListModel.dart';
import 'package:realtime_face_recognition/Model/usermodel.dart';
import 'package:realtime_face_recognition/Utils/Urils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../DB/DatabaseHelper.dart';
import 'Recognition.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;


class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  double threshold = 1.5;
  final dbHelper = DatabaseHelper();
  Map<String,Recognition> registered = Map();
  @override
  String get modelName => 'assets/mobile_face_net.tflite';
  final FirebaseService firebaseService = FirebaseService();
  List<Data>? users;
  List<double>? predictedArray;
  File? _image;
  late FaceDetector faceDetector;

  Recognizer({int? numThreads}) {
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
    initDB();
  }

  initDB() async {
    await dbHelper.init();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var admin_id= await prefs.getString('admin_id')??"";
        var url= Urls.staffListUrl+"admin_id=${admin_id}";
        print("res body"+url.toString());
        final response = await http.get(Uri.parse(url), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',},);
        print("response"+response.body.toString());
        if (response.statusCode == 200) {

          StaffListModel res =StaffListModel.fromJson(jsonDecode(response.body));
          print("vdbvsbd"+res.toString());
          if(res!=null)
          {
            var info= res.success;

            if(info==true)
            {
               users=res.data;

            }
            loadRegisteredFaces();

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





  }
  void loadRegisteredFaces() async {
    registered.clear();
    for(int i=0;i<users!.length;i++)
      {
             String name = users![i].name.toString();
             var url= users![i].faceModel;
             String modifiedUrl = url.replaceFirst('\/home\/hqcj8lltjqyi\/public_html\/', '');
             print(modifiedUrl);
             String filePath = 'https://'+modifiedUrl;
             String localPath = '/path/to/save/file.png'; // Specify local path where you want to save the file

             // Download the file
             _image= await urlToFile(filePath);
           //  File file = File(filePath);


             //_image = file;
             //TODO remove rotation of camera images
             _image = await removeRotation(_image!);

             var image = await _image?.readAsBytes();
             var images =  await decodeImageFromList(image!,);

             //TODO passing input to face detector and getting detected faces
             InputImage inputImage = InputImage.fromFile(_image!);
             List<Face> faces = await faceDetector.processImage(inputImage);
             for (Face face in faces) {
               Rect faceRect = face.boundingBox;
               num left = faceRect.left < 0 ? 0 : faceRect.left;
               num top = faceRect.top < 0 ? 0 : faceRect.top;
               num right = faceRect.right > images.width ? images.width - 1 : faceRect
                   .right;
               num bottom = faceRect.bottom > images.height ? images.height - 1 : faceRect
                   .bottom;
               num width = right - left;
               num height = bottom - top;

               //TODO crop face
               final bytes = _image!.readAsBytesSync();
               img.Image? faceImg = img.decodeImage(bytes!);
               img.Image faceImg2 = img.copyCrop(faceImg!, x: left.toInt(), y: top.toInt(), width: width.toInt(), height: height.toInt());

               Recognition recognition = recognize(faceImg2, faceRect);
               String staff_id=users![i].id.toString();
               Recognition recognitionss = Recognition(name,Rect.zero,recognition.embeddings,0,staff_id,modifiedUrl,"");
               registered.putIfAbsent(name, () => recognitionss);
               print("R="+name);

             }



      }

  }

    Future<File> urlToFile(String imageUrl) async {
      final response = await http.get(Uri.parse(imageUrl));
      final imageName = 'my_image.png'; // Set a desired file name
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/$imageName';
      final imageFile = File(localPath);
      await imageFile.writeAsBytes(response.bodyBytes);
      return imageFile;
    }

  List<double> parseStringToList(String str) {
    // Remove brackets [ and ]
    String numbersString = str.substring(1, str.length - 1);

    // Split the string by commas and parse each substring into a double
    List<double> numbers = numbersString.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();

    return numbers;
  }
  void registerFaceInDB(String name, List<double> embedding) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnEmbedding: embedding.join(",")
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    loadRegisteredFaces();
  }


  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage = img.copyResize(inputImage!, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!.expand((channel) => [channel.r, channel.g, channel.b]).map((value) => value.toDouble()).toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] = (float32Array[c * height * width + h * width + w]-127.5)/127.5;
        }
      }
    }
    return reshapedArray.reshape([1,112,112,3]);
  }

  Recognition recognize(img.Image image,Rect location) {

    //TODO crop face from image resize it and convert it to float array
    var input = imageToArray(image);
    print(input.shape.toString());

    //TODO output array
   List output = List.filled(1*192, 0).reshape([1,192]);

    //TODO performs inference
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
//    output = output.reshape([192]);
//    predictedArray = List.from(output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms$output');

    //TODO convert dynamic list to double list
   List<double>predictedArray = output.first.cast<double>();

     //TODO looks for the nearest embeeding in the database and returns the pair

     Pair pair = findNearest(predictedArray!);

    print("distance= ${pair.distance}, pair.name==${pair.name}");
    return Recognition(pair.name,location,predictedArray!,pair.distance,pair.id,pair.imageUrl,"");
  }
  //TODO  looks for the nearest embeeding in the database and returns the pair which contain information of registered face with which face is most similar
  findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", -5,"","","");
    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;
      List<double> knownEmb = item.value.embeddings;
      final staff_id=item.value.id;
      final staff_url=item.value.imageUrl;
      double distance = 0.0;
      int minDist = 999;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff*diff;
      }
      distance = sqrt(distance);

      if (pair.distance == -5 || distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
        pair.id=staff_id;
        pair.imageUrl=staff_url;
      }

    }
    return pair;
  }

  void close() {
    interpreter.close();
  }

  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage = img.decodeImage(await File(inputImage!.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }




}
class Pair{
   String name;
   double distance;
   String id;
   String imageUrl;
   String image2;
   Pair(this.name,this.distance,this.id,this.imageUrl,this.image2);
}


