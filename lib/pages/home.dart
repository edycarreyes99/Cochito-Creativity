import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loveliacreativity/pages/account.dart';
import 'pedidos.dart';
import 'inventario.dart';
import 'account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  HomePage({this.titulo});

  final String titulo;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Firestore fs = Firestore.instance;

  StreamSubscription<QuerySnapshot> pedidoSub;

  Stream<QuerySnapshot> getListaPedidos({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = this.fs.collection('Pedidos').snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  FirebaseMessaging _fcm = FirebaseMessaging();

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _fcm.getToken().then((token) {
      print(token);
    });

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
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
    pedidoSub = this.getListaPedidos().listen((QuerySnapshot snapshot) {
      print("Cambio");
      snapshot.documentChanges.map((DocumentChange documento) =>
          print("Tipo de cambio: " + documento.type.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.titulo),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.shopping_cart),
                  text: 'Pedidos',
                ),
                Tab(
                  icon: Icon(Icons.assignment),
                  text: 'Inventario',
                ),
                Tab(
                  icon: Icon(Icons.account_circle),
                  text: 'Mi Cuenta',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[PedidosPage(), InventarioPage(), AccountPage()],
          )),
    );
  }
}
