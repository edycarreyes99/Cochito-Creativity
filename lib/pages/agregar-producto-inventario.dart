import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AgregarProductoInventarioPage extends StatefulWidget {
  @override
  _AgregarProductoInventarioPageState createState() =>
      _AgregarProductoInventarioPageState();
}

class _AgregarProductoInventarioPageState
    extends State<AgregarProductoInventarioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar al Inventario')),
      body: ListView(
        children: <Widget>[
          Text('Hola Mundo'),
        ],
      ),
    );
  }
}
