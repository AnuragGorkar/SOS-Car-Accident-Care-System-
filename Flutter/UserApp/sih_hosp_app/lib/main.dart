import 'package:flutter/material.dart';
import 'package:sih_hackathon/Screens/Flash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Navigation",
      home: Flash(),
    );
  }
}
