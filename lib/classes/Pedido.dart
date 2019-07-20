class Pedido {
  String _id;
  String _fecha;
  int _totalPago;
  int _totalProductos;
  int _cantidadClientes;

  Pedido(this._id, this._fecha, this._totalPago, this._totalProductos,
      this._cantidadClientes);

  Pedido.map(dynamic obj) {
    this._id = obj['ID'];
    this._fecha = obj['FechaEntrega'];
    this._totalProductos = obj['TotalProductos'];
    this._totalPago = obj['TotalPago'];
    this._cantidadClientes = obj['CantidadClientes'];
  }

  String get id => this._id;

  String get fecha => this._fecha;

  int get totalPago => this._totalPago;

  int get totalProductos => this._totalProductos;

  int get cantidadClientes => this._cantidadClientes;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (this._id != null) {
      map['ID'] = this._id;
    }
    map['FechaEntrega'] = this._fecha;
    map['TotalProductos'] = this._totalProductos;
    map['TotalPago'] = this._totalPago;
    map['CantidadClientes'] = this._cantidadClientes;

    return map;
  }

  Pedido.fromMap(Map<String, dynamic> map) {
    this._id = map['ID'];
    this._fecha = map['FechaEntrega'];
    this._totalProductos = map['TotalProductos'];
    this._totalPago = map['TotalPago'];
    this._cantidadClientes = map['CantidadClientes'];
  }
}
