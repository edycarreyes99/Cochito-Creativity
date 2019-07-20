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
  StreamSubscription<QuerySnapshot> pedidoSub;

  Stream<QuerySnapshot> getListaPedidos({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = fs.collection('Pedidos').snapshots();

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
    pedidos = new List();

    pedidoSub.cancel();

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
      body: ListView(
        children: <Widget>[
          Text('Pedidos Page'),
        ],
      ),
    );
  }
}
