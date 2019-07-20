import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import '../classes/Pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidosPage extends StatefulWidget {
  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<Pedido> pedidos;
  Firestore fs = Firestore.instance;
  final CollectionReference pedidosRef =
      Firestore.instance.collection('Pedidos');
  StreamSubscription<QuerySnapshot> pedidoSub;

  Stream<QuerySnapshot> getListaPedidos({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = this.pedidosRef.snapshots();

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
    this.pedidos = new List();

    pedidoSub = this.getListaPedidos().listen((QuerySnapshot snapshot) {
      final List<Pedido> pedidoss = snapshot.documents
          .map((documentSnapshot) => Pedido.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this.pedidos = pedidoss;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pedidoSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: this.pedidos.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(this.pedidos[i].getId()),
              subtitle: Text(this.pedidos[i].getFecha().toString()),
            ),
          );
        },
      ),
    );
  }
}
