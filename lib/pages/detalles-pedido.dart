import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DetallesPedidoPage extends StatefulWidget {
  DetallesPedidoPage({this.titulo});

  final String titulo;

  @override
  _DetallesPedidoPageState createState() => _DetallesPedidoPageState();
}

class _DetallesPedidoPageState extends State<DetallesPedidoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.titulo),
        actions: <Widget>[
          Icon(Icons.more_vert),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Text('Hola Mundo')
        ],
      ),
    );
  }
}
