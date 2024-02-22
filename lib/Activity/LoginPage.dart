import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:realtime_face_recognition/Controller/LoginController.dart';
import 'package:realtime_face_recognition/Utils/AppFontFamily.dart';
import 'package:realtime_face_recognition/Utils/Appcolors.dart';
import 'package:realtime_face_recognition/Widgetsss/CustomButton.dart';
import 'package:realtime_face_recognition/Widgetsss/PasswordTextEditWidget.dart';
import 'package:realtime_face_recognition/Widgetsss/TextInputFields.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  final LoginController controller =Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //---------logo--------------
              Container(
                margin: EdgeInsets.fromLTRB(0, 40, 10, 10),
                height: 80,
                child: Image.asset("assets/images/logo_b.png",),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(25.0,0,0,0),
                child: Text("...........................................",
                  style:AppFontFamilyClass.regular
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(25.0,0,0,0),
                child: Row(
                  children: [
                    Text("Welcome Back",
                      style: AppFontFamilyClass.regular,
                    ),
                    Icon(Icons.waving_hand_sharp,color: Colors.yellow,)
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(25.0,0,0,0),
                child: Row(
                  children: [
                    Text("to",
                      style: AppFontFamilyClass.regular),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("HR Attendance",
                        style: AppFontFamilyClass.bluebold),
                    )
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(25.0,0,0,0),
                child: Text("Hello there, login to continue",
                  style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    fontFamily: "Lexend"

                  ),),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextInputFields(
                        enable: true,
                        controller: emailController,
                        hintText: AppContents.email,
                        labelText:  AppContents.email, isHint: false,
                        nmber: TextInputType.emailAddress,
                        bordercolors: Colors.blue,
                        textcolors:Colors.blue,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter email / username';
                          }
                          else if(!value.contains("@")){
                            return "Enter valid email";
                          }
                          else{
                            return null;
                          }
                        },),
                      SizedBox(
                        height: 20,
                      ),
                      PasswordTextEditWidget(
                        enable: true,
                        loginController: controller,
                        controller: passwordController,
                        hintText: AppContents.Password,
                        labelText:  AppContents.Password,
                        isHint: true.obs,
                        nmber: TextInputType.visiblePassword,
                        bordercolors:Colors.blue,
                        textcolors: Colors.blue, validator: (value ) {
                        if (value.toString().length < 3) {
                          return 'Password should be longer or equal to 3 characters'.tr;
                        } else {
                          return null;
                        }
                      },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Obx(() =>  CustomButton(
                        onPressed: () {
                          if(formKey.currentState!.validate()){
                            var email=emailController.text;
                            var password=passwordController.text;
                            controller.login(email,password,context);
                          }

                        }, title: controller.isLoading2.value?"Login": "Login",
                        colors: Colors.blue,
                        isLoading: controller.isLoading2,
                      ),),
                      GestureDetector(
                        onTap: () async {
                         // Navigator.pushNamed(context, RouteNames.forget_screen);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("Forget Password ?",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Lexend",
                              ),),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Container(
                            width: 150,
                            child: Divider(
                              height: 2,

                              thickness: 1,

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Or",
                              style: TextStyle(

                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Lexend",
                                  fontSize: 18
                              ),),
                          ),
                          Expanded(
                            child: Container(
                              width: 150,
                              child: Divider(
                                height: 2,
                                color:Colors.grey,
                                thickness: 1,


                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50,),
                      Container(
                        height: 50,
                        decoration:  BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey ,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: (){
                            // GoogleSinginClass.signup(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                    height: 20,
                                    width: 20,
                                    "assets/images/google.png"
                                ),
                                Padding(
                                  padding:  EdgeInsets.fromLTRB(15.0,0,0,0),
                                  child: Text("Google",
                                  style: TextStyle(

                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Lexend",
                                      fontSize: 18
                                  ),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                         // Navigator.pushNamed(context!,RouteNames.registration_screen);
                        },
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:  const EdgeInsets.fromLTRB(8,8.0,3.0,8.0),
                                child: Text("Don't have an account",style: TextStyle(
                                    color: Colors.black38,
                                    fontFamily: "Lexend",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,8.0,8.0,8.0),
                                child: Text("SingUp",style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: "Lexend",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),

                    ],
                  ),
                ),
              )
          
            ],
          ),
        ),
      ),
    );
  }
}
