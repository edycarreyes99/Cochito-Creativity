import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../classes/Pedido.dart';
import 'agregar-pedido.dart';
import 'detalles-pedido.dart';

class PedidosPage extends StatefulWidget {
  PedidosPage({Key key}) : super(key: key);

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
      body: this.pedidos.length == 0
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
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(
                      '¡Aún no hay ningún pedido registrado.!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: this.pedidos.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    title: Text(this.pedidos[i].getId()),
                    subtitle: Row(
                      children: <Widget>[
                        Text('Estado: '),
                        Text(
                          this.pedidos[i].getEstadoPedido(),
                          style: TextStyle(
                            color: this.pedidos[i].getEstadoPedido() ==
                                    'Pendiente'
                                ? Colors.orange
                                : this.pedidos[i].getEstadoPedido() == 'Cerrado'
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        )
                      ],
                    ),
                    trailing: Column(
                      children: <Widget>[
                        Text(this.pedidos[i].getDiaSemanaEntrega()),
                        Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'C\$' + this.pedidos[i].getTotalPago().toString(),
                          ),
                        )
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Center(
                        child: Text(
                          this.pedidos[i].getTotalProductos().toString(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetallesPedidoPage(
                            titulo: this.pedidos[i].getId(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarPedidoPage(),
            ),
          );
        },
      ),
    );
  }
}