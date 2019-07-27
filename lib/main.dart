import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/home.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics();

  FirebaseMessaging _fcm = FirebaseMessaging();

  void _extraerFcmToken() async {
    if (!Platform.isIOS) {
      String fcmToken = await _fcm.getToken();
      print(fcmToken);
    } else if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) async {
        String fcmToken = await _fcm.getToken();
        print(fcmToken);
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: ListTile(
                  title: Text(message['notification']['title']),
                  subtitle: Text(message['notification']['body']),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    } /*, onLaunch: (Map<String, dynamic> message) async {
      print("onResume: $message");
      final snackBar = SnackBar(
        content: Text(message['notification']['title']),
        action: SnackBarAction(
          label: 'Ir',
          onPressed: () => null,
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }, onResume: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      final snackBar = SnackBar(
        content: Text(message['notification']['title']),
        action: SnackBarAction(
          label: 'Ir',
          onPressed: () => null,
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }*/
        );
    _fcm.subscribeToTopic('pedidos');
    _extraerFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lovelia Creativity',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightGreen,
        primaryColor: Colors.redAccent[100],
      ),
      home: HomePage(
        titulo: 'Lovelia Creativity',
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
