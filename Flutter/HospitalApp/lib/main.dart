import 'package:flutter/material.dart';

import 'SignUp.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SOS Medical Care",
      home: SignUp(),
    );
  }
}
