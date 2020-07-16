import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:sih_hackathon/Auth/Login.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Home();
  }
}

class _Home extends State<Home>{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;

  final CollectionReference accident = _firestore.collection("accident");
  final CollectionReference SOS_UID = _firestore.collection("SOS");
  final CollectionReference User_UID = _firestore.collection("Users");


  final FirebaseMessaging _fcm = FirebaseMessaging();

  FirebaseUser user;
  String UID;

  double long, lat;

  List<String> list = [];
  List<String> list1 = [];
  List<String> list2 = [];
  List<String> list3 = [];

  List<Placemark> placemark;

  Placemark location;

  bool flag, flag1, flag2, flag3, temp, temp1, qrFlag, qrFlag2;

  String result, SOS_ID;

  String localFilePath;

  static AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = new AudioCache(fixedPlayer: audioPlayer);

  play() {
    temp = true;
    audioCache.loop('ring.mp3', stayAwake: true, isNotification: true);
  }

  stop() {
    audioPlayer.stop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    qrFlag = false;
    qrFlag2 = true;
    temp = false;
    result = '';
    temp1 = true;
    flag = false;
    flag1 = false;
    flag2 = false;
    flag3 = false;
    getUID().then((user1) {
      UID = user1.uid;
    });
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
    );
    _fcm.requestNotificationPermissions(IosNotificationSettings());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('SOS',style: TextStyle(
            fontSize: 26
        ),),
        backgroundColor: Colors.red.shade900,
        actions: <Widget>[
          IconButton(
            icon: Image.asset('images/logout.png',color: Colors.white),
            tooltip: 'Log Out',
            onPressed: () async {
              Map data = new HashMap<String, String>();
              data.putIfAbsent('Token', () => "");
              Firestore.instance.collection('Users')
                  .document(user.uid)
                  .updateData(data);
              if (temp1)
                stop();
              setState(() {
                temp1 = false;
              });
              await _firebaseAuth.signOut().then((user) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Login();
                        }));
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: accident.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data == null) return CircularProgressIndicator();
                return new Column(
                  children: snapshot.data.documents.map((
                      DocumentSnapshot document) {
                    if (document.exists) {
                      if (document['users'] != null) {
                        list = List<String>.from(document['users']);
                        if (list.contains(UID)) {
                          if (document['flag'] == true) {
                            long = document['Longitude'];
                            lat = document['Latitude'];
                            if (temp1)
                              play();
                            return cardB();
                          }
                          else {
                            if (temp) {
                              stop();
                              temp = false;
                              temp1 = true;
                            }
                          }
                        }
                      }
                    }
                    return SizedBox(
                      height: 0,
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(
              height: 40,
            ),
            Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: RaisedButton(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text('Find My Car', style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500
                        ),),
                        onPressed: () async {
                          setState(() {
                            flag2 = true;
                          });
                          await getCoordinates();
                        }),
                  ),
                )
            ),
            SizedBox(
              height: 20,
            ),
            flag2 ? CircularProgressIndicator() : SizedBox(height: 0),
            flag1 ?
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 40,
              alignment: Alignment.center,
              child: SelectableText(
                'Location: ${location.name}, ${location
                    .subThoroughfare}, ${location
                    .thoroughfare}, ${location.subLocality}, ${location
                    .locality}, ${location.postalCode}, ${location.country}',
                style: TextStyle(
                    color: Colors.black
                ),
              ),
            ) :
            SizedBox(
              height: 0,
            ),
            flag1 ?
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 130,
                child: RaisedButton(
                  onPressed: () async {
                    if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.google,
                        coords: Coords(lat, long),
                        title: 'Find my Car',
                        description: 'Your car is here!',
                      );
                    }
                    else if (await MapLauncher.isMapAvailable(MapType.apple)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.apple,
                        coords: Coords(lat, long),
                        title: 'Find my Car',
                        description: 'Your car is here!',
                      );
                    }
                    else {
                      final availableMaps = await MapLauncher.installedMaps;
                      await availableMaps.first.showMarker(
                        coords: Coords(lat, long),
                        title: "Find my Car",
                        description: "Your car is here!",
                      );
                    }
                  },
                  child: Text('Navigate', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                  ),),
                ),
              ),
            ) :
            SizedBox(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: RaisedButton(elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ), onPressed: () {
                    setState(() {
                      qrFlag2 = false;
                    });
                    User_UID.document(UID).get().then((documentSS) {
                      if (documentSS.exists) {
                        if (documentSS['SOS_ID'] != null) {
                          SOS_ID = documentSS['SOS_ID'];
                          Map data1 = new HashMap<String, List<String>>();
                          Firestore.instance
                              .collection('SOS')
                              .document(SOS_ID)
                              .get()
                              .then((documentSS) {
                            if (documentSS.exists)
                              list1 = [];
                            list1.add(UID);
                            data1.putIfAbsent('Trip', () => list1);
                            Firestore.instance
                                .collection('SOS')
                                .document(SOS_ID)
                                .updateData(
                                data1).then((val) {
                              Fluttertoast.showToast(
                                  msg: 'Successfully Started!');
                              setState(() {
                                qrFlag = true;
                                qrFlag2=true;
                              });
                            });
                          });
                        }
                        else {
                          Fluttertoast.showToast(msg: 'Can\'t Start a Trip!');
                        }
                      }
                    });
                  },
                  child: qrFlag2 ? Text('Start Trip', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                  ),):CircularProgressIndicator(),

                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            qrFlag ? QrImage(
              data: UID,
              size: 200,
              version: QrVersions.auto,
            ) : SizedBox(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 18, left: 8, right: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: RaisedButton(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ), onPressed: () async {
                  await _scanQR();
                  bool val = await isIDValid(result);
                  if (val == false)
                    Fluttertoast.showToast(msg: 'Can\'t Join');
                  else {
                    User_UID.document(result).get().then((documentSS) {
                      if (documentSS.exists) {
                        if (documentSS['SOS_ID'] != null) {
                          SOS_ID = documentSS['SOS_ID'];
                          Map data1 = new HashMap<String, List<String>>();
                          SOS_UID
                              .document(SOS_ID)
                              .get()
                              .then((documentSS) {
                            if (documentSS.exists)
                              if (documentSS['Trip'] != null) {
                                list2 = List.from(documentSS['Trip']);
                                if (!list2.contains(UID)) {
                                  list2.add(UID);
                                  data1.putIfAbsent('Trip', () => list2);
                                  Firestore.instance
                                      .collection('SOS')
                                      .document(SOS_ID)
                                      .updateData(
                                      data1).then((val) {
                                    Fluttertoast.showToast(
                                        msg: 'Successfully Joined');
                                  });
                                }
                                else {
                                  Fluttertoast.showToast(
                                      msg: 'Already in the Trip!');
                                }
                              }
                              else {
                                Fluttertoast.showToast(
                                    msg: 'Create Trip Again!');
                                return;
                              }
                          });
                        }
                        else {
                          Fluttertoast.showToast(msg: 'Can\'t Join This Trip!');
                        }
                      }
                    });
                  }
                },
                  child: Text('Join Trip', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                  ),),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8, top: 8, bottom: 30),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: RaisedButton(elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  onPressed: () {
                    User_UID.document(UID).get().then((documentSS) {
                      if (documentSS.exists) {
                        if (documentSS['SOS_ID'] != null) {
                          SOS_ID = documentSS['SOS_ID'];
                          Map data1 = new HashMap<String, List<String>>();
                          Firestore.instance
                              .collection('SOS')
                              .document(SOS_ID)
                              .get()
                              .then((documentSS) {
                            if (documentSS.exists) {
                              list3 = List.from(documentSS['Trip']);
                              if (list3.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: 'First Start a Trip!');
                                return;
                              }
                              list3 = [];
                              data1.putIfAbsent('Trip', () => list3);
                              Firestore.instance
                                  .collection('SOS')
                                  .document(SOS_ID)
                                  .updateData(
                                  data1).then((val) {
                                Fluttertoast.showToast(msg: 'Trip Finished');
                                setState(() {
                                  qrFlag = false;
                                });
                              });
                            }
                          });
                        }
                        else {
                          Fluttertoast.showToast(msg: 'Can\'t Finish!');
                        }
                      }
                    });
                  },
                  child: Text('Finish Trip', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                  ),),

                ),
              ),
            )
            ,
          ],
        )
        ,
      )
      ,
    );
  }

  Future<bool> isIDValid(String result) async {
    bool val;
    await User_UID.document(result).get().then((SS) {
      if (SS['SOS_ID'] != null)
        val = true;
      else
        val = false;
    });
    return val;
  }

  Future _scanQR() async {
    try {
      result = await BarcodeScanner.scan();
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

  Future<FirebaseUser> getUID() async {
    return user = await _firebaseAuth.currentUser();
  }

  Future getLocation() async {
    placemark = await Geolocator().placemarkFromCoordinates(lat, long);
    location = placemark[0];
  }

  getCoordinates() async {
    String SOS_ID;
    await User_UID.document(UID).get().then((DS) {
      if (DS.exists)
        SOS_ID = DS['SOS_ID'];
    });
    Map map = HashMap<String, bool>();
    map.putIfAbsent('getLocation', () => true);
    await SOS_UID.document(SOS_ID).updateData(map);
    Future.delayed(Duration(seconds: 5));
    await SOS_UID.document(SOS_ID).get().then((DS) {
      if (DS.exists) {
        long = DS['Longitude'];
        lat = DS['Latitude'];
      }
    });
    await getLocation();
    setState(() {
      flag1 = true;
      flag2 = false;
    });
  }


  Widget cardB() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.red.shade900,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 30,
              child: Text('Emergency! Your Car Has Met With An Accident!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30, color: Colors.white,
                    fontWeight: FontWeight.bold
                ),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 50, width: double.infinity,
              child: RaisedButton(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                onPressed: () async {
                  setState(() {
                    flag3 = true;
                  });
                  await getLocation();
                  setState(() {
                    flag3 = false;
                    flag = true;
                  });
                },
                child: Text('Get Location', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                ),),
              ),
            ),
          ),
          flag3 ? CircularProgressIndicator() : SizedBox(height: 0),
          flag ?
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width - 40,
            alignment: Alignment.center,
            child: SelectableText(
              'Location: ${location.name}, ${location
                  .subThoroughfare}, ${location
                  .thoroughfare}, ${location.subLocality}, ${location
                  .locality}, ${location.postalCode}, ${location.country}',
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ) :
          SizedBox(
            height: 0,
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    icon: Icon(Icons.share,
                      color: Colors.white,
                      size: 32,),
                    tooltip: 'Share',
                    splashColor: temp1 ? Colors.white : Colors.red.shade900,
                    highlightColor: temp1 ? Colors.white : Colors.red
                        .shade900,
                    onPressed: () {
                      Share.share(
                          'http://www.google.com/maps/place/$lat,$long');
                    }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 130,
                  child: RaisedButton(
                    onPressed: flag ? () async {
                      if (await MapLauncher.isMapAvailable(MapType.google)) {
                        await MapLauncher.launchMap(
                          mapType: MapType.google,
                          coords: Coords(lat, long),
                          title: 'Accident Spot',
                          description: 'Your car is here!',
                        );
                      }
                      else if (await MapLauncher.isMapAvailable(MapType.apple)) {
                        await MapLauncher.launchMap(
                          mapType: MapType.apple,
                          coords: Coords(lat, long),
                          title: 'Accident Spot',
                          description: 'Your car is here!',
                        );
                      }
                      else {
                        final availableMaps = await MapLauncher.installedMaps;
                        await availableMaps.first.showMarker(
                          coords: Coords(lat, long),
                          title: "Accident Spot",
                          description: "Your car is here!",
                        );
                      }
                    } : () {
                      Fluttertoast.showToast(
                          msg: 'First Press \"Get Location\" to acquire the co-ordinates!',
                          toastLength: Toast.LENGTH_LONG);
                    },
                    child: Text('Navigate'),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                    icon: Image.asset('images/silent.jpg', color: Colors.white),
                    tooltip: 'Silent',
                    splashColor: temp1 ? Colors.white : Colors.red.shade900,
                    highlightColor: temp1 ? Colors.white : Colors.red
                        .shade900,
                    onPressed: () {
                      if (temp1)
                        stop();
                      setState(() {
                        temp1 = false;
                      });
                    }
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}