import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  String _id;
  Timestamp _fecha;
  double _totalPago;
  int _totalProductos;
  int _cantidadClientes;
  String _diaSemanaEntrega;
  String _estadoPedido;
  double _ganancias;

  Pedido(this._id, this._fecha, this._totalPago, this._totalProductos,
      this._cantidadClientes, this._estadoPedido);

  Pedido.map(dynamic obj) {
    this._id = obj['ID'];
    this._fecha = obj['FechaEntrega'];
    this._totalProductos = obj['TotalProductos'];
    this._totalPago = obj['TotalPago'];
    this._cantidadClientes = obj['CantidadClientes'];
    this._diaSemanaEntrega = obj['DiaSemanaEntrega'];
    this._estadoPedido = obj['EstadoPedido'];
    this._ganancias = obj['TotalGanancias'];
  }

  String getId() => this._id;

  String getFecha() => this._fecha.toDate().toString();

  double getTotalPago() => this._totalPago;

  int getTotalProductos() => this._totalProductos;

  int getCantidadClientes() => this._cantidadClientes;

  String getDiaSemanaEntrega() => this._diaSemanaEntrega;

  String getEstadoPedido() => this._estadoPedido;

  double getGanancias() => this._ganancias;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (this._id != null) {
      map['ID'] = this._id;
    }
    map['FechaEntrega'] = this._fecha;
    map['TotalProductos'] = this._totalProductos;
    map['TotalPago'] = this._totalPago;
    map['CantidadClientes'] = this._cantidadClientes;
    map['DiaSemanaEntrega'] = this._diaSemanaEntrega;
    map['EstadoPedido'] = this._estadoPedido;
    map['TotalGanancias'] = this._ganancias;

    return map;
  }

  Pedido.fromMap(Map<String, dynamic> map) {
    this._id = map['ID'];
    this._fecha = map['FechaEntrega'];
    this._totalProductos = map['TotalProductos'];
    this._totalPago = double.parse(map['TotalPago'].toString());
    this._cantidadClientes = map['CantidadClientes'];
    this._diaSemanaEntrega = map['DiaSemanaEntrega'];
    this._estadoPedido = map['EstadoPedido'];
    this._ganancias = double.parse(map['TotalGanancias'].toString());
  }
}
