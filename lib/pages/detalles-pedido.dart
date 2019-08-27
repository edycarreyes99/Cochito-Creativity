import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/clouddebugger/v2.dart';
import 'package:loveliacreativity/classes/Pedido.dart';
import '../classes/Detalle-Pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalles-compras.dart';
import 'agregar-cliente.dart';
import 'dart:io' show Platform;

class DetallesPedidoPage extends StatefulWidget {
  DetallesPedidoPage({Key key, this.titulo}) : super(key: key);

  final String titulo;

  @override
  _DetallesPedidoPageState createState() => _DetallesPedidoPageState();
}

class _DetallesPedidoPageState extends State<DetallesPedidoPage> {
  List<DetallePedido> detallesPedidos;
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> detallesPedidoSub;
  Pedido pedido;

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

  Future<void> eliminarPedido() async {
    await this
        .fs
        .document('Pedidos/${this.widget.titulo}')
        .delete()
        .then((res) {
      print('Pedido ${this.widget.titulo} ha sido eliminado correctamente');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> cerrarPedido() async {
    await this
        .fs
        .document('Pedidos/${this.widget.titulo}')
        .updateData({'EstadoPedido': 'Cerrado'}).then((res) {
      print('Pedido ${this.widget.titulo} ha sido cerrado correctamente');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }).catchError((e) {
      print(e);
    });
  }

  Future<Null> mostrarConfirmacionEliminar(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('Confirmar Eliminación'),
                  content: Text(
                    '¿Está seguro que desea eliminar este pedido?. Todos los clientes que contiene también serán eliminados.',
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
                      onPressed: () => this.eliminarPedido(),
                      child: Text(
                        'Eliminar Pedido',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              : AlertDialog(
                  title: Text('Confirmar Eliminación'),
                  content: Text(
                    '¿Está seguro que desea eliminar este pedido?. Todos los clientes que contiene también serán eliminados.',
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
                      onPressed: () => this.eliminarPedido(),
                      child: Text(
                        'Eliminar Pedido',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                );
        });
  }

  Future<Null> mostrarConfirmacionCerrar(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text('Confirmar Cierre'),
                  content: Text(
                    '¿Está seguro que desea cerrar este pedido?, no se podrán agregar nuevos clientes ni nuevos productos.',
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
                      onPressed: () => this.cerrarPedido(),
                      child: Text(
                        'Cerrar Pedido',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                )
              : AlertDialog(
                  title: Text('Confirmar Cierre'),
                  content: Text(
                    '¿Está seguro que desea cerrar este pedido?, no se podrán agregar nuevos clientes ni nuevos productos.',
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
                      onPressed: () => this.cerrarPedido(),
                      child: Text(
                        'Cerrar Pedido',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                );
        });
  }

  Future<Null> realizarAccionPedido(String tipoAccion) async {
    switch (tipoAccion) {
      case 'Entregar':
        print('Caso: Entregar');
        await this
            .fs
            .document('Pedidos/${this.widget.titulo}')
            .updateData({'EstadoPedido': 'Entregado'}).then((res) {
          print(
              'El estado del pedido ${this.widget.titulo} se ha cambiado a entregado correctamente');
          Navigator.of(context).pop();
        }).catchError((e) {
          print(e);
        });
        break;
      case 'Cerrar':
        print('Caso: Cerrar');
        this.mostrarConfirmacionCerrar(context);
        break;
      case 'Eliminar':
        print('Caso: Eliminar');
        this.mostrarConfirmacionEliminar(context);
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.detallesPedidos = new List();
    Pedido pedidoAux;

    detallesPedidoSub =
        this.getListaDetallesPedidos().listen((QuerySnapshot snapshot) async {
      final List<DetallePedido> detallessPedido = snapshot.documents
          .map((documentSnapshot) =>
              DetallePedido.fromMap(documentSnapshot.data))
          .toList();
      this
          .fs
          .document('Pedidos/${this.widget.titulo}')
          .snapshots()
          .listen((pedido) {
        pedidoAux = Pedido.fromMap(pedido.data);
      });

      setState(() {
        this.detallesPedidos = detallessPedido;
        this.pedido = pedidoAux;
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
          PopupMenuButton<String>(
            onSelected: (String result) {
              realizarAccionPedido(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Entregar',
                    child: ListTile(
                      leading: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      title: Text('Confirmar Entrega'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Cerrar',
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_late,
                        color: Colors.blue,
                      ),
                      title: Text('Cerrar Pedido'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Eliminar',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      title: Text('Eliminar Pedido'),
                    ),
                  ),
                ],
          )
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
