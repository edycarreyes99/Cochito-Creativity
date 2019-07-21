import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AgregarPedidoPage extends StatefulWidget {
  @override
  _AgregarPedidoPageState createState() => _AgregarPedidoPageState();
}

class _AgregarPedidoPageState extends State<AgregarPedidoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Pedido'),
      ),
      body: ListView(
        children: <Widget>[
          Text('Hola Mundo'),
        ],
      ),
    );
  }
}
