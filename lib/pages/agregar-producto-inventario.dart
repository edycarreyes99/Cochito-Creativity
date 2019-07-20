import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class AgregarProductoInventarioPage extends StatefulWidget {
  @override
  _AgregarProductoInventarioPageState createState() =>
      _AgregarProductoInventarioPageState();
}

class _AgregarProductoInventarioPageState
    extends State<AgregarProductoInventarioPage> {
  File _imagenProducto;

  Future tomarImagen(String lugar) {
    switch (lugar) {
      case 'Galeria':
        break;
      case 'Camara':
        break;
      default:
        break;
    }
  }

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
