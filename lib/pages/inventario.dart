import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'agregar-producto-inventario.dart';

class InventarioPage extends StatefulWidget {
  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[Text('Inventario Page')],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_photo_alternate,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarProductoInventarioPage(),
            ),
          );
        },
      ),
    );
  }
}
