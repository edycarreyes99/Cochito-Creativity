import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EditarClientePage extends StatefulWidget {
  @override
  _EditarClientePageState createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cliente'),
      ),
      body: Center(
        child: Text('Hola Mundo'),
      ),
    );
  }
}
