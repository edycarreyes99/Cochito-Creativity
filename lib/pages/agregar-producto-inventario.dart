import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class AgregarProductoInventarioPage extends StatefulWidget {
  @override
  _AgregarProductoInventarioPageState createState() =>
      _AgregarProductoInventarioPageState();
}

class _AgregarProductoInventarioPageState
    extends State<AgregarProductoInventarioPage> {
  File _imagenProducto;

  Future tomarImagen(String lugar) async {
    switch (lugar) {
      case 'Camara':
        var image = await ImagePicker.pickImage(source: ImageSource.camera);

        setState(() {
          _imagenProducto = image;
        });
        break;
      case 'Galeria':
        var image = await ImagePicker.pickImage(source: ImageSource.gallery);

        setState(() {
          _imagenProducto = image;
        });
        break;
      default:
        print("Metodo para escoger imagen no definido, intente nuevamente");
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this._imagenProducto = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar al Inventario')),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext ctx) {
                              return Container(
                                child: Wrap(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.photo_camera),
                                      title: Text('Tomar foto'),
                                      onTap: () => this
                                          .tomarImagen('Camara')
                                          .then((value) =>
                                              Navigator.of(ctx).pop())
                                          .catchError(
                                              (e) => print(e.toString())),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text('Escoger de la Galeria'),
                                      onTap: () => this
                                          .tomarImagen('Galeria')
                                          .then((value) =>
                                              Navigator.of(ctx).pop())
                                          .catchError(
                                              (e) => print(e.toString())),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 50.0,
                        child: this._imagenProducto == null
                            ? Center(
                                child: Icon(
                                  Icons.photo,
                                  size: 40.0,
                                ),
                              )
                            : null,
                        backgroundImage: this._imagenProducto == null
                            ? null
                            : FileImage(this._imagenProducto),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Foto del Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
