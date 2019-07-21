import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AgregarClientePage extends StatefulWidget {
  AgregarClientePage({this.idPedido});

  final String idPedido;

  @override
  _AgregarClientePageState createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends State<AgregarClientePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Cliente'),
      ),
      body: ListView(
        children: <Widget>[
          Text('Hola Mundo'),
        ],
      ),
    );
  }
}
