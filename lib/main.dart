import 'dart:io' show Platform;

import 'package:catcher/catcher_plugin.dart';
import 'package:cochitocreativity/views/router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  // Crashlytics.instance.enableInDevMode = true;
  /*final Trace myTrace = FirebasePerformance.instance.newTrace("run_app");
  myTrace.start();*/

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();

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

  Future<RemoteConfig> setupRemoteConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    // Enable developer mode to relax fetch throttling
    remoteConfig
        .setConfigSettings(RemoteConfigSettings(debugMode: !kReleaseMode));

    return remoteConfig;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cochito Creativity',
      debugShowCheckedModeBanner: !kReleaseMode,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        primaryColor: Colors.redAccent[100],
      ),
      home: FutureBuilder<RemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context,
            AsyncSnapshot<RemoteConfig> remoteConfigSnapshot) {
          return remoteConfigSnapshot.hasData
              ? RouterPage(
                  isAndroid: Platform.isAndroid
                      ? true
                      : Platform.isFuchsia ? true : false,
                  remoteConfig: remoteConfigSnapshot.data,
                )
              : Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
