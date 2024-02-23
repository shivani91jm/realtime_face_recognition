import 'dart:io';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:path_provider/path_provider.dart';
import 'package:realtime_face_recognition/Activity/LoginPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRecogniationPage.dart';
import 'package:realtime_face_recognition/Activity/StaffRegistrationPage.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/Utils/AppFontFamily.dart';
import 'package:shared_preferences/shared_preferences.dart';



import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SharedPreferences loginData;
  var businessMob="",bussinessName="",bussinessEmail="",name="";
  var no_of_active_bussiness="";
  final TextEditingController _MobileController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  List<String> languageitemList = ['English', 'Hindi'];
  var language="";

  var images;
  File? _image;
  List<Face> faces = [];
  dynamic _scanResults;
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown,]);
    _MobileController.dispose();
    languageitemList.clear();
    super.dispose();

  }
  @override
  void initState()
  {
    // TODO: implement initState
    super.initState();


    getValueOfSharedPrefrence();

    getValue();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    bool isSwitched = false;
    bool light = true;
    return Scaffold(
      backgroundColor:Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          title: Text(AppContents.settings.tr,style: AppFontFamilyClass.bold,),
          actions: [
            new IconButton(
                icon: new Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () async{
                 _showLogoutDilaog(context);
                }
            )]
          ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 40),
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Column(
                  children: [
                    //-----------------------------Business Settings Container------------------------------------
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                      child: Column(
                        children: [
                          //----------------------------------title busniness name-------------------------------------
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                    child: Row(
                                      children: [
                                        Image.asset('assets/images/tech.png',
                                            width: 25,
                                            height: 25,
                                            fit:BoxFit.fill
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(13.0,8.0,8.0,8.0),
                                          child: Text(AppContents.business_settings.tr,style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0
                                          ),),
                                        ),
                                        Divider(
                                          color: Colors.black,
                                          height: 1,
                                        )
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                         Divider(
                           height: 2,
                           color: Colors.black26
                         ),
                          //----------------------------bussiness name-------------------------------
                          GestureDetector(
                            onTap: ()async {
                              var camera=  await availableCameras();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  StaffRegistrationPage(cameras: camera,)),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Staff Registration",style: TextStyle(
                                                color: Colors.black38,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0
                                            ),),
                                            Text(""+bussinessName,style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0
                                            ),),

                                          ],
                                        ),
                                      )
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      iconSize: 18,
                                      splashColor: Colors.blue ,
                                      icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                      onPressed: () async
                                      {
                                        var camera=  await availableCameras();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>  StaffRegistrationPage(cameras: camera,)),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //-----------------------month calculation---------------------------------------

                          Divider(
                              height: 2,
                              color: Colors.black26
                          ),
                          //shiflt Settings

                          //================Attendance Settings=================

                          //Attendance on Holidays
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(AppContents.Holiday.tr,style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0
                                          ),),

                                        ],
                                      ),
                                    ),),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      iconSize: 18,
                                      splashColor: Colors.blue,
                                      icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                      onPressed: (){

                                      },
                                    ),
                                  ),
                                ]),),

                          Divider(
                              height: 2,
                              color: Colors.black26
                          ),
                          //---------------aatendance scan-----------
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async{
                                      var camera=  await availableCameras();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>  StaffRecognationPage(cameras: camera,)),
                                      );
                                    },
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(AppContents.scan.tr,style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0
                                            ),),

                                          ],
                                        ),
                                      ),),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      iconSize: 18,
                                      splashColor: Colors.blue ,
                                      icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                      onPressed: () async{
                                      var camera=  await availableCameras();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>  StaffRecognationPage(cameras: camera,)),
                                      );
                                     //  Navigator.push(context, MaterialPageRoute(builder: (_) => AutoDectionPage(cameras: camera)));


                                        },
                                    ),
                                  ),
                                ]),),

                          Divider(
                              height: 2,
                              color: Colors.black26
                          ),
                          //Business bank account


                        ],
                ),
              ),

                  ],
          ),
        ),
              //-----------------------------------------------------
              //Account Settings Conatiner
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                  child: Column(
                    children: [
                      //----------------------------title busniness name------------------------------------
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                                child: Row(
                                  children: [
                                    Image.asset('assets/images/tech.png',
                                        width: 25,
                                        height: 25,
                                        fit:BoxFit.fill
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(13.0,8.0,8.0,8.0),
                                      child: Text(AppContents.accountsettings.tr,style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0
                                      ),),
                                    ),
                                    Divider(
                                      color: Colors.black,
                                      height: 1,

                                    )
                                  ],
                                )
                            ),

                          ],
                        ),
                      ),
                      Divider(
                          height: 2,
                          color: Colors.black26
                      ),
                      //--------------------------Chanage Launge-----------------------------------------
                      GestureDetector(
                        onTap: (){
                          //showdialogLaguage(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppContents.Language.tr,style: TextStyle(
                                            color: Colors.black38,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0
                                        ),),
                                        Text(language.tr,style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0
                                        ),),

                                      ],
                                    ),
                                  )
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  iconSize: 18,
                                  splashColor: Colors.blue ,
                                  icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                  onPressed: (){
                                  // showdialogLaguage(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                          height: 2,
                          color: Colors.black26
                      ),



                    ],
                  ),
                ),
              ),
              // ================================Personal Info======================
              Card(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                  child: Column(
                    children: [
                      //tile busniness name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                                child: Row(
                                  children: [
                                    Image.asset('assets/images/tech.png',
                                        width: 25,
                                        height: 25,
                                        fit:BoxFit.fill
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(13.0,8.0,8.0,8.0),
                                      child: Text(AppContents.personal_infomation.tr,style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0
                                      ),),
                                    ),
                                    Divider(
                                      color: Colors.black,
                                      height: 1,

                                    )
                                  ],
                                )
                            ),

                          ],
                        ),
                      ),
                      Divider(
                          height: 2,
                          color: Colors.black26
                      ),
                      //User Name
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppContents.name.tr,style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0
                                      ),),
                                      Text(""+name,style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0
                                      ),),

                                    ],
                                  ),
                                )
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                iconSize: 18,
                                splashColor: Colors.blue ,
                                icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                onPressed: (){

                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                          height: 2,
                          color: Colors.black26
                      ),
                      //Phone Number
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppContents.phoneno.tr,style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0
                                      ),),
                                      Text(""+businessMob,style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0
                                      ),),

                                    ],
                                  ),
                                )
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                iconSize: 18,
                                splashColor: Colors.blue,
                                icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                onPressed: (){

                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                          height: 2,
                          color: Colors.black26
                      ),
                      //Email Id
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(1.0,0.0,0.0,0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppContents.email.tr,style: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0
                                      ),),
                                      Text(""+bussinessEmail,style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0
                                      ),),
                                    ],
                                  ),
                                )
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                iconSize: 18,
                                splashColor:Colors.blue,
                                icon: Icon(Icons.arrow_forward_ios_rounded,color:  Colors.black38,),
                                onPressed: (){},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ])
        )
      ),
    );
  }

  void getValueOfSharedPrefrence() async {
    loginData=await SharedPreferences.getInstance();
    setState(() {
      loginData.getString("token");
      bussinessEmail= loginData.getString("email")??"";
      name=loginData.getString("name")??"";
      businessMob=loginData.getString("mobile")??"";
      bussinessName=loginData.getString("bussiness_name")??"";
      if(businessMob=="null" )
        {
          //showdialog(context);
        }
       else if(businessMob=="")
        {
         // showdialog(context);
        }
       if(bussinessName=="null" || bussinessName==null)
         {
           bussinessName="";
         }

    });
  }


  void _showLogoutDilaog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title:  Text("Logout",style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold
          ),),
          content:  Text("Are you sure to logout app ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child:  Text("Cancel",style: TextStyle(
                  fontSize: 15,
                  color: Colors.red
              ),),
            ),
            TextButton(
              onPressed: () async{
                _logoutUser();
              } ,
              child:  Text("OK",style: TextStyle(
                  fontSize: 15,
                  color: Colors.green
              ),),
            ),
          ],
        ));
  }
  //
  void _logoutUser() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
   // FirebaseAuth.instance.signOut();
  //  GoogleSignIn _googleSignIn = GoogleSignIn();
   // bool isSignedIn = await _googleSignIn.isSignedIn();
  //  _googleSignIn.signOut();
    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()),);

  }
  //
  // void showdialog(BuildContext context) {
  //   showDialog<String>(
  //       context: context,
  //       builder: (BuildContext context) => AlertDialog(
  //         title:  Center(
  //           child: Text(AppContents.updatemobile.tr,style: TextStyle(
  //               fontSize: AppSize.large,
  //               color: Colors.black87,
  //               fontWeight: FontWeight.bold
  //           ),),
  //         ),
  //         content: Container(
  //           height: 150,
  //           child: Form(
  //             key: _formkey,
  //             child: Column(
  //               children: [
  //                  Text(AppContents.mobileEmpty.tr),
  //                 Container(
  //                   margin: EdgeInsets.fromLTRB(0,10,0,10),
  //                   padding: EdgeInsets.all(8.0),
  //                   child: TextFormField(
  //                     keyboardType: TextInputType.number,
  //                     inputFormatters: <TextInputFormatter>[
  //                       FilteringTextInputFormatter.digitsOnly,
  //                     ],
  //                     validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return AppContents.mobileloginsucess.tr;
  //                       }
  //                       else if(value.length!=10)
  //                       {
  //                         return AppContents.mobiletendigit.tr;
  //                       }
  //                       return null;
  //                     },
  //                     controller: _MobileController,
  //
  //                     autofocus: true,
  //                     decoration: InputDecoration(
  //                         contentPadding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
  //                         labelText: AppContents.mobileEmpty.tr,
  //                         hintStyle: TextStyle(color: Colors.grey[400]),
  //                         enabledBorder: OutlineInputBorder(
  //                           borderSide: const BorderSide(width: 1, color: Color.fromRGBO(143, 148, 251, 6)),
  //
  //                         ),
  //                         focusedBorder: OutlineInputBorder(
  //                           borderSide: const BorderSide(width: 1, color: Color.fromRGBO(143, 148, 251, 6)),
  //
  //                         )  ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, 'Cancel'),
  //             child:  Text(AppContents.cancel.toString().tr,style: TextStyle(
  //                 fontSize: 15,
  //                 color: Colors.red
  //             ),),
  //           ),
  //           TextButton(
  //             onPressed: () async{
  //             updateMobileNumber();
  //             } ,
  //             child:  Text(AppContents.ok.tr,style: TextStyle(
  //                 fontSize: 15,
  //                 color: Colors.green
  //             ),),
  //           ),
  //         ],
  //       ));
  // }
  // //----------------------------show language dialog------------------------------------------
  //
  // void showdialogLaguage(BuildContext context) {
  //   showModalBottomSheet<void>(
  //       context: context,
  //       backgroundColor: Colors.white,
  //       elevation: 10,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       builder: (BuildContext context)  {
  //         return Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Column(
  //             children: [
  //               Container(
  //                 margin: EdgeInsets.all(30),
  //                 child: Text(AppContents.Language.tr,
  //                   style: TextStyle(
  //                   fontSize: 19,
  //                   color: AppColors.textColorsBlack,
  //                   fontWeight: FontWeight.bold
  //                 ),
  //                 ),
  //               ),
  //               Divider(
  //                 height: 1,
  //                 color: AppColors.lightTextColorsBlack,
  //               ),
  //               Expanded(
  //                 child: ListView.separated(
  //                         physics: NeverScrollableScrollPhysics(),
  //                         scrollDirection: Axis.vertical,
  //                         shrinkWrap: true,
  //                         itemCount: languageitemList.length,
  //                         itemBuilder: (BuildContext context, int index) {
  //                           return ListTile(
  //                             onTap: () async{
  //                               language=languageitemList[index];
  //                               SharedPreferences prefrence=await SharedPreferences.getInstance();
  //
  //                               print("laguage"+language);
  //                               if(language!=""&& language!="null")
  //                               {
  //                                 if(language=="English")
  //                                 {
  //                                   print("laguage id "+language);
  //
  //                                   Get.updateLocale(Locale('en','us'));
  //                                   prefrence.setString("laguageValue", "English");
  //                                   Navigator.of(context).pop();
  //
  //                                 }
  //                                 else if(language=="Hindi")
  //                                 {
  //                                   print("laguage else ifs"+language);
  //                                   Get.updateLocale(Locale('hi','In'));
  //                                   prefrence.setString("laguageValue", "Hindi");
  //                                   Navigator.of(context).pop();
  //                                 }
  //                               }
  //                             },
  //                             title: Text(languageitemList[index],
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: AppColors.dartTextColorsBlack,
  //                                 fontWeight: FontWeight.bold
  //                             ),
  //                             ),
  //                           );
  //                           }, separatorBuilder: (BuildContext context, int index) {
  //                           return Divider(
  //                           height: 1,
  //                       color: AppColors.lightTextColorsBlack,
  //                 ); },),
  //               ),
  //
  //
  //             ],
  //           ),
  //         );
  // });
  // }


  void getValue()  async{
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
   language= sharedPreferences.getString("laguageValue")??"";
  }

}
