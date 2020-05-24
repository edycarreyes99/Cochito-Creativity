import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cochitocreativity/views/home.dart';
import 'package:cochitocreativity/views/login.dart';
import 'package:cochitocreativity/services/auth.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class RouterPage extends StatefulWidget {
  RouterPage({this.isAndroid, this.authInstance});

  final bool isAndroid;

  final Auth authInstance;

  @override
  State<StatefulWidget> createState() => new _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  Auth authInstance;

  // Variables para las notificaciones
  FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Instancia de firestore
  Firestore fs = Firestore.instance;

  @override
  void initState() {
    super.initState();
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

  void activarNotificaciones(Auth authInstance) {
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
            'PerteneceA': authInstance.user.uid,
            'NombreUsuario': authInstance.user.displayName,
            'Email': authInstance.user.email != null
                ? authInstance.user.email
                : '',
          })
          .then((value) =>
              print("Dispositivo agregado a la base de datos correctamente!."))
          .catchError((e) => print(e.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider(create: (_) {
        authInstance = this.widget.authInstance == null
            ? Auth.instance()
            : this.widget.authInstance;
        return authInstance;
      }, child: Consumer(builder: (context, Auth user, _) {
        switch (user.status) {
          case Status.Uninitialized:
            print("En el router esta es la view de cargando");
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
            break;
          case Status.Authenticating:
          case Status.Unauthenticated:
            return new LoginPage(
              isAndroid: Platform.isAndroid,
            );
            break;
          case Status.Authenticated:
            // Actualizar la base de datos con los datos del dispositivo
            activarNotificaciones(authInstance);
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
              userId: authInstance.user.uid,
              auth: authInstance,
            );
            break;
          default:
            return new LoginPage(
              isAndroid: Platform.isAndroid,
            );
        }
      })),
    );
  }
}
