import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cochitocreativity/classes/Producto.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';

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
  TextEditingController precioCompra = new TextEditingController();
  TextEditingController precioVenta = new TextEditingController();

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
      StorageReference storageReference =
          storage.ref().child('Inventario/${this.generarId()}');

      StorageUploadTask uploadTask =
          storageReference.putFile(this._imagenProducto);

      await uploadTask.onComplete;

      print("Objeto cargado a la nube de firebase");

      return await storageReference.getDownloadURL();
    } else if (validarFormulario() && this._imagenProducto == null) {
      return this.widget.producto.imagen;
    } else {
      return null;
    }
  }

  Future<File> recortarImagen(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  Future tomarImagen(String lugar) async {
    switch (lugar) {
      case 'Camara':
        // ignore: deprecated_member_use
        var image = await ImagePicker.pickImage(source: ImageSource.camera)
            .then((imagen) async => await this.recortarImagen(imagen))
            .catchError((e) => print(e));

        setState(() {
          _imagenProducto = image;
        });

        break;
      case 'Galeria':
        // ignore: deprecated_member_use
        var image = await ImagePicker.pickImage(source: ImageSource.gallery)
            .then((imagen) async => await this.recortarImagen(imagen))
            .catchError((e) => print(e));

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
    this.precioVenta.value =
        TextEditingValue(text: this.widget.producto.precioVenta.toString());
    this.precioCompra.value =
        TextEditingValue(text: this.widget.producto.precioCompra.toString());
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
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar un precio de compra para el producto'
                              : null,
                          controller: this.precioCompra,
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
                            labelText: 'Precio de compra',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar un precio de venta para el producto'
                              : null,
                          controller: this.precioVenta,
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
                            labelText: 'Precio de compra',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                                title: Text('¡Actualizando Producto!'),
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
                              'PrecioVenta': double.parse(this.precioVenta.text),
                              'PrecioCompra': double.parse(this.precioCompra.text)
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
