import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cochitocreativity/services/auth.dart';
import 'package:cochitocreativity/views/account.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'account.dart';
import 'inventario.dart';
import 'pedidos.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.titulo, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final String titulo;
  final Auth auth;
  final VoidCallback onSignedOut;
  final String userId;

  final theme = SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    // navigation bar color
    statusBarColor: Colors.redAccent[100],
    // status bar color
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Firestore fs = Firestore.instance;

  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot> pedidoSub;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseMessaging _fcm = FirebaseMessaging();

  TabController _tabController;

  int indexTab;

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

  // ignore: non_constant_identifier_names
  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _fcm.getToken().then((token) {
      print(token);
    });

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotificationWithDefaultSound(
            message['notification']['title'].toString(),
            message['notification']['body'].toString());
        /*showDialog(
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
        );*/
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  // ignore: non_constant_identifier_names
  void iOS_Permission() {
    _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
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

  Future<Null> realizarAccionPedido(String tipoAccion) async {
    switch (tipoAccion) {
      case 'Cerrar Sesion':
        try {
          await widget.auth.signOut();
          widget.onSignedOut();
        } catch (e) {
          print(e);
        }
        break;
      default:
        print("Esta opcion no estaba registrada en el menu");
        break;
    }
  }

  _handleTabSelection(){
    setState(() {
      indexTab = _tabController.index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(_handleTabSelection);

    firebaseCloudMessaging_Listeners();
    pedidoSub = this.getListaPedidos().listen((QuerySnapshot snapshot) {
      print("Cambio");
      snapshot.documentChanges.map((DocumentChange documento) =>
          print("Tipo de cambio: " + documento.type.toString()));
    });

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('logo');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cochito Creativity'),
        actions: <Widget>[
          /*this._tabController.index == 1
              ? IconButton(
                  icon: FaIcon(FontAwesomeIcons.hatCowboySide),
                  onPressed: () => print("Configuracion de inventario."),
                )
              : null,
              this._tabController.index == 1
              ? IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () => print("Filtrar Lista"),
                )
              : null,*/

          /*PopupMenuButton<String>(
            onSelected: (String result) {
              realizarAccionPedido(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Cerrar Sesion',
                    child: ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
          ),*/
        ].where((w) => w != null).toList(),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Pedidos',
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Inventario',
            ),
            /*Tab(
              icon: Icon(Icons.message),
              text: 'Chats',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Ajustes',
            ),*/
            Tab(
              icon: Icon(Icons.account_circle),
              text: 'Mi Cuenta',
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: this._tabController,
        children: <Widget>[
          PedidosPage(),
          InventarioPage(),
          /*Scaffold(
            body: Center(
              child: Text("Zona de mensajes."),
            ),
          ),
          Scaffold(
            body: Center(
              child: Text("Zona de ajustes."),
            ),
          ),*/
          AccountPage(
            auth: widget.auth,
            userId: widget.userId,
            onSignedOut: widget.onSignedOut,
          )
        ],
      ),
    );
  }
}
