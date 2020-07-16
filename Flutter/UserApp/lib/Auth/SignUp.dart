import 'dart:collection';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sih_hackathon/Auth/Login.dart';
import 'package:sih_hackathon/Info/PInfo.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUp();
  }
}

class _SignUp extends State<SignUp> {
  final _mailKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();
  final _repassKey = GlobalKey<FormState>();
  final _IDKey = GlobalKey<FormState>();


  TextEditingController mailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repassController = TextEditingController();
  TextEditingController IDController = TextEditingController();

  String mail, password, repassword, SOS_ID;

  bool passwordVis, repasswordVis;

  final FocusNode _mailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _repassFocus = FocusNode();
  final FocusNode _IDFocus = FocusNode();


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;

  final CollectionReference SOS_UID = _firestore.collection("SOS");
  final CollectionReference User_UID = _firestore.collection("Users");

  bool result, flag;

  int i;


  @override
  void initState() {
    i = 1;
    result = false;
    flag = false;
    passwordVis = true;
    repasswordVis = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
//      backgroundColor: Colors.black,
//      appBar: AppBar(
//        title: Text('SOS'),
//        backgroundColor: Colors.red.shade900,
//      ),
      body: SafeArea(
        child: Center(
            child: SingleChildScrollView(
              child: CardB(),)
        ),
      ),
    );
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus,
      FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  bool isEmailValid(String email) {
    return EmailValidator.validate(email);
  }

  bool isPasswordValid(String password) {
    return password.length > 6;
  }

  Future<bool> isIDValid(String UID) async {
    if (i==0)
      return true;
    if (UID.isEmpty && i==1)
      return false;
    var snapshot = await SOS_UID.document(UID).get();
    return snapshot.exists;
  }

  Future _scanQR() async {
    String result = '';
    try {
      result = await BarcodeScanner.scan();
      setState(() {
        IDController.text = result;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Fluttertoast.showToast(msg: 'Camera permission was denied!',
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIos: 2);
      }
      else
        Fluttertoast.showToast(msg: 'Unknown Error: $e',
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIos: 2);
    } on FormatException {
      Fluttertoast.showToast(
          msg: 'You pressed the back button before scanning anything!',
          toastLength: Toast.LENGTH_LONG, timeInSecForIos: 2);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Unknown Error: $e',
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2);
    }
  }

