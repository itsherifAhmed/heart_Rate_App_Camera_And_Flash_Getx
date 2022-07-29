import 'package:flutter/material.dart';
import 'package:heartrate/view/screens/HomeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPG',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: HomeScreen(),
    );
  }
}
