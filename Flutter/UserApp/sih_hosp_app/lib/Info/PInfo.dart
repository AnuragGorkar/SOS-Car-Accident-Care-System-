import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sih_hackathon/Info/MInfo.dart';

int ii;

class PInfo extends StatefulWidget {
  PInfo(int i) {
    ii = i;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PInfo();
  }
}

class _PInfo extends State<PInfo> {
  var _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addController = TextEditingController();
  TextEditingController emergency1nController = TextEditingController();
  TextEditingController emergency2nController = TextEditingController();
  TextEditingController emergency3nController = TextEditingController();
  TextEditingController emergency1cController = TextEditingController();
  TextEditingController emergency2cController = TextEditingController();
  TextEditingController emergency3cController = TextEditingController();

  String name, contact, add, eme1n, eme1c, eme2n, eme2c, eme3n, eme3c;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _contactFocus = FocusNode();
  final FocusNode _addFocus = FocusNode();
  final FocusNode _eme1nFocus = FocusNode();
  final FocusNode _eme2nFocus = FocusNode();
  final FocusNode _eme3nFocus = FocusNode();
  final FocusNode _eme1cFocus = FocusNode();
  final FocusNode _eme2cFocus = FocusNode();
  final FocusNode _eme3cFocus = FocusNode();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;

  final CollectionReference User_UID = _firestore.collection("Users");

  bool flag;

  @override
  void initState() {
    flag = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Emergency Information', style: TextStyle(
        ),),
        backgroundColor: Colors.red.shade900,
      ),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                  child: Text(
                    'Personal Information',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, left: 5, right: 10),
                    child: Divider(
                      color: Colors.red.shade600,
                      thickness: 1.5,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 15, left: 10, right: 10),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _nameFocus,
                controller: nameController,
                onSaved: (value) {
                  name = value;
                },
                validator: (value) {
                  if (value.isEmpty) return 'This field cannot be empty!';
                  return null;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _nameFocus, _contactFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Full Name',
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
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
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
                focusNode: _contactFocus,
                controller: contactController,
                onSaved: (value) {
                  contact = value;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _contactFocus, _addFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Phone Number',
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
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                maxLines: null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.newline,
                focusNode: _addFocus,
                controller: addController,
                onSaved: (value) {
                  add = value;
                },
                validator: (value) {
                  if (value.isEmpty) return 'This field cannot be empty!';
                  return null;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _addFocus, _eme1nFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Address',
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
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 10),
                  child: Text(
                    'Emergency Information',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30, left: 5, right: 10),
                    child: Divider(
                      color: Colors.red.shade600,
                      thickness: 1.5,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10),
              child: Text(
                'Emergency Contact 1:',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _eme1nFocus,
                controller: emergency1nController,
                onSaved: (value) {
                  eme1n = value;
                },
                validator: (value) {
                  if (value.isEmpty) return 'This field cannot be empty!';
                  return null;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _eme1nFocus, _eme1cFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.black,),
                  hintText: 'Enter Name',
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
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
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
                focusNode: _eme1cFocus,
                controller: emergency1cController,
                onSaved: (value) {
                  eme1c = value;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _eme1cFocus, _eme2nFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.black,),
                  hintText: 'Enter Phone Number',
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
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10),
              child: Text(
                'Emergency Contact 2:',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _eme2nFocus,
                controller: emergency2nController,
                onSaved: (value) {
                  eme2n = value;
                },
                validator: (value) {
                  if (value.isEmpty) return 'This field cannot be empty!';
                  return null;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _eme2nFocus, _eme2cFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Name',
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
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
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
                focusNode: _eme2cFocus,
                controller: emergency2cController,
                onSaved: (value) {
                  eme2c = value;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _eme2cFocus, _eme3nFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Phone Number',
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
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 10),
              child: Text(
                'Emergency Contact 3(Optional):',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                focusNode: _eme3nFocus,
                controller: emergency3nController,
                onSaved: (value) {
                  eme3n = value;
                },
                validator: (value) {
                  if (emergency3cController.text.isNotEmpty && value.isEmpty)
                    return 'This field cannot be empty!';
                  return null;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _eme3nFocus, _eme3cFocus);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Name',
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
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: (String value) {
                  if (emergency3nController.text.isNotEmpty) {
                    if (value.isEmpty) return 'This field cannot be empty!';
                    if (value.length != 10) return 'Invalid Phone Number!';
                  }
                  if(value.isNotEmpty && value.length<10) return 'Invalid Phone Number!';
                  return null;
                },
                focusNode: _eme3cFocus,
                controller: emergency3cController,
                onSaved: (value) {
                  eme3c = value;
                },
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _eme3cFocus, null);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  hintText: 'Enter Phone Number',
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
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(30),
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
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          flag = true;
                        } else {
                          flag = false;
                        }
                      });
                      if (flag)
                        await pDetails(name, contact, add, eme1n, eme1c, eme2n,
                            eme2c, eme3n, eme3c);
                    },
                    child: !flag
                        ? Text('Next', style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500))
                        : CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors
                            .white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  pDetails(String name, String phone, String addr, String EC1N, String EC1C,
      String EC2N, String EC2C, String EC3N, String EC3C) async {
    FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
    Map data = new HashMap<String, String>();
    data.putIfAbsent('name', () => name);
    data.putIfAbsent('phone_no', () => phone);
    data.putIfAbsent('address', () => addr);
    data.putIfAbsent('EC1N', () => EC1N);
    data.putIfAbsent('EC1C', () => EC1C);
    data.putIfAbsent('EM2N', () => EC2N);
    data.putIfAbsent('EM2C', () => EC2C);
    if (EC3C != null) {
      data.putIfAbsent('EM3N', () => EC3N);
      data.putIfAbsent('EM3C', () => EC3C);
    }
    User_UID.document(_firebaseUser.uid).updateData(data).then((user) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MInfo(ii)));
    });
  }
}
