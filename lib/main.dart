import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/home.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'package:firebase_performance/firebase_performance.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;
  final Trace myTrace = FirebasePerformance.instance.newTrace("run_app");
  myTrace.start();

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  runApp(MyApp());
  myTrace.stop();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseMessaging _fcm = FirebaseMessaging();
  Firestore fs = Firestore.instance;

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _fcm.getToken().then((token) async {
      await fs
          .collection('Dispositivos')
          .document(token.toString())
          .setData({'Token': token.toString(), 'UID': token.toString()})
          .then((value) =>
              print("Dispositivo agregado a la basae de datos correctamente!."))
          .catchError((e) => print(e.toString()));
    });
  }

  void iOS_Permission() {
    _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseCloudMessaging_Listeners();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lovelia Creativity',
      theme: ThemeData(
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
