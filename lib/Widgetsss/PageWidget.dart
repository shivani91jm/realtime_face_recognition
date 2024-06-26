import 'package:flutter/material.dart';
class PageWidget extends StatelessWidget {
  final String title;
  PageWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title,
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }
}