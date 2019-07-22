import 'package:cloud_firestore/cloud_firestore.dart';

class Compra {
  int _cantidadProducto;
  String _producto;

  Compra(this._cantidadProducto, this._producto);

  Compra.map(dynamic obj) {
    this._producto = obj['Producto'];
    this._cantidadProducto = obj['Cantidad'];
  }

  int get cantidadProducto => this._cantidadProducto;

  String get producto => this._producto;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['Cantidad'] = this._cantidadProducto;
    map['Producto'] = this._producto;

    return map;
  }

  Compra.fromMap(Map<String, dynamic> map) {
    this._producto = map['Producto'];
    this._cantidadProducto = map['Cantidad'];
  }
}
