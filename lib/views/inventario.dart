import 'dart:async';
import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cochitocreativity/views/editar-producto-inventario.dart';
import 'package:cochitocreativity/views/ver-producto-inventario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../classes/Producto.dart';
import 'agregar-producto-inventario.dart';
import 'editar-producto-inventario.dart';

class InventarioPage extends StatefulWidget {
  InventarioPage({Key key}) : super(key: key);

  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  List<Producto> productos;
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> productosSub;
  FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot> getListaDeInventario({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots =
        Firestore.instance.collection('/Inventario/').snapshots();

    if (offset != null) {
      snapshots = snapshots.skip(offset);
    }

    if (limit != null) {
      snapshots = snapshots.take(limit);
    }

    return snapshots;
  }

  Future<void> eliminarProductoInventario(Producto producto) async {
    await this
        .fs
        .document('Inventario/${producto.id}')
        .delete()
        .then((response) async {
      await this
          .storage
          .ref()
          .child('Inventario/${producto.id}')
          .delete()
          .then((resp) {
        Navigator.of(context).pop();
      }).catchError((er) {
        print(er);
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<Null> mostrarConfirmacionEliminar(
      BuildContext context, Producto producto) async {
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('Confirmar Eliminación'),
                  content: Text(
                    '¿Está seguro que desea eliminar el producto ${producto.id} del inventario?',
                  ),
                  actions: <Widget>[
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text('Eliminando Producto'),
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            });
                        await eliminarProductoInventario(producto);
                      },
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              : AlertDialog(
                  title: Text('Confirmar Eliminación'),
                  content: Text(
                    '¿Está seguro que desea eliminar el producto "${producto.id}" del inventario?',
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text('Eliminando Producto'),
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            });
                        eliminarProductoInventario(producto);
                      },
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.productos = new List();

    this.productosSub =
        this.getListaDeInventario().listen((QuerySnapshot snapshot) {
      final List<Producto> productoss = snapshot.documents
          .map((documentSnapshot) => Producto.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        this.productos = productoss;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this.productosSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this.productos.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/draws/empty_draw.svg",
                    width: 250,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      '¡Aún no hay ningún producto registrado en el inventario.!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              itemCount: this.productos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext ctx, int index) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext ctx) {
                          return Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    'Ver Producto',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            VerProductoInventarioPage(
                                          producto: this.productos[index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  title: Text(
                                    'Editar Producto',
                                    style: TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditarProductoInventarioPage(
                                          producto: this.productos[index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    'Eliminar Producto',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    this.mostrarConfirmacionEliminar(
                                        context, this.productos[index]);
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: CachedNetworkImage(
                    imageUrl: this.productos[index].imagen,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_photo_alternate,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarProductoInventarioPage(),
            ),
          );
        },
      ),
    );
  }
}
