import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../classes/Detalle-Pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalles-compras.dart';
import 'agregar-cliente.dart';

class DetallesPedidoPage extends StatefulWidget {
  DetallesPedidoPage({this.titulo});

  final String titulo;

  @override
  _DetallesPedidoPageState createState() => _DetallesPedidoPageState();
}

class _DetallesPedidoPageState extends State<DetallesPedidoPage> {
  List<DetallePedido> detallesPedidos;
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> detallesPedidoSub;

  Stream<QuerySnapshot> getListaDetallesPedidos({int offset, int limit}) {
    Stream<QuerySnapshot> snapshots = Firestore.instance
        .collection('Pedidos/${this.widget.titulo}/Clientes')
        .snapshots();

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
    this.detallesPedidos = new List();

    detallesPedidoSub =
        this.getListaDetallesPedidos().listen((QuerySnapshot snapshot) {
      final List<DetallePedido> detallessPedido = snapshot.documents
          .map((documentSnapshot) =>
              DetallePedido.fromMap(documentSnapshot.data))
          .toList();

      setState(() {
        this.detallesPedidos = detallessPedido;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    detallesPedidoSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.titulo),
        actions: <Widget>[
          Icon(Icons.more_vert),
        ],
      ),
      body: this.detallesPedidos.length == 0
          ? Center(
              child: Text(
                'Aún no hay ningun cliente registrado para este pedido.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: this.detallesPedidos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    title: Text(this.detallesPedidos[index].nombreCliente),
                    leading: CircleAvatar(
                      backgroundColor: Colors.lightGreen,
                      child: Center(
                        child: Text(
                          this
                              .detallesPedidos[index]
                              .cantidadProductos
                              .toString(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Text(
                      this.detallesPedidos[index].lugarEntrega +
                          " | " +
                          this
                              .detallesPedidos[index]
                              .fechaEntrega
                              .hour
                              .toString() +
                          ":" +
                          this
                              .detallesPedidos[index]
                              .fechaEntrega
                              .minute
                              .toString(),
                    ),
                    trailing: Column(
                      children: <Widget>[
                        Text(this.detallesPedidos[index].redSocial),
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text('C\$' +
                              this.detallesPedidos[index].totalPago.toString()),
                        )
                      ],
                    ),
                    onTap: () {
                      print("Cantidad de compras: " +
                          this
                              .detallesPedidos[index]
                              .compras
                              .length
                              .toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetallesComprasPage(
                                titulo:
                                    this.detallesPedidos[index].nombreCliente,
                                detallePedido: this.detallesPedidos[index],
                                idPedido: this.widget.titulo,
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
          Icons.person_add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarClientePage(
                    idPedido: this.widget.titulo,
                  ),
            ),
          );
        },
      ),
    );
  }
}
