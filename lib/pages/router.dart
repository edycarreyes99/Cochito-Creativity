import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cochitocreativity/pages/home.dart';
import 'package:cochitocreativity/pages/login.dart';
import 'package:cochitocreativity/services/auth.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RouterPage extends StatefulWidget {
  RouterPage({this.auth});

  final Auth auth;

  @override
  State<StatefulWidget> createState() => new _RouterPageState();
}

enum AuthStatus {
  // NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RouterPageState extends State<RouterPage> {
  AuthStatus authStatus = AuthStatus.NOT_LOGGED_IN;
  String _userId = "";

  // Variables para las notificaciones
  FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Instancia de firestore
  Firestore fs = Firestore.instance;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future showNotificationWithDefaultSound(String title, String body) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Haz tocado la notificacion',
    );
  }

  void activarNotificaciones() {
    if (!Platform.isAndroid) {
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotificationWithDefaultSound(
            message['notification']['title'].toString(),
            message['notification']['body'].toString());
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
              ),
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );

    _fcm.getToken().then((token) async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String versionOS;
      String modelo;
      String marca;
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        versionOS = "Android " + androidInfo.version.release;
        modelo = androidInfo.model;
        marca = androidInfo.brand;
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        versionOS = iosInfo.utsname.version;
        modelo = iosInfo.utsname.machine;
        marca = iosInfo.model;
      }
      print("Id de dispositivo: " + token.toString());
      print("La version del sistema operativo es: " + versionOS);
      print("El modelo del dispositivo es: " + modelo);
      print("La marca del dispositivo es: " + marca);
      fs
          .collection('Dispositivos')
          .document(token.toString())
          .setData({
            'Token': token.toString(),
            'DUID': token.toString(),
            'SistemaOperativo': Platform.isAndroid
                ? 'Android'
                : Platform.isIOS ? 'iOS' : Platform.isFuchsia ? 'Fuchsia' : '',
            'VersionOS': versionOS,
            'Modelo': modelo,
            'PerteneceA': widget.auth.user.uid,
            'NombreUsuario': widget.auth.user.displayName,
          })
          .then((value) =>
              print("Dispositivo agregado a la base de datos correctamente!."))
          .catchError((e) => print(e.toString()));
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      /*case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;*/
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginPage(
          servicio: widget.auth,
          onIniciado: _onLoggedIn,
          isAndroid: Platform.isAndroid,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          // Actualizar la base de datos con los datos del dispositivo
          activarNotificaciones();
          var initializationSettingsAndroid =
              new AndroidInitializationSettings('logo');
          var initializationSettingsIOS = new IOSInitializationSettings();
          var initializationSettings = new InitializationSettings(
              initializationSettingsAndroid, initializationSettingsIOS);
          flutterLocalNotificationsPlugin =
              new FlutterLocalNotificationsPlugin();
          flutterLocalNotificationsPlugin.initialize(initializationSettings,
              onSelectNotification: onSelectNotification);
          return new HomePage(
            titulo: 'Cochito Creativity',
            userId: _userId,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
          );
        } else
          return new LoginPage(
            servicio: widget.auth,
            onIniciado: _onLoggedIn,
            isAndroid: Platform.isAndroid,
          );
        // return _buildWaitingScreen();
        break;
      default:
        return new LoginPage(
          servicio: widget.auth,
          onIniciado: _onLoggedIn,
          isAndroid: Platform.isAndroid,
        );
      // return _buildWaitingScreen();
    }
  }
}
