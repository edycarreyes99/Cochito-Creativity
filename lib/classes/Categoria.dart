
class Categoria {
  double _precioCompra;
  double _precioVenta;
  String _nombreCategoria;

  // Constructor
  Categoria(nombreCategoria, precioCompra, precioVenta){
    this._nombreCategoria = nombreCategoria;
    this._precioCompra = precioCompra;
    this._precioVenta = precioVenta;
  }

  // Metodo para transformar la clase a json
  Map<String, dynamic> toJson(){
    var json = new Map<String, dynamic>();

    json['NombreCategoria'] = this._nombreCategoria;
    json['PrecioCompra'] = this._precioCompra;
    json['PrecioVenta'] = this._precioVenta;

    return json;
  }

  // Constructor para convertir desde json la clase
  Categoria.fromJson(Map<String, dynamic> json){
    this._nombreCategoria = json['NombreCategoria'];
    this._precioCompra = double.parse(json['PrecioCompra'].toString());
    this._precioVenta = double.parse(json['PrecioVenta'].toString());
  }

  // Metodos de acceso a la clase
  double get precioCompra => this._precioCompra;

  double get precioVenta => this._precioVenta;

  String get nombreCategoria => this._nombreCategoria;

  void setPrecioCompra(double precioCompra){
    this._precioCompra = precioCompra;
  }

  void setPrecioVenta(double precioventa){
    this._precioVenta = precioVenta;
  }

  void setNombreCategoria(String nombreCategoria){
    this._nombreCategoria = nombreCategoria;
  }
}