import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loveliacreativity/classes/Detalle-Pedido.dart';
import 'editar-producto-inventario.dart';
import 'dart:async';
import '../classes/Producto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' show Platform;
import '../classes/Compra.dart';

class SeleccionarProductoInventarioPage extends StatefulWidget {
  SeleccionarProductoInventarioPage({Key key, this.idPedido, this.cliente})
      : super(key: key);

  final String idPedido;
  final DetallePedido cliente;

  @override
  _SeleccionarProductoInventarioPageState createState() =>
      _SeleccionarProductoInventarioPageState();
}

class _SeleccionarProductoInventarioPageState
    extends State<SeleccionarProductoInventarioPage> {
  List<Producto> productos;
  Firestore fs = Firestore.instance;
  StreamSubscription<QuerySnapshot> productosSub;
  FirebaseStorage storage = FirebaseStorage.instance;

  TextEditingController cantidadProductoAgregar = new TextEditingController();
  final _formKey = new GlobalKey<FormState>();

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

  bool validar() {
    final form = this._formKey.currentState;
    final formDate = this._formKey.currentState;
    if (form.validate() && formDate.validate()) {
      form.save();
      formDate.save();
      return true;
    } else {
      return false;
    }
  }

  Future<Null> agregarPedidoACliente(Producto producto) async {
    if (this.validar() && this.cantidadProductoAgregar.text != '') {
      final compras = [];
      int coincidencias = 0;
      this.widget.cliente.compras.forEach((compra) {
        if (compra.producto == producto.id) coincidencias = coincidencias + 1;
      });
      if (coincidencias != 0) {
        this
            .widget
            .cliente
            .compras
            .firstWhere((compra) => producto.id == compra.producto)
            .cantidadProducto += int.parse(this.cantidadProductoAgregar.text);
      } else {
        this.widget.cliente.compras.add(
            Compra(int.parse(this.cantidadProductoAgregar.text), producto.id));
      }
      this.widget.cliente.compras.forEach((compra) {
        compras.add(compra.toMap());
      });
      await this
          .fs
          .document(
              'Pedidos/${this.widget.idPedido}/Clientes/${this.widget.cliente.id}')
          .updateData({'Compras': compras});
    }
  }

  Future<Null> seleccionarCantidadParaProducto(
      BuildContext context, Producto producto, int indexProducto) async {
    this.cantidadProductoAgregar.value = TextEditingValue(text: '1');
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(producto.id),
                  content: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: true,
                          autofocus: false,
                          controller: this.cantidadProductoAgregar,
                          validator: (value) {
                            String texto = value.toString();
                            switch (texto) {
                              case '':
                                return 'Debe de ingresar una cantidad válida';
                                break;
                              case '0':
                                return 'Debe de ingresar una cantidad mayor a 0';
                                break;
                              default:
                                return null;
                                break;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        agregarPedidoACliente(this.productos[indexProducto]);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Actualizar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(producto.id),
                  content: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          enabled: true,
                          autofocus: false,
                          controller: this.cantidadProductoAgregar,
                          validator: (value) {
                            String texto = value.toString();
                            switch (texto) {
                              case '':
                                return 'Debe de ingresar una cantidad válida';
                                break;
                              case '0':
                                return 'Debe de ingresar una cantidad mayor a 0';
                                break;
                              default:
                                return null;
                                break;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        agregarPedidoACliente(this.productos[indexProducto]);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Actualizar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
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
        this.cantidadProductos = snapshot.documents.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Producto'),
      ),
      body: this.productos.length == 0
          ? Center(
              child: Text('Aun no hay productos en el inventario.'),
            )
          : GridView.builder(
              itemCount: this.productos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext ctx, int index) {
                return GestureDetector(
                  onTap: () {
                    this.seleccionarCantidadParaProducto(
                        context, this.productos[index], index);
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
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              },
            ),
    );
  }
}
