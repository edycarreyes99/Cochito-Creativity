import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AgregarProductoInventarioPage extends StatefulWidget {
  AgregarProductoInventarioPage({Key key}) : super(key: key);

  @override
  _AgregarProductoInventarioPageState createState() =>
      _AgregarProductoInventarioPageState();
}

class _AgregarProductoInventarioPageState
    extends State<AgregarProductoInventarioPage> {
  File _imagenProducto;
  double _precioCompraProducto;
  double _precioVentaProducto;
  final _formKey = new GlobalKey<FormState>();
  String _idNuevoProducto;
  int cantidadProductos;
  final _idProductoController = TextEditingController();
  // ignore: cancel_subscriptions
  StreamSubscription<DocumentSnapshot> controlSub;

  Firestore fs = Firestore.instance;
  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot> agregarProductoSub;

  FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot> inventarioRef =
      Firestore.instance.collection('Inventario/').snapshots();

  Stream<QuerySnapshot> getListaDeInventario({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection('Inventario/').snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
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

  String generarId() {
    return this._idNuevoProducto;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.controlSub = this.fs.document('Control/Control').snapshots().listen((control){
      setState(() {
        this._idNuevoProducto =
            'PROD-' + (control.data['ContadorIdInventario'] + 1).toString();
        this._idProductoController.value =
            TextEditingValue(text: this._idNuevoProducto);
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this._imagenProducto = null;
    this._idNuevoProducto = null;
    this.cantidadProductos = null;
    this._precioCompraProducto = null;
    this._precioVentaProducto = null;
    this.controlSub.cancel();
    // this.agregarProductoSub.cancel();
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
                          controller: this._idProductoController,
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
                          onSaved: (value) =>
                              this._precioCompraProducto = double.parse(value),
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
                            labelText: 'Precio de Compra',
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
                          onSaved: (value) =>
                              this._precioVentaProducto = double.parse(value),
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
                            labelText: 'Precio de Venta',
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
                      child: Text('Agregar Producto'),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text('Subiendo Producto'),
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
                                .setData({
                              'Imagen': url,
                              'PrecioCompra': this._precioCompraProducto,
                              'PrecioVenta': this._precioVentaProducto,
                              'ID': this.generarId()
                            }).then((value) {
                              this.fs.document('Control/Control').updateData({
                                'ContadorIdInventario': FieldValue.increment(1),
                              }).then((onValue) {
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
