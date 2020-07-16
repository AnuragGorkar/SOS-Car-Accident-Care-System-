import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'Home.dart';

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUp();
  }
}

class _SignUp extends State<SignUp> {
  final _gloabKey= GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController repassController = TextEditingController();
  TextEditingController contact1Controller = TextEditingController();
  TextEditingController contact2Controller = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String name,mail, password, repassword,contact1,contact2,address;

  bool passwordVis, repasswordVis;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _mailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _repassFocus = FocusNode();
  final FocusNode _contact1Focus = FocusNode();
  final FocusNode _contact2Focus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;

  final CollectionReference User_UID = _firestore.collection("Hospitals");

  Position position;

  List<Placemark> placemark;

  Placemark location;

  bool flag,flag1;

  @override
  void initState() {
    flag = false;
    flag1=false;
    passwordVis = true;
    repasswordVis = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS Medical Care'),
      ),
      body: SingleChildScrollView(
          child: Form(
            key: _gloabKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty) return 'This field cannot be empty!';
                      return null;
                    },
                    focusNode: _nameFocus,
                    controller: nameController,
                    onSaved: (value) {
                      name = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _nameFocus, _mailFocus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.local_hospital,
                      ),
                      hintText: 'Enter Hospital\'s Name',
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
                      labelText: 'Hospital Name',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
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
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
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
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: TextFormField(
                    autocorrect: false,
                    obscureText: repasswordVis,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
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
                      _fieldFocusChange(context, _repassFocus, _contact1Focus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.enhanced_encryption,
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
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isEmpty) return 'This field cannot be empty!';
                      if (value.length != 10) return 'Invalid Phone Number!';
                      return null;
                    },
                    focusNode: _contact1Focus,
                    controller: contact1Controller,
                    onSaved: (value) {
                      contact1 = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _contact1Focus, _contact2Focus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.call,
                      ),
                      hintText: 'Enter Mobile Number',
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
                      labelText: 'Mobile Number',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (String value) {
                      if (value.isNotEmpty) {
                        if (value.length < 10) return 'Invalid Phone Number!';
                        if (value.length > 11) return 'Invalid Phone Number!';
                      }
                      return null;
                    },
                    focusNode: _contact2Focus,
                    controller: contact2Controller,
                    onSaved: (value) {
                      contact2 = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _contact2Focus, _addressFocus);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.call,
                      ),
                      hintText: 'Enter Telephone Number',
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
                      labelText: 'Telephone Number',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10,bottom: 2),
                  child: TextFormField(
                    onTap: () async {
                      setState(() {
                        flag1=true;
                      });
                      await getLocation();
                      addressController.text='${location.name},${location.subThoroughfare},${location.thoroughfare},\n${location.subLocality},\n${location.locality},\n${location.postalCode},\n${location.country}';
                      setState(() {
                        flag1=false;
                      });
                    },
                    maxLines: null,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: (String value) {
                      if (value.isEmpty) return 'This field cannot be empty!';
                      return null;
                    },
                    focusNode: _addressFocus,
                    controller: addressController,
                    onSaved: (value) {
                      address = value;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _addressFocus, null);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on,
                      ),
                      suffixIcon: flag1?Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(),
                            height: 20,
                            width: 20,
                          ),
                        ],
                      ):Padding(
                        padding: EdgeInsets.only(bottom: 0.3,left: 1),
                        child: Icon(
                          Icons.my_location,
                        ),
                      ),
                      hintText: 'Please Turn On Location',
                      hintStyle: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
                      labelText: 'Address',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Container(
                    height: 50,
                    child: RaisedButton(
                      onPressed: () async {
                        setState(() {
                          flag = true;
                        });
                        setState(() {
                          if (_gloabKey.currentState.validate()) {
                            _gloabKey.currentState.save();
                            flag = true;
                          }
                          else {
                            passController.clear();
                            flag = false;
                          }
                        });
                        if (flag){
                          await Sign_Up(mail, password);
                        }
                      },
                      child: !flag
                          ? Text('Sign Up')
                          : CircularProgressIndicator(),
                    ),
                  ),
                ),
              ],
            ),
          )),
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

  getLocation() async {
    position=await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    placemark=await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    location=placemark[0];
  }
  Sign_Up(String mail, String password) async {
    bool flag1 = true;
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: mail, password: password).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      _firebaseAuth.signOut();
      setState(() {
        flag = false;
      });
      flag1 = false;
    });
    if (flag1) {
      FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
      Map data = new HashMap<String, String>();
      data.putIfAbsent('E-Mail', () => mail);
      data.putIfAbsent('Name_Hosp', () => name);
      data.putIfAbsent('Con1_Hosp', () => contact1);
      if(contact2.isNotEmpty)
        data.putIfAbsent('Con2_Hosp', () => contact2);
      data.putIfAbsent('location', () => addressController.text);
      data.putIfAbsent('longi', () => position.longitude.toString());
      data.putIfAbsent('lati', () => position.latitude.toString());
      data.putIfAbsent('city', ()=>location.locality);

      User_UID
          .document(_firebaseUser.uid)
          .setData(data)
          .then((user) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }
}


