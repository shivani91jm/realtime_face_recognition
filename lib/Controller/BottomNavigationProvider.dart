import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BottomNavigationProvider with ChangeNotifier{
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}