import 'package:flutter/material.dart';

class PedidosPage extends StatefulWidget {
  PedidosPage({this.titulo});

  final String titulo;

  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.titulo),
      ),
      body: Center(
        child: Text('Hola mundo'),
      ),
    );
  }
}
