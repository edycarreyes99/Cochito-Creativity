import 'package:flutter/material.dart';
import 'package:loveliacreativity/pages/login.dart';
import 'package:loveliacreativity/services/auth.dart';
import 'package:loveliacreativity/pages/home.dart';
import 'dart:io' show Platform;

class RouterPage extends StatefulWidget {
  RouterPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RouterPageState();
}

enum AuthStatus {
  // NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RouterPageState extends State<RouterPage> {
  AuthStatus authStatus = AuthStatus.NOT_LOGGED_IN;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      /*case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;*/
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginPage(
          servicio: widget.auth,
          onIniciado: _onLoggedIn,
          isAndroid: Platform.isAndroid,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new HomePage(
            titulo: 'Lovelia Creativity',
            userId: _userId,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
          );
        } else
          return new LoginPage(
            servicio: widget.auth,
            onIniciado: _onLoggedIn,
            isAndroid: Platform.isAndroid,
          );
        // return _buildWaitingScreen();
        break;
      default:
        return new LoginPage(
          servicio: widget.auth,
          onIniciado: _onLoggedIn,
          isAndroid: Platform.isAndroid,
        );
      // return _buildWaitingScreen();
    }
  }
}
