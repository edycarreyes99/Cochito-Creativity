import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          child: Text('Cerrar Sesion'),
          color: Colors.redAccent[100],
          onPressed: () => print("Sesion Cerrada"),
        ),
      ),
    );
  }
}
