import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_api/face_api.dart' hide Image;
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Activity/user_details_view.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Controller/CameraProvider.dart';
import 'package:realtime_face_recognition/Controller/FaceDetectorWidget.dart';
import 'package:realtime_face_recognition/ML/CustomePainClass.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognition2.dart';
import 'package:realtime_face_recognition/ML/Recognizer.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/ML/UserData.dart';



class StaffRecognationPage extends StatefulWidget  {
  late List<CameraDescription> cameras;
  StaffRecognationPage({Key? key, required this.cameras}) : super(key: key);
  @override
  _StaffRecognationPageState createState() => _StaffRecognationPageState();
}

class _StaffRecognationPageState extends State<StaffRecognationPage> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = widget.cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;
  late List<Recognition> recognitions = [];
  final _convertNativeImgStreamPlugin = ConvertNativeImgStream();
  //TODO declare face detector
  late FaceDetector faceDetector;

  //TODO declare face recognizer
  late Recognizer recognizer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  static  String flag="1";
  Uint8List? imageBytes;
  File? imageFile;
  late Recognizer222 recognizer222;
  String _similarity = "nil";
  String _liveness = "nil";
   var image1 = new MatchFacesImage();
   var image2 = new MatchFacesImage();
  BuildContext? contextss= Get.context;
  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer
    recognizer = Recognizer();
    recognizer222 = Recognizer222();
    //TODO initialize camera footage
   initializeCamera(widget.cameras[1]);

  }

  //TODO code to initialize the camera feed
  initializeCamera(CameraDescription cameraDescription) async {
    controller = CameraController(cameraDescription, ResolutionPreset.high,imageFormatGroup: ImageFormatGroup.yuv420);
    try {
      await controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controller.startImageStream((image) async {
          if(!isBusy)
          {
            isBusy=true;
            frame = image;
            doFaceDetectionOnFrame(contextss!);

          }});
      });

    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  //TODO close all resources
  @override
  void dispose() {

    controller?.dispose();
    recognitions.clear();
    faceDetector.close();
     _audioPlayer.dispose();
    super.dispose();
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  CameraImage? frame;
  doFaceDetectionOnFrame(BuildContext context) async {
    try{
      recognitions.clear();

      //TODO convert frame into InputImage format
      InputImage? inputImage = recognizer222.getInputImage(frame!,description);
     // Uint8List? imageBytes = await inputImage!.bytes;
     // File imageFile = await createTemporaryFile();
     // var bbb= await imageFile.writeAsBytes(imageBytes!);
     // image2.bitmap=base64Encode(bbb.readAsBytesSync());
     // image2.imageType=ImageType.PRINTED;
      //TODO pass InputImage to face detection model and detect faces
      List<Face> faces = await faceDetector.processImage(inputImage!);
      //TODO perform face recognition on detected faces
      // setState(() {
            _scanResults = faces;
         //   isBusy = false;
         // });
          performFaceRecognition(faces,context);
    } catch(e){
      CustomSnackBar.errorSnackBar("Face Detcion Problem Please Refresh",context);
    }
    finally{
     // setState(() => isBusy = false);
    }


  }
  Future<File> createTemporaryFile() async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/my_image.png');
    return tempFile;
  }
  double calculateBrightness(CameraImage image) {
    double sum = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        sum += image.planes[0].bytes[y * image.width + x] & 0xFF;
      }
    }
    double brightness = sum / (image.width * image.height);
    return brightness;
  }


  img.Image? image;
  bool register = false;
  // TODO perform Face Recognition
  performFaceRecognition(List<Face> faces,BuildContext context) async {
    //TODO convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image = img.copyRotate(
        image!, angle: camDirec == CameraLensDirection.front ? 270 : 90);

    for (Face face in faces) {
       var faceRect = face!.boundingBox;
      //
      // // Calculate the width and height of the bounding box
       int? width = (faceRect.right! - faceRect.left!).toInt();
      int height = (faceRect.bottom! - faceRect.top!).toInt();
      //
      // // Get the left and top coordinates of the bounding box
      int left = faceRect.left!.toInt();
      int top = faceRect.top!.toInt();
      //
      // // Crop the face directly from the image
       img.Image croppedFace = img.copyCrop(image!, x: left, y: top, width: width, height: height);
      //

       Uint8List imges=  Uint8List.fromList(img.encodeBmp(croppedFace));
       String base64String = base64Encode(imges);
       image2.bitmap=base64String;
       image2.imageType=ImageType.PRINTED;
      //TODO pass cropped face to face recognition model
      Recognition recognition = recognizer.recognize(croppedFace, face.boundingBox);
      if (recognition.distance > 0.90) {
        recognition.name = "Unknown";
      }

      recognitions.add(recognition);

      // if (recognition.name!= "Unknown") {
      //   // var ur="https://"+recognition.imageUrl;
      //   // File userss=await recognizer.urlToFile(ur);
      //   // image1.bitmap = base64Encode(File(userss!.path).readAsBytesSync() );
      //   // image1.imageType =  ImageType.PRINTED;
      //   // var request = new MatchFacesRequest();
      //   // request.images = [image1, image2];
      //   // print("hjdsfjk"+request.images.toString());
      //   // FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      //   //   var response = MatchFacesResponse.fromJson(json.decode(value));
      //   //   print("object+"+response.toString());
      //   //   FaceSDK.matchFacesSimilarityThresholdSplit(
      //   //       jsonEncode(response!.results), 0.75)
      //   //       .then((str) {
      //   //     var split = MatchFacesSimilarityThresholdSplit.fromJson(
      //   //         json.decode(str));
      //   //
      //   //     setState(() {
      //   //       _similarity = split!.matchedFaces.isNotEmpty
      //   //           ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
      //   //           : "error";
      //   //       log("similarity: $_similarity");
      //   //
      //   //       if (_similarity != "error" && double.parse(_similarity) > 90.00) {
      //   //         //print("hghg" + user.name);
      //   //         // faceMatched = true;
      //   //         //  setState(() {
      //   //         //    trialNumber = 1;
      //   //         //    //isMatching = false;
      //   //         //  });
      //   //
      //   //         _audioPlayer
      //   //           ..stop()
      //   //           ..setReleaseMode(ReleaseMode.release)
      //   //           ..play(AssetSource("sucessAttendance.m4r"));
      //   // UserData data = UserData(
      //   //     user.name, image1.bitmap!, user.id, image2.bitmap!);
      //
      //   Navigator.pushReplacement(context!, MaterialPageRoute(
      //       builder: (context) => UserDetailsView(user: recognition,image2: croppedFace,)),);
      // }

      //});
      // });
      //   });
       // Batch multiple face matching requests
       List<MatchFacesImage> batchRequests = [];

       for (UserData user in recognizer222.users) {
       //  File userss=await recognizer.urlToFile(user.targetimage);
        // image1.bitmap = base64Encode(File(userss!.path).readAsBytesSync() );
         image1.imageType =  ImageType.PRINTED;
         batchRequests.add(image1);
       }
       batchRequests.add(image2);
       var request = new MatchFacesRequest();
       request.images = batchRequests;
       FaceSDK.matchFaces(jsonEncode(request)).then((value) {
         var response = MatchFacesResponse.fromJson(json.decode(value));
         FaceSDK.matchFacesSimilarityThresholdSplit(
             jsonEncode(response!.results), 0.75)
             .then((str) {
           var split = MatchFacesSimilarityThresholdSplit.fromJson(
               json.decode(str));

           setState(() {
             _similarity = split!.matchedFaces.isNotEmpty
                 ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
                 : "error";
             log("similarity: $_similarity");

             if (_similarity != "error" && double.parse(_similarity) > 90.00) {
               //print("hghg" + user.name);
               // faceMatched = true;
               //  setState(() {
               //    trialNumber = 1;
               //    //isMatching = false;
               //  });

               _audioPlayer
                 ..stop()
                 ..setReleaseMode(ReleaseMode.release)
                 ..play(AssetSource("sucessAttendance.m4r"));
               // UserData data = UserData(
               //     user.name, image1.bitmap!, user.id, image2.bitmap!);

             //  Navigator.pushReplacement(context!, MaterialPageRoute(builder: (context) =>  UserDetailsView(user: recognition,)),);

             }
             else {

               print("no image found");
             }
           });
         });
       });

       }

      // setState(() {
      //   isBusy = false;
      // });

    // showDialog(
    //   context: context,
    //   builder: (ctx) => AlertDialog(
    //     title: const Text("Face Registration",textAlign: TextAlign.center),alignment: Alignment.center,
    //     content: SizedBox(
    //       height: 340,
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           const SizedBox(height: 20,),
    //           Image.memory(Uint8List.fromList(img.encodeBmp(image!)),
    //             width: 200,
    //             height: 200,
    //           ),
    //
    //           const SizedBox(height: 10,),
    //
    //         ],
    //       ),
    //     ),contentPadding: EdgeInsets.zero,
    //   ),
    // );
    }


  // initDB() async {
  //   await dbHelper.init();
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       final SharedPreferences prefs = await SharedPreferences.getInstance();
  //       var admin_id = await prefs.getString('admin_id') ?? "";
  //       var url = Urls.staffListUrl + "admin_id=${admin_id}";
  //       print("res body" + url.toString());
  //       final response = await http.get(
  //         Uri.parse(url), headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',},);
  //       print("response" + response.body.toString());
  //       if (response.statusCode == 200) {
  //         StaffListModel res = StaffListModel.fromJson(
  //             jsonDecode(response.body));
  //         print("vdbvsbd" + res.toString());
  //         if (res != null) {
  //           var info = res.success;
  //           if (info == true) {
  //             var   users = res.data;
  //             final allRows = await dbHelper.queryAllRows();
  //             print("allrows"+allRows.length.toString()+"user"+allRows.isEmpty.toString());
  //
  //             if(allRows.isEmpty) {
  //               print("worng is value");
  //               for (int i = 0; i < users!.length; i++) {
  //                 String name = users![i].name.toString();
  //                 var url = users![i].faceModel;
  //                 String modifiedUrl = url.replaceFirst(
  //                     '\/home\/hqcj8lltjqyi\/public_html\/', '');
  //                 print(modifiedUrl);
  //                 http.Response response = await http.get(Uri.parse("https://"+modifiedUrl));
  //                 if (response.statusCode == 200) {
  //                   // Convert the image bytes to Base64
  //                   String image1 = base64Encode(response.bodyBytes);
  //                   print('Base64 encoded image: $image1');
  //                   Map<String, dynamic> row = {
  //                     DatabaseHelper.columnName: name,
  //                     DatabaseHelper.columnEmbedding: image1,
  //                     DatabaseHelper.columnStaffId: users![i].id
  //                   };
  //                   final id = await dbHelper.insert(row);
  //                   print('inserted row id: $id');
  //                 } else {
  //                   print('Failed to fetch image: ${response.statusCode}');
  //                 }
  //
  //
  //               }
  //               fetchstaffList();
  //             }
  //
  //             else
  //             {
  //               if(allRows.length!=users!.length)
  //               {
  //                 print("false is value");
  //                 for (int i = 0; i < users!.length; i++) {
  //                   String name = users![i].name.toString();
  //                   var url = users![i].faceModel;
  //                   String modifiedUrl = url.replaceFirst(
  //                       '\/home\/hqcj8lltjqyi\/public_html\/', '');
  //                   print(modifiedUrl);
  //                   http.Response response = await http.get(Uri.parse("https://"+modifiedUrl));
  //                   if (response.statusCode == 200) {
  //                     // Convert the image bytes to Base64
  //                     String image1 = base64Encode(response.bodyBytes);
  //                     print('Base64 encoded image: $image1');
  //                     Map<String, dynamic> row = {
  //                       DatabaseHelper.columnName: name,
  //                       DatabaseHelper.columnEmbedding: image1,
  //                       DatabaseHelper.columnStaffId: users![i].id
  //                     };
  //                     final id = await dbHelper.insert(row);
  //                     print('inserted row id: $id');
  //                   } else {
  //                     print('Failed to fetch image: ${response.statusCode}');
  //                   }
  //                 }
  //                 fetchstaffList();
  //               }
  //               else
  //               {
  //                 print("true is value");
  //               }
  //             }
  //           }
  //         }
  //       }
  //       else if (response.statusCode == 401) {
  //         print("data" + response.body.toString());
  //
  //         // Navigator.push(context!, MaterialPageRoute(builder: (context) => LoginPage()),);
  //       }
  //       else if (response.statusCode == 500) {
  //         print("data" + response.body.toString());
  //       }
  //       else {
  //         print("data" + response.body.toString());
  //       }
  //     }
  //   }
  //   on SocketException catch (_) {
  //
  //   }
  //
  // }
  // fetchstaffList() async{
  //   await dbHelper.init();
  //   final allRows = await dbHelper.queryAllRows();
  //   if(allRows.isNotEmpty) {
  //     for (final row in allRows) {
  //       //  debugPrint(row.toString());
  //       print(row[DatabaseHelper.columnName]);
  //       String name = row[DatabaseHelper.columnName];
  //       String url = row[DatabaseHelper.columnEmbedding];
  //       String id = row[DatabaseHelper.columnStaffId];
  //       print(url);
  //
  //       UserData data = UserData(name, "", id, url);
  //       users.add(data);
  //
  //     }
  //   }
  // }




  // TODO method to convert CameraImage to Image
  // img.Image convertYUV420ToImage(CameraImage cameraImage) {
  //   final width = cameraImage.width;
  //   final height = cameraImage.height;
  //   final yRowStride = cameraImage.planes[0].bytesPerRow;
  //   final uvRowStride = cameraImage.planes[1].bytesPerRow;
  //   final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
  //   final image = img.Image(width:width, height:height);
  //   for (var w = 0; w < width; w++) {
  //     for (var h = 0; h < height; h++) {
  //       final uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
  //       final index = h * width + w;
  //       final yIndex = h * yRowStride + w;
  //
  //       final y = cameraImage.planes[0].bytes[yIndex];
  //       final u = cameraImage.planes[1].bytes[uvIndex];
  //       final v = cameraImage.planes[2].bytes[uvIndex];
  //
  //
  //       int color = yuv2rgb(y, u, v);
  //       int r = (color >> 16) & 0xFF;
  //       int g = (color >> 8) & 0xFF;
  //       int b = color & 0xFF;
  //
  //       // If the color is red, make it transparent
  //       if (r > 200 && g < 50 && b < 50) {
  //         image.data!.setPixelRgba(w, h, 0, 0, 0, 0);
  //       } else {
  //         image.data!.setPixelRgba(w, h, r, g, b,0);
  //       }
  //     }
  //
  //
  //
  //       //= yuv2rgb(y, u, v);
  //
  //    // }
  //   }
  //   return image;
  // }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
    final image = img.Image(width:width, height:height);
    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex = uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        int color = yuv2rgb(y, u, v);
        int r = (color >> 16) & 0xFF;
        int g = (color >> 8) & 0xFF;
        int b = (color >> 8) & 0xFF;

        // If the color is blue, make it transparent
        // if (b > 100 && g < 50 && r < 50) {
        //   image.data!.setPixelRgba(w, h, 0, 0, 0, 0);
        // } else {
        //   image.data!.setPixelRgba(w, h, r, g, b, 0);
        // }
        // if ((b > 200 && g < 50 && r < 50) || (r > 80 && g < 80 && b > 80)) {
        //   image.data!.setPixelRgba(w, h, 0, 0, 0, 0);
        // } else {
        //   image.data!.setPixelRgba(w, h, r, g, b, 0);
        // }
        image.data!.setPixelRgba(w, h, r, g, b, 0);
      }
    }
    return image;
  }



  int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 | ((b << 16) & 0xff0000) | ((g << 8) & 0xff00) | (r & 0xff);
  }
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };



  // TODO Show rectangles around detected faces
  Widget buildResult() {
    if (controller == null) {
      return const  Center(child: CircularProgressIndicator());
    }
    if(_scanResults==null)
    {
      return const Center(child: Text(""));
    }
    // final Size imageSize = Size(
    //   controller.value.previewSize!.height,
    //   controller.value.previewSize!.width,
    // );
    CustomPainter painter = FaceDetectorPainter( _scanResults, MediaQuery.of(contextss!).size);
    return CustomPaint(
      painter: painter,
    );
  }

  //TODO toggle camera direction
  void _toggleCameraDirection() async {
    // if (camDirec == CameraLensDirection.back) {
    //   camDirec = CameraLensDirection.front;
    //   description = widget.cameras[1];
    // } else {
    //   camDirec = CameraLensDirection.back;
    //   description = widget.cameras[0];
    // }
  //   await controller.stopImageStream();

    initializeCamera(widget.cameras[1]);
    setState(() {

      isBusy  = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stackChildren = [];
  //  size = MediaQuery.of(context).size;
    if (controller != null) {

      //TODO View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            )
                : Container(),
          ),
        ),
      );

      //TODO View for displaying rectangles around detected aces
      stackChildren.add(
        Positioned(
            top: 0.0,
            left: 0.0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: buildResult()),
      );
    }

    //TODO View for displaying the bar to switch camera direction or for registering faces
    final cameraProvider = Provider.of<CameraProvider>(context);
    final List<Face> faces = cameraProvider.detectedFaces;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.cached,
              color: Colors.white,
            ),
            iconSize: 40,
            color: Colors.black,
            onPressed: () {
              _toggleCameraDirection();
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}


class FaceDetectorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        final detectedFaces = cameraProvider.detectedFaces;
        return Stack(
          children: [
            for (var face in detectedFaces)
              Positioned(
                left: face.boundingBox.left,
                top: face.boundingBox.top,
                width: face.boundingBox.width,
                height: face.boundingBox.height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2.0),
                  ),
                ),
              ) ,
          ],
        );
      },
    );
  }
}
