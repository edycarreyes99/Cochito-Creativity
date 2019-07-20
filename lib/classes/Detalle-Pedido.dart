import 'package:cloud_firestore/cloud_firestore.dart';

class DetallePedido {
  String _id;
  String _descripcion;
  String _lugarEntrega;
  String _nombreCliente;
  String _redSocial;
  Timestamp _fechaEntrega;
  int _cantidadProductos;
  int _totalPago;

  DetallePedido(
      this._id,
      this._descripcion,
      this._lugarEntrega,
      this._nombreCliente,
      this._redSocial,
      this._fechaEntrega,
      this._cantidadProductos,
      this._totalPago);

  DetallePedido.map(dynamic obj) {
    this._id = obj['ID'];
    this._descripcion = obj['Descripcion'];
    this._lugarEntrega = obj['LugarEntrega'];
    this._nombreCliente = obj['NombreCliente'];
    this._redSocial = obj['RedSocial'];
    this._fechaEntrega = obj['FechaEntrega'];
    this._cantidadProductos = obj['CantidadProductos'];
    this._totalPago = obj['TotalPago'];
  }

  String get id => this._id;

  String get descripcion => this._descripcion;

  String get lugarEntrega => this._lugarEntrega;

  String get nombreCliente => this._nombreCliente;

  String get redSocial => this._redSocial;

  DateTime get fechaEntrega => this._fechaEntrega.toDate();

  int get cantidadProductos => this._cantidadProductos;

  int get totalPago => this._totalPago;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    if (this._id != null) {
      map['ID'] = this._id;
    }

    map['Descripcion'] = this.descripcion;
    map['LugarEntrega'] = this.lugarEntrega;
    map['NombreCliente'] = this.nombreCliente;
    map['RedSocial'] = this.redSocial;
    map['FechaEntrega'] = this.fechaEntrega;
    map['CantidadProductos'] = this.cantidadProductos;
    map['TotalPago'] = this.totalPago;

    return map;
  }

  DetallePedido.fromMap(Map<String, dynamic> map) {
    this._id = map['ID'];
    this._descripcion = map['Descripcion'];
    this._lugarEntrega = map['LugarEntrega'];
    this._nombreCliente = map['NombreCliente'];
    this._redSocial = map['RedSocial'];
    this._fechaEntrega = map['FechaEntrega'];
    this._cantidadProductos = map['CantidadProductos'];
    this._totalPago = map['TotalPago'];
  }
}
