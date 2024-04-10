import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_face_recognition/Activity/AttendanceListDateWisePage.dart';
import 'package:realtime_face_recognition/Activity/SettingPage.dart';
import 'package:realtime_face_recognition/Activity/ShowStaffListPage.dart';
import 'package:realtime_face_recognition/Controller/BottomNavigationProvider.dart';
import 'package:realtime_face_recognition/ML/Recognition2.dart';
import 'package:realtime_face_recognition/Widgetsss/PageWidget.dart';
class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
 late Recognizer222 recognizer222;
  final List<Widget> _pages = [
    ShowStaffListPage(),
    AttendencePageClass(),
    SettingPage(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recognizer222=Recognizer222();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BottomNavigationProvider>(
        builder: (context, state, _) => _pages[state.selectedIndex],
      ),
      bottomNavigationBar: Consumer<BottomNavigationProvider>(
        builder: (context, state, _) => BottomNavigationBar(
          currentIndex: state.selectedIndex,
          onTap: (index) {
            Provider.of<BottomNavigationProvider>(context, listen: false).setIndex(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Staff List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'My Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Settings',
            ),
          ],
          selectedItemColor: Colors.blue,
        ),
      ),
    );
  }



}