  Sign_Up(String mail, String password) async {
    bool flag1 = true;
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: mail, password: password).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e.toString());
      _firebaseAuth.signOut();
      setState(() {
        flag = false;
      });
      flag1 = false;
    });
    if (flag1) {
      FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
      FirebaseMessaging message=new FirebaseMessaging();
      var token = await message.getToken();
      List<String> list;
      Map data1 = new HashMap<String, List<String>>();
      Map data2= new HashMap<String, bool>();
      Map data3= new HashMap<String, double>();
      if (SOS_ID != null) {
        Firestore.instance.collection('SOS').document(SOS_ID).get().then((
            documentSS) {
          if (documentSS.exists)
            if (documentSS['users'] != null)
              list = List.from(documentSS['users']);
            else
              list = [];
          list.add(_firebaseUser.uid);
          data1.putIfAbsent('users', () => list);
          data2.putIfAbsent('getLocation', () => false);
          data3.putIfAbsent('Longitude', () => null);
          data3.putIfAbsent('Latitude', () => null);
          Firestore.instance.collection('SOS').document(SOS_ID).updateData(
              data1);
          Firestore.instance.collection('SOS').document(SOS_ID).updateData(
              data2);
          Firestore.instance.collection('SOS').document(SOS_ID).updateData(
              data3);
        });
      }
      Map data = new HashMap<String, String>();
      data.putIfAbsent('E-Mail', () => mail);
      if (SOS_ID != null)
        data.putIfAbsent('SOS_ID', () => SOS_ID);
      else
        data.putIfAbsent('SOS_ID', () => null);
      data.putIfAbsent('Token', () => token);
      User_UID
          .document(_firebaseUser.uid)
          .setData(data)
          .then((user) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PInfo(i)));
      });

    }
  }

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
                padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Form(
                  key: _mailKey,
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty) return 'This field cannot be empty!';
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.green.shade600, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      labelText: 'E-Mail',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
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
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'This field cannot be empty!';
                      }
                      if (!isPasswordValid(value)) {
                        return 'Password must be more than 6 characters!';
                      }
                      return null;
                    },
                    focusNode: _passFocus,
                    controller: passController,
                    onSaved: (value) {
                      password = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _passFocus, _repassFocus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.enhanced_encryption,
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVis ? Icons.visibility_off : Icons.visibility,
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
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.green.shade600, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                child: Form(
                  key: _repassKey,
                  child: TextFormField(
                    autocorrect: false,
                    obscureText: repasswordVis,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty) return 'This field cannot be empty!';
                      if ((passController.text).compareTo(
                          repassController.text) !=
                          0) return 'Password must be same!';
                      return null;
                    },
                    focusNode: _repassFocus,
                    controller: repassController,
                    onSaved: (value) {
                      repassword = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _repassFocus, _IDFocus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.enhanced_encryption,
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          repasswordVis ? Icons.visibility_off : Icons
                              .visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            repasswordVis = !repasswordVis;
                          });
                        },
                      ),
                      hintText: 'Re-Enter Password',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.green.shade600, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Row(
                  children: <Widget>[
                    Text('Have a Car?',
                      style: TextStyle(
                          fontSize: 20
                      ),),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Radio(groupValue: i, onChanged: (val) {
                        setState(() {
                          i = 1;
                        });
                      }, value: 1,),
                    ),
                    Text('Yes', style: TextStyle(
                        fontSize: 20
                    ),),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Radio(groupValue: i, onChanged: (val) {
                        setState(() {
                          i = 0;
                        });
                      }, value: 0,),
                    ),
                    Text('No', style: TextStyle(
                        fontSize: 20
                    ),),
                  ],
                ),
              ), i == 1 ?
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Form(
                  key: _IDKey,
                  child: TextFormField(
                    maxLines: null,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: (String value) {
                        if (value.isEmpty) return 'This field cannot be empty!';
                        if (value.isNotEmpty)
                          if (!result) return 'Invalid QR Code';
                      return null;
                    },
                    focusNode: _IDFocus,
                    controller: IDController,
                    onSaved: (value) {
                      SOS_ID = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _IDFocus, null);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.directions_car,
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        iconSize: 40,
                        icon: Image.asset('images/qr.jpg',
                        ),
                        onPressed: () {
                          setState(() {
                            _scanQR();
                          });
                        },
                      ),
                      hintText: 'Scan QR',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.green.shade600, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      labelText: 'SOS ID',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
              ) : SizedBox(
                height: 0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.red.shade700,
                    elevation: 5,
                    onPressed: () async {
                      setState(() {
                        flag = true;
                      });
                      result = await isIDValid(IDController.text);
                      setState(() {
                        if (_mailKey.currentState.validate() &&
                            _passKey.currentState.validate() &&
                            _repassKey.currentState.validate() &&
                            ((i==1 && _IDKey.currentState.validate())||(i==0)) &&
                            result) {
                          _mailKey.currentState.save();
                          _passKey.currentState.save();
                          _repassKey.currentState.save();
                          if(i==1)
                          _IDKey.currentState.save();
                          flag = true;
                        }
                        else {
                          if (!_mailKey.currentState.validate()) {
                            mailController.clear();
                            passController.clear();
                            repassController.clear();
                            IDController.clear();
                            passwordVis = true;
                            repasswordVis = true;
                            flag = false;
                          }
                          if (!_passKey.currentState.validate()) {
                            passController.clear();
                            repassController.clear();
                            passwordVis = true;
                            repasswordVis = true;
                            flag = false;
                          }
                          if (!_repassKey.currentState.validate()) {
                            repassController.clear();
                            passwordVis = true;
                            repasswordVis = true;
                            flag = false;
                          }
                          if (!_IDKey.currentState.validate() && !result) {
                            IDController.clear();
                            flag = false;
                          }
                        }
                      });
                      if (flag)
                        await Sign_Up(mail, password);
                    },
                    child: !flag
                        ? Text('Sign Up', style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500
                    ),)
                        : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 30),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: RaisedButton(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('Already Registered? Log In', style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                              return Login();
                            }));
                      }),
                ),
              )
            ],
          )),
    );
  }

}


