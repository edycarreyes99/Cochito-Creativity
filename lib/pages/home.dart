import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loveliacreativity/pages/account.dart';
import 'pedidos.dart';
import 'inventario.dart';
import 'account.dart';

class HomePage extends StatefulWidget {
  HomePage({this.titulo});

  final String titulo;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                  icon: Icon(Icons.add_shopping_cart),
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
            children: <Widget>[
              PedidosPage(),
              InventarioPage(),
              AccountPage()
            ],
          )),
    );
  }
}
