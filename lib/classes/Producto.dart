
class Producto {
  String _imagen;
  double _precio;

  Producto(this._imagen, this._precio);

  Producto.map(dynamic obj) {
    this._imagen = obj['Imagen'];
    this._precio = obj['Precio'];
  }

  String get imagen => this._imagen;

  double get precio => this._precio;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['Imagen'] = this.imagen;
    map['Precio'] = this.precio;

    return map;
  }

  Producto.fromMap(Map<String, dynamic> map) {
    this._imagen = map['Imagen'];
    this._precio = double.parse(map['Precio'].toString());
  }
}
