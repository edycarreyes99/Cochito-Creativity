import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cochitocreativity/services/auth.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final Auth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          child: Text('Cerrar Sesion'),
          color: Colors.redAccent[100],
          onPressed: () {
            print("Sesion Cerrada");
            _signOut();
          },
        ),
      ),
    );
  }
}
