import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sih_hackathon/Screens/Home.dart';

int ii;
class CInfo extends StatefulWidget {
  CInfo(int i) {
    ii = i;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CInfo();
  }
}

class _CInfo extends State<CInfo> {
  var _formKey = GlobalKey<FormState>();

  TextEditingController cMController = TextEditingController();
  TextEditingController cNController = TextEditingController();
  TextEditingController cCController = TextEditingController();
  TextEditingController cSController = TextEditingController();
  TextEditingController idenController = TextEditingController();

  String cM, cN, cC, cS, iden,photo;

  final FocusNode _cMFocus = FocusNode();
  final FocusNode _cNFocus = FocusNode();
  final FocusNode _cCFocus = FocusNode();
  final FocusNode _cSFocus = FocusNode();
  final FocusNode _idenFocus = FocusNode();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;

  final CollectionReference User_UID = _firestore.collection("Users");

  bool flag;

  File _image;


  Future getImagefromCam(File file) async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera);
    setState(() {
      if (image == null)
        _image = file;
      else
        _image = image;
    });
  }

  Future getImagefromGal(File file) async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,);
    setState(() {
      if (image == null)
        _image = file;
      else
        _image = image;
    });
  }

  @override
  initState() {
    _image = null;
    flag = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Information', style: TextStyle(
        ),),
        backgroundColor: Colors.red.shade900,
      ),
      body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ii == 1 ? Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 10),
                          child: Text(
                            'Vehicle Information',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 20, left: 5, right: 10),
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
                        focusNode: _cMFocus,
                        controller: cMController,
                        onSaved: (value) {
                          cM = value;
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'This field cannot be empty!';
                          return null;
                        },
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _cMFocus, _cNFocus);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.directions_car,
                            color: Colors.black,
                          ),
                          hintText: 'For example, Mahindra XUV300',
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
                          labelText: 'Car Model',
                          labelStyle: TextStyle(
                              color: Colors.black, fontSize: 18),
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
                        validator: (String value) {
                          if (value.isEmpty)
                            return 'This field cannot be empty!';
                          return null;
                        },
                        focusNode: _cNFocus,
                        controller: cNController,
                        onSaved: (value) {
                          cN = value;
                        },
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _cNFocus, _cCFocus);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.crop_16_9,
                            color: Colors.black,
                          ),
                          hintText: 'For example, MH01AE8017',
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
                          labelText: 'Car Number',
                          labelStyle: TextStyle(
                              color: Colors.black, fontSize: 18),
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
                        focusNode: _cCFocus,
                        controller: cCController,
                        onSaved: (value) {
                          cC = value;
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'This field cannot be empty!';
                          return null;
                        },
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _cCFocus, _cSFocus);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.color_lens,
                            color: Colors.black,
                          ),
                          hintText: 'For example, Red',
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
                          labelText: 'Car Color',
                          labelStyle: TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                          top: 10, left: 10, right: 10, bottom: 20),
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        focusNode: _cSFocus,
                        controller: cSController,
                        onSaved: (value) {
                          cS = value;
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'This field cannot be empty!';
                          return null;
                        },
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(
                              context, _cSFocus, null);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.airline_seat_recline_normal,
                            color: Colors.black,
                          ),
                          hintText: 'For example, 6',
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
                          labelText: 'Number of Seats',
                          labelStyle: TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ) : SizedBox(
                  height: 0,
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        'Identification',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, left: 5, right: 10),
                        child: Divider(
                          color: Colors.red.shade600,
                          thickness: 1.5,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 40,
                        child: Text(
                          'This section is to identify whether the Accident Victim is someone else.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: TextFormField(
                    maxLines: null,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.newline,
                    focusNode: _idenFocus,
                    controller: idenController,
                    onSaved: (value) {
                      iden = value;
                    },
                    validator: (value) {
                      return null;
                    },
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _idenFocus, null);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      hintText: 'For example, Tattoo on back',
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
                      labelText: 'Identification Mark',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 10),
            child: Text(
              'Facial Recognition',
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
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Icon(
              Icons.info_outline,
              color: Colors.grey.shade500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 40,
              child: Text(
                'This section is to identify whether the Accident Victim is someone else.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Center(
          child: Container(
              child: FlatButton(
                onPressed: () {
                  _showD(context);
                },
                child: _image == null ? Icon(Icons.face,
                color: Colors.grey.shade500,
                size: 150,) : FittedBox(
              child: Image.file(_image), fit: BoxFit.cover,),
      ),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey.shade500,
              width: 3
          )
      ),
    ),
    ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
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
                            await pDetails(cM, cN, cC, cS, iden, _image);
                        },
                        child: !flag
                            ? Text('Done', style: TextStyle(
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

  pDetails(String carM, String carN, String carC, String carS,
      String IM, File file) async {
    FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
    Map data = new HashMap<String, String>();
    data.putIfAbsent('Car_Model', () => carM);
    data.putIfAbsent('Car_Number', () => carN);
    data.putIfAbsent('Car_Color', () => carC);
    data.putIfAbsent('Car_Seater', () => carS);
    if (IM.isNotEmpty)
      data.putIfAbsent('Identification', () => IM);
    else
      data.putIfAbsent('Identification', () => 'None');
    if (file != null) {
      await uploadFile(file);
      data.putIfAbsent('profilePath', () => photo);
    }
    User_UID.document(_firebaseUser.uid).updateData(data).then((user) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    });
  }


  Future uploadFile(File file) async {
    FirebaseUser _firebaseUser = await _firebaseAuth.currentUser();
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('Users/${_firebaseUser.uid}');
    StorageUploadTask uploadTask = storageReference.putFile(file);
    var downURL=await (await uploadTask.onComplete).ref.getDownloadURL();
    photo=downURL.toString();
  }

  Future<void> _showD(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context)
    {
      return AlertDialog(
        title: Text('Photo'),
        titlePadding: EdgeInsets.only(left: 24,right: 24,top: 24),
        actions: <Widget>[
          Column(
            children: <Widget>[
          Container(
            padding:EdgeInsets.only(left: 0),
            width: 300,
            height: 50,
            child: ListTile(
              leading: Icon(Icons.camera_enhance),
              title: Text('Camera'),
              onTap: () {
                getImagefromCam(_image);
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            width: 300,
            height: 50,
            child: ListTile(
              leading: Icon(Icons.image),
              title: Text('Gallery'),
              onTap: () {
                getImagefromGal(_image);
                Navigator.pop(context);
              },
            ),
          ),
          _image==null?SizedBox(height: 0,):
          Container(
            width: 300,
            height: 50,
            child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove'),
                onTap: () {
                  setState(() {
                    _image = null;
                  });
                  Navigator.pop(context);
                }
            ),
          )
            ],
          )
        ],
      );
    });
  }
}
