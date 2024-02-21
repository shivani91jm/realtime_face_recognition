import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:realtime_face_recognition/Constants/AppConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AttendencePageClass extends StatefulWidget {
  const AttendencePageClass({Key? key}) : super(key: key);
  @override
  State<AttendencePageClass> createState() => _AttendencePageClassState();
}

class _AttendencePageClassState extends State<AttendencePageClass> {


  bool _isLoading=false;
  var btn_color_visiblity=false;
  String? _currentAddress;

  DateTime _selectedTime = DateTime.now();
  var totalpresent="",totalabsent="",totalhalfday="",totalpaidleave="",totalpaidfine="",totalpaidovertime="";
  DateTime currentDate = DateTime.now();
  var nextDate="";
  bool isButtonEnabled = false;
  var staffjoiningdate="2023-06-01";
  var noaatendancelistFlag=false;
  var stafflistflag=false;
  int _state = 0;
  var puchOutFlag=false;

  var name="";
  var pandingApproval;


  var markAttendanceTotal;
  bool markattendanceStatus=false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown,]);
   // markAttendanceInfo.clear();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDateMethod();
  }
  @override
  Widget build(BuildContext context)
  {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown,]);
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Row(
                children: [
                  Text(AppContents.Attendance.tr,style: TextStyle(
                      color: Colors.white,
                      fontSize:17,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold),)
                ])
        ),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints)
        {
          return   SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child :
                  // _isLoading==false? ErrowDialogsss():
                  HomePage(),
                ),
              ],
            ),
          );
        }));
  }
  Widget ErrowDialogsss() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(90),
            height:50,
            width: 50,
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
  Widget staffListWidget() {
    return Column(
      children: [
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [

              Divider(
                height: 1,
                color: Colors.grey,
              ),
              //_buildMonthlyContrainer(),
            ],


        ),
      ],
    );
  }
  // -------------------------------------previous month or day staff list show------------------------------------------
  void getPreviousMonthData() {
    currentDate = currentDate.subtract(Duration(days: 1));
    nextDate = DateFormat('yyyy-MM-dd').format(currentDate);
    setState(() {
      isButtonEnabled=true;
      if(nextDate==staffjoiningdate)
      {
        setState(() {
          DateTime startDate = DateTime.parse(nextDate);
          print(startDate);
          currentDate=startDate;
          noaatendancelistFlag=true;

        });
      }
      else
      {
        setState(() {
          DateTime startDate = DateTime.parse(nextDate);
          print(startDate);
          currentDate=startDate;
          noaatendancelistFlag=false;
         // showStaffListData();
        });
      }
    });

    print("current date decrement"+currentDate.toString());

  }
  // ------------------------------next date according staff list show ---------------------------------------------
  void getCurrentMonthData() {
    currentDate = currentDate.add(Duration(days: 1));
    nextDate=DateFormat('yyyy-MM-dd').format(currentDate);
    print("current date incremnt"+currentDate.toString());
    var currentdatevalue= DateTime.now();
    var date= DateFormat('yyyy-MM-dd').format(currentdatevalue);
    if(nextDate==date)
    {
      setState(() {
        DateTime startDate = DateTime.parse(nextDate);
        print(startDate);
        currentDate=startDate;
        isButtonEnabled=false;
      //  showStaffListData();
      });
      print("condition match"+nextDate.toString()+"date"+date);
    }
    else
    {
      setState(() {
        DateTime startDate = DateTime.parse(nextDate);
        print(startDate);
        currentDate=startDate;
        isButtonEnabled=true;
        //showStaffListData();
      });
      print("condition not match"+nextDate+"date"+date);
    }
  }
  void currentDateMethod() {
    nextDate=currentDate.toString() ;
    DateFormat('yyyy-MM-dd').format(currentDate);
    DateTime startDate = DateTime.parse(nextDate);
    print(startDate);
  }
  Widget nodatastaffList() {
    return Center(
      child: Column(
        children: [
          Text("No attendance",style: TextStyle(
              color: Colors.black38,
              fontSize: 14.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }

  Widget  staffListAttendancePage() {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //--------------------------- present absent and half day--------------------------
                Row(
                  children: [
                    Container(
                      width: 92,
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:BorderRadius.circular(5),
                        border: Border.all(
                          width:1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppContents.Present.tr,style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),),
                            Text(""+totalpresent,style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 92,
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:BorderRadius.circular(5),
                        border: Border.all(
                          width:1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppContents.Absent.tr,style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),),
                            Text(""+totalabsent,style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 92,
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:BorderRadius.circular(5),
                        border: Border.all(
                          width:1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppContents.HalfDay.tr,style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),),
                            Text(""+totalhalfday,style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //--------------------paid leave find and overtime----------------------------------------
                Row(
                  children: [
                    Container(
                      width: 92,
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:BorderRadius.circular(5),
                        border: Border.all(
                          width:1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppContents.paidLeave.tr,style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),),
                            Text(""+totalpaidleave,style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 92,
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:BorderRadius.circular(5),
                        border: Border.all(
                          width:1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppContents.Fine.tr,style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),),
                            Text(""+totalpaidfine,style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 92,
                      margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:BorderRadius.circular(5),
                        border: Border.all(
                          width:1,
                          color: Colors.grey,
                          style: BorderStyle.solid,
                        ),),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppContents.Overtime.tr,style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),),
                            Text(""+totalpaidovertime,style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //---------------------------------------search staff-----------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async{

              },
              child: Container(
                width: 339,
                margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 12, 10, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppContents.searchstaff.tr,style: TextStyle(
                          color: Colors.black38,
                          fontSize: 14.0,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold),),
                      Icon(Icons.search,color: Colors.black38,)
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
        //-----------------------staff listing show  Container-------------------------------
        staffListWidget()
      ],
    );
  }

  Widget  HomePage() {
    return Column(
      children: [
        Card(
          elevation: 5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new IconButton(
                    icon: new Icon(Icons.arrow_back_ios,
                        color: Colors.black87),
                    onPressed: () async {
                      setState(() {
                        _isLoading=false;
                        getPreviousMonthData();
                      });
                    },
                  ),
                  Text(""+DateFormat('dd MMM, EEE').format(currentDate),
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold)
                  ),
                  new IconButton(
                    icon: new Icon(Icons.arrow_forward_ios,
                        color: isButtonEnabled == true ? Colors.black87 : Colors.black12),
                    onPressed: isButtonEnabled == true ? ()
                    async {
                      setState(() {
                        _isLoading=false;
                        getCurrentMonthData();
                      });

                    } : null,),
                ],
              ),
            ],
          ),
        ),
        //----------------------------------check staff create date according list show-------------------------------------------
        if(noaatendancelistFlag==true)...
        {
          nodatastaffList()
        }
        else...
        {
          staffListAttendancePage()
        }
      ],
    );
  }



}
