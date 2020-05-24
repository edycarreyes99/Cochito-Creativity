class Producto {
  String _imagen;
  double _precioCompra;
  double _precioVenta;
  String _id;
  String _categoria;

  Producto(this._imagen, this._precioCompra, this._precioVenta, this._categoria);

  Producto.map(dynamic obj) {
    this._imagen = obj['Imagen'];
    this._precioCompra = obj['PrecioCompra'];
    this._precioVenta = obj['PrecioVenta'];
    this._categoria = obj['Categoria'];
    this._id = obj['ID'];
  }

  String get imagen => this._imagen;

  double get precio => this._precioCompra;

  String get id => this._id;

  String get categoria => this._categoria;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['Imagen'] = this.imagen;
    map['Precio'] = this.precio;
    map['ID'] = this._id;
    map['Categoria'] = this._categoria;

    return map;
  }

  Producto.fromMap(Map<String, dynamic> map) {
    this._imagen = map['Imagen'];
    this._precioCompra = double.parse(map['Precio'].toString());
    this._categoria = map['Categoria'].toString();
    this._id = map['ID'];
  }
}
