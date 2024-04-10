import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:realtime_face_recognition/Constants/custom_snackbar.dart';
import 'package:realtime_face_recognition/Controller/StaffRegistrationController.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
import 'package:realtime_face_recognition/ML/Recognizer.dart';
import 'package:image/image.dart' as img;
import 'package:realtime_face_recognition/Model/usermodel.dart';
import 'package:realtime_face_recognition/main.dart';
import 'package:uuid/uuid.dart';

class StaffRegistrationPage extends StatefulWidget {
  late List<CameraDescription> cameras;
  StaffRegistrationPage({Key? key, required this.cameras}) : super(key: key);
  @override
  _StaffRegistrationPageState createState() => _StaffRegistrationPageState();
}

class _StaffRegistrationPageState extends State<StaffRegistrationPage> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = widget.cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;
  late List<Recognition> recognitions = [];
  RegistrationController regcontroller =Get.put(RegistrationController());
  //TODO declare face detector
  late FaceDetector faceDetector;

  //TODO declare face recognizer
  late Recognizer recognizer;
  bool register = false;
  File? _image;
  var image;
  @override
  void initState() {
    super.initState();

    //TODO initialize face detector
    var options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    //TODO initialize face recognizer
    recognizer = Recognizer();
    //TODO initialize camera footage
    initializeCamera(widget.cameras[1]);
    // initCamera(widget.cameras![1]);
  }

  //TODO code to initialize the camera feed
  initializeCamera(CameraDescription cameraDescription) async {
    controller = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        controller.startImageStream((image) async {
          if(isBusy==false)
          {
            isBusy=true;
          }
        });
       setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }
  Future takePicture() async {
    if (!controller.value.isInitialized) {return null;}
    if (controller.value.isTakingPicture) {return null;}
    try {
      await controller.setFlashMode(FlashMode.off);
      XFile picture = await controller.takePicture();
      setState((){
        _image = File(picture.path);

      });
      doFaceDetection();
      print("fhdhhfhjf"+picture.path.toString());
      // Navigator.push(context, MaterialPageRoute(
      //     builder: (context) => PreviewPage(
      //       picture: picture,
      //     )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }
  List<Face> faces = [];
  doFaceDetection() async {
    //TODO remove rotation of camera images
    _image = await removeRotation(_image!);
    String base64Image = base64Encode(_image!.readAsBytesSync());
    image = await _image?.readAsBytes();
  // image = await decodeImageFromList(image);

    //TODO passing input to face detector and getting detected faces
    InputImage inputImage = InputImage.fromFile(_image!);
    final bytes = _image!.readAsBytesSync();//await File(cropedFace!.path).readAsBytes();
    img.Image? faceImg = img.decodeImage(bytes!);
    //   img.Image faceImg2 = img.copyCrop(faceImg!,x:left.toInt(),y:top.toInt(),width:width.toInt(),height:height.toInt());
    showFaceRegistrationDialogue(base64Image,Uint8List.fromList(img.encodeBmp(faceImg!)));
     faces = await faceDetector.processImage(inputImage);
    for (Face face in faces) {
      // Rect faceRect = face.boundingBox;
      // num left = faceRect.left<0?0:faceRect.left;
      // num top = faceRect.top<0?0:faceRect.top;
      // num right = faceRect.right>image.width?image.width-1:faceRect.right;
      // num bottom = faceRect.bottom>image.height?image.height-1:faceRect.bottom;
      // num width = right - left;
      // num height = bottom - top;

      //TODO crop face
      final bytes = _image!.readAsBytesSync();//await File(cropedFace!.path).readAsBytes();
      img.Image? faceImg = img.decodeImage(bytes!);
   //   img.Image faceImg2 = img.copyCrop(faceImg!,x:left.toInt(),y:top.toInt(),width:width.toInt(),height:height.toInt());
      showFaceRegistrationDialogue(base64Image,Uint8List.fromList(img.encodeBmp(faceImg!)));
    //  Recognition recognition = recognizer.recognize(faceImg2, faceRect);

    }
  //  drawRectangleAroundFaces();

    //TODO call the method to perform face recognition on detected faces
  }
  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage = img.decodeImage(await File(inputImage!.path).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }
  //TODO close all resources
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  drawRectangleAroundFaces() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    print("${image.width}   ${image.height}");
    setState(() {
      image;
      faces;
    });
  }

  //TODO Face Registration Dialogue
  TextEditingController textEditingController = TextEditingController();
  showFaceRegistrationDialogue(var data,var cropedFace) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Face Registration",textAlign: TextAlign.center),alignment: Alignment.center,
        content: SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              Image.memory(
                cropedFace,
                width: 200,
                height: 200,
              ),
              SizedBox(
                width: 200,
                child: TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration( fillColor: Colors.white, filled: true,hintText: "Enter Name")
                ),
              ),
              const SizedBox(height: 10,),
              Obx(() =>     ElevatedButton(
                onPressed: regcontroller.isLoading2.value ? null : () {
                    var name=textEditingController.text;
                    if(name!="" && name!="null")
                      {
                      //  recognizer.registerFaceInDB(name,);
                        regcontroller.addStaff(name,data.toString(),context);
                      }
                    else
                      {
                        CustomSnackBar.errorSnackBar("Please Enter your name",context!);
                      }
                },
                style: ElevatedButton.styleFrom(backgroundColor:Colors.blue,minimumSize: const Size(200,40)),
                child:  regcontroller.isLoading2.value ? Center(child: Container(height: 20,width: 20,child: CircularProgressIndicator(),)) : Text('Register'),))
            ],
          ),
        ),contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // TODO Show rectangles around detected faces
  Widget buildResult() {
    if  (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }


if(_image==null)
  {
    return Text("");
  }

    return CustomPaint(
      painter: FacePainter(
          facesList: faces, imageFile: _image!.path),
    );
  }

  //TODO toggle camera direction
  void _toggleCameraDirection() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = widget.cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = widget.cameras[0];
    }
    await controller.stopImageStream();
    setState(() {
      controller;
    });
    initializeCamera(widget.cameras[1]);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {

      //TODO View for displaying the live camera footage
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
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
      // stackChildren.add(
      //   Positioned(
      //       top: 0.0,
      //       left: 0.0,
      //       width: size.width,
      //       height: size.height,
      //       child: buildResult()),
      // );
    }

    //TODO View for displaying the bar to switch camera direction or for registering faces
    stackChildren.add(Positioned(
      top: size.height - 140,
      left: 0,
      width: size.width,
      height: 80,
      child: Card(
        margin: const EdgeInsets.only(left: 20, right: 20),
        color: Colors.blue,
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                    Container(
                      width: 30,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      color: Colors.black,
                      onPressed: () {
                        setState(() {

                        });
                        takePicture();
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
          margin: const EdgeInsets.only(top: 0),
          color: Colors.black,
          child: Stack(
            children: stackChildren,
          )),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> facesList;
  dynamic imageFile;
  FacePainter({required this.facesList, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = Colors.blue;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
