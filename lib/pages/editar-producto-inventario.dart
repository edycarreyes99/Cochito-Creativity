import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loveliacreativity/classes/Producto.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class EditarProductoInventarioPage extends StatefulWidget {
  EditarProductoInventarioPage({Key key, this.producto}) : super(key: key);

  final Producto producto;

  @override
  _EditarProductoInventarioPageState createState() =>
      _EditarProductoInventarioPageState();
}

class _EditarProductoInventarioPageState
    extends State<EditarProductoInventarioPage> {
  File _imagenProducto;
  final _formKey = new GlobalKey<FormState>();
  FirebaseStorage storage = FirebaseStorage.instance;
  Firestore fs = Firestore.instance;
  TextEditingController precioProducto = new TextEditingController();

  String generarId() {
    return this.widget.producto.id;
  }

  bool validarFormulario() {
    final form = this._formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future<String> subirImagenStorage() async {
    if (validarFormulario() && this._imagenProducto != null) {
      String filename = basename(this._imagenProducto.path);

      String extension = context.extension(filename);

      StorageReference storageReference =
          storage.ref().child('Inventario/${this.generarId()}');

      StorageUploadTask uploadTask =
          storageReference.putFile(this._imagenProducto);

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      Uri location = taskSnapshot.uploadSessionUri;

      print("Objeto cargado a la nube de firebase");

      return await storageReference.getDownloadURL();
    } else if (validarFormulario() && this._imagenProducto == null) {
      return this.widget.producto.imagen;
    } else {
      return null;
    }
  }

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
  void initState() {
    // TODO: implement initState
    this.precioProducto.value =
        TextEditingValue(text: this.widget.producto.precio.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ' + this.widget.producto.id)),
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
                        child: this.widget.producto.imagen == null
                            ? Center(
                                child: Icon(
                                  Icons.photo,
                                  size: 40.0,
                                ),
                              )
                            : null,
                        backgroundImage: this._imagenProducto == null
                            ? NetworkImage(this.widget.producto.imagen)
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
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          enabled: false,
                          autofocus: false,
                          initialValue: this.widget.producto.id,
                          decoration: InputDecoration(
                            labelText: 'ID de Producto',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar un precio para el producto'
                              : null,
                          controller: this.precioProducto,
                          decoration: InputDecoration(
                            prefix: Text('C\$'),
                            suffix: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.redAccent[100],
                              ),
                              onPressed: () {
                                this._formKey.currentState.reset();
                              },
                            ),
                            labelText: 'Precio',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.redAccent[100],
                      child: Text('Actualizar Producto'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text('¡Actializando Producto!'),
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            });
                        this.subirImagenStorage().then((url) {
                          if (url != null) {
                            this
                                .fs
                                .collection('Inventario')
                                .document(this.generarId())
                                .updateData({
                              'Imagen': url,
                              'Precio': double.parse(this.precioProducto.text)
                            }).then((value) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            }).catchError((e) {
                              print(e.toString());
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: Text('Hubo un error:'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('Cerrar'),
                                        )
                                      ],
                                      content: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Center(
                                          child: Text(e.toString()),
                                        ),
                                      ),
                                    );
                                  });
                            });
                          }
                        }).catchError((e) {
                          print(e.toString());
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return CupertinoAlertDialog(
                                  title: Text('Hubo un error:'),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text('Cerrar'),
                                    )
                                  ],
                                  content: Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Center(
                                      child: Text(e.toString()),
                                    ),
                                  ),
                                );
                              });
                        });
                      },
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
