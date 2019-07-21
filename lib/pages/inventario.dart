import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'agregar-producto-inventario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class InventarioPage extends StatefulWidget {
  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> agregarProductoSub;

  int cantidadProductos = 0;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.agregarProductoSub =
        this.getListaDeInventario().listen((QuerySnapshot snapshot) {
      setState(() {
        this.cantidadProductos = snapshot.documents.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[Text('Inventario Page')],
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
