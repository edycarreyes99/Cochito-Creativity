class Producto {
  String _imagen;
  double _precio;
  String _id;

  Producto(this._imagen, this._precio);

  Producto.map(dynamic obj) {
    this._imagen = obj['Imagen'];
    this._precio = obj['Precio'];
    this._id = obj['ID'];
  }

  String get imagen => this._imagen;

  double get precio => this._precio;

  String get id => this._id;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['Imagen'] = this.imagen;
    map['Precio'] = this.precio;
    map['ID'] = this._id;

    return map;
  }

  Producto.fromMap(Map<String, dynamic> map) {
    this._imagen = map['Imagen'];
    this._precio = double.parse(map['Precio'].toString());
    this._id = map['ID'];
  }
}
