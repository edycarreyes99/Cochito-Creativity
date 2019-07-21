import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'agregar-producto-inventario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../classes/Producto.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InventarioPage extends StatefulWidget {
  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  List<Producto> productos;
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> productosSub;

  int cantidadProductos = 0;

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
        this.cantidadProductos = snapshot.documents.length;
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
      body: GridView.builder(
        itemCount: this.productos.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (BuildContext ctx, int index) {
          return GestureDetector(
            onTap: () => print("Objeto Tocado"),
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
              placeholder: (context, url) => CircularProgressIndicator(),
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
              builder: (context) => AgregarProductoInventarioPage(
                    cantidadProductosInventario: this.cantidadProductos,
                  ),
            ),
          );
        },
      ),
    );
  }
}
