import 'dart:async';
import 'dart:collection';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
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

  String user1;
  List<String> list = [];

  List<Placemark> placemark;

  Placemark location;

  bool flag, flag1, flag2, flag3, temp, temp1;


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
    temp = false;
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
                return Container(
                  height: 300,
                  child: new Column(
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
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
                                temp1=true;
                              }
                            }
                          }
                        }
                      }
                      return SizedBox(
                        height: 0,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Center(
                child: Container(
                  padding: EdgeInsets.only(top: 5),
                  height: 50,
                  child: RaisedButton(
                      child: Text('Find My Car'),
                      onPressed: () async {
                        setState(() {
                          flag2 = true;
                        });
                        await getCoordinates();
                      }),
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
                  child: Text('Navigate'),
                ),
              ),
            ) :
            SizedBox(
              height: 0,
            ),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 130,
              child: RaisedButton(
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
                child: Text('Get Location'),
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
                      else
                      if (await MapLauncher.isMapAvailable(MapType.apple)) {
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