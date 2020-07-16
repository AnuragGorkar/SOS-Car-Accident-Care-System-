import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sih_hackathon/Auth/Login.dart';
import 'package:sih_hackathon/Info/CInfo.dart';
import 'package:sih_hackathon/Info/MInfo.dart';
import 'package:sih_hackathon/Info/PInfo.dart';

import 'Home.dart';

class Flash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Flash();
  }
}

class _Flash extends State<Flash> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;
  final CollectionReference User_UID = _firestore.collection("Users");

  Future<void> nav(BuildContext context) async {
    FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
    if (_firebaseUser == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return Login();
      }));
    } else {
      User_UID.document(_firebaseUser.uid).snapshots().listen((datasnapshot) {
        if(datasnapshot.data['SOS_ID']!=null) {
          if (datasnapshot.data.containsKey('name') &&
              datasnapshot.data.containsKey('bloodG') &&
              datasnapshot.data.containsKey('Car_Model')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return Home();
                }));
          } else if (datasnapshot.data.containsKey('name') &&
              datasnapshot.data.containsKey('bloodG')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return CInfo(1);
                }));
          } else if (datasnapshot.data.containsKey('name')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return MInfo(1);
                }));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return PInfo(1);
                }));
          }
        }
        else{
          if (datasnapshot.data.containsKey('name') &&
              datasnapshot.data.containsKey('bloodG') &&
              datasnapshot.data.containsKey('Car_Model')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return Home();
                }));
          } else if (datasnapshot.data.containsKey('name') &&
              datasnapshot.data.containsKey('bloodG')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return CInfo(0);
                }));
          } else if (datasnapshot.data.containsKey('name')) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return MInfo(0);
                }));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return PInfo(0);
                }));
          }
        }
      });
    }

  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SOS',
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 15,),
              CircularProgressIndicator()
            ],
          ),
        ));
  }

  Future<Null> startCountdown() async {
    const timeOut = const Duration(seconds: 2);
    new Timer(timeOut, () {
      nav(context);
    });
  }
}
