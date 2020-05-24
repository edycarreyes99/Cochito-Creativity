import 'dart:io' show Platform;

import 'package:catcher/catcher_plugin.dart';
import 'package:cochitocreativity/views/router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  // Crashlytics.instance.enableInDevMode = true;
  /*final Trace myTrace = FirebasePerformance.instance.newTrace("run_app");
  myTrace.start();*/

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // Catcher Options
  CatcherOptions debugOptions = CatcherOptions(
    SilentReportMode(),
    [
      ConsoleHandler(
        enableCustomParameters: true,
        enableApplicationParameters: true,
        enableDeviceParameters: true,
        enableStackTrace: true,
      ),
    ],
  );

  CatcherOptions releaseOptions = CatcherOptions(
    SilentReportMode(),
    [
      SlackHandler(
        "https://hooks.slack.com/services/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",
        "#cochito-creativity-bugs",
        username: "Cochito Creativity-Flutter",
        iconEmoji: ":disappointed_relieved:",
        enableDeviceParameters: true,
        enableApplicationParameters: true,
        enableCustomParameters: true,
        enableStackTrace: true,
        printLogs: true,
      ),
    ],
  );

  Catcher(MyApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);
  // myTrace.stop();
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
      title: 'Cochito Creativity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.redAccent[100],
      ),
      home: RouterPage(
        isAndroid:
            Platform.isAndroid ? true : Platform.isFuchsia ? true : false,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
