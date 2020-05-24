import 'package:cached_network_image/cached_network_image.dart';
import 'package:cochitocreativity/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(
                this.widget.auth.user.photoUrl +
                    '?type=large&width=512&height=512',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                this.widget.auth.user.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            MaterialButton(
              child: Text('Cerrar Sesion'),
              color: Colors.redAccent[100],
              onPressed: () {
                print("Sesion Cerrada");
                _signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
