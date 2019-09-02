import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loveliacreativity/classes/Producto.dart';
import 'package:photo_view/photo_view.dart';

class VerProductoInventarioPage extends StatefulWidget {
  VerProductoInventarioPage({Key key, this.producto}) : super(key: key);

  final Producto producto;

  @override
  _VerProductoInventarioPageState createState() =>
      _VerProductoInventarioPageState();
}

class _VerProductoInventarioPageState extends State<VerProductoInventarioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.widget.producto.id +
              ' / C\$' +
              this.widget.producto.precio.toString(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(this.widget.producto.imagen),
        ),
      ),
    );
  }
}
