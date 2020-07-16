import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sih_hackathon/Auth/SignUp.dart';
import 'package:sih_hackathon/Info/CInfo.dart';
import 'package:sih_hackathon/Info/MInfo.dart';
import 'package:sih_hackathon/Info/PInfo.dart';
import 'package:sih_hackathon/Screens/Home.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Login();
  }
}

class _Login extends State<Login> {
  final _mailKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();

  TextEditingController mailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  String mail, password;

  bool passwordVis;

  final FocusNode _mailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;

  final CollectionReference User_UID = _firestore.collection("Users");

  bool flag;

  @override
  void initState() {
    flag = false;
    passwordVis = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.red.shade700,
//      appBar: AppBar(
//        title: Text('SOS'),
//        backgroundColor: Colors.red.shade900,
//      ),
          body: Center(
            child: SingleChildScrollView(
              child: CardB(),
            ),
          )
      ),
    );
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool isEmailValid(String email) {
    return EmailValidator.validate(email);
  }

  bool isPasswordValid(String password) {
    return password.length > 6;
  }

  Sign_In(String mail, String password) async {
    await _firebaseAuth
        .signInWithEmailAndPassword(email: mail, password: password)
        .then((authResult) async {
      FirebaseUser user = await _firebaseAuth.currentUser();
      FirebaseMessaging message = new FirebaseMessaging();
      var token = await message.getToken();
      Map data = new HashMap<String, String>();
      data.putIfAbsent('Token', () => token);
      Firestore.instance.collection('Users')
          .document(user.uid)
          .updateData(data);
      nav(context);
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      _firebaseAuth.signOut();
      setState(() {
        flag = false;
      });
    });
  }

  Future<void> nav(BuildContext context) async {
    FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
    User_UID.document(_firebaseUser.uid).snapshots().listen((datasnapshot) {
      if (datasnapshot.data['SOS_ID'] != null) {
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
      else {
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

//  Widget CardBVirtual() {
//    return Container(
//      width: MediaQuery.of(context).size.width-150,
//      height: 60,
//      padding: EdgeInsets.only(right: 10, left: 10),
//      child: Card(
//        elevation: 15,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.circular(20),
//        ),
//      ),
//    );
//  }

  Widget CardB() {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 10),
      child: Card(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Image(
                  image: AssetImage('images/SOS.png'),
                  filterQuality: FilterQuality.high,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Form(
                  key: _mailKey,
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty)
                        return 'This field cannot be empty!';
                      if (!isEmailValid(value)) return 'Invalid E-Mail!';
                      return null;
                    },
                    focusNode: _mailFocus,
                    controller: mailController,
                    onSaved: (value) {
                      mail = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _mailFocus, _passFocus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.mail,
                        color: Colors.black,
                      ),
                      hintText: 'Enter E-Mail',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(
                            color: Colors.green.shade600, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.0),
                      ),
                      labelText: 'E-Mail',
                      labelStyle: TextStyle(color: Colors.black,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Form(
                  key: _passKey,
                  child: TextFormField(
                    autocorrect: false,
                    obscureText: passwordVis,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    validator: (String value) {
                      if (value.isEmpty)
                        return 'This field cannot be empty!';
                      return null;
                    },
                    focusNode: _passFocus,
                    controller: passController,
                    onSaved: (value) {
                      password = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _passFocus, null);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.enhanced_encryption,
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVis ? Icons.visibility_off : Icons
                              .visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVis = !passwordVis;
                          });
                        },
                      ),
                      hintText: 'Enter Password',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(
                            color: Colors.green.shade600, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.0),
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: RaisedButton(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.red.shade700,
                    onPressed: () async {
                      setState(() {
                        flag = true;
                      });
                      setState(() {
                        if (_mailKey.currentState.validate() &&
                            _passKey.currentState.validate()) {
                          _mailKey.currentState.save();
                          _passKey.currentState.save();
                          flag = true;
                        } else {
                          if (!_mailKey.currentState.validate()) {
                            mailController.clear();
                            passController.clear();
                            passwordVis = true;
                            flag = false;
                          }
                          if (!_passKey.currentState.validate()) {
                            passController.clear();
                            passwordVis = true;
                            flag = false;
                          }
                        }
                      });
                      if (flag) await Sign_In(mail, password);
                    },
                    child: !flag ? Text('Log In', style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500
                    ),) : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors
                          .white),),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Not Registered? Sign Up', style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return SignUp();
                                }));
                      }),
                ),
              )
            ],
          )
      ),
    );
  }
}

