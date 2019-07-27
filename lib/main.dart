import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/home.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;

  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
