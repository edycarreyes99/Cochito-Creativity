import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class Auth with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FacebookLogin fbLogin = FacebookLogin();
  String _uid = '';
  Status _status = Status.Uninitialized;
  FirebaseUser _user;

  BuildContext ctx;

  Auth.instance() : _firebaseAuth = FirebaseAuth.instance {
    _firebaseAuth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
      _uid = '';
    } else {
      _user = firebaseUser;
      _uid = firebaseUser.uid;
      if (this.ctx != null) Navigator.of(this.ctx).pop();
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Status get status => _status;

  String get uid => _uid;

  FirebaseUser get user => _user;

  Future<bool> signInWithFacebook(BuildContext context) async {
    this.ctx = context;
    FirebaseUser currentUser;
    fbLogin.loginBehavior = FacebookLoginBehavior.nativeOnly;
    final FacebookLoginResult facebookLoginResult =
        await fbLogin.logIn(['email', 'public_profile']);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Iniciando Sesión'),
            content: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        });
    try {
      _status = Status.Authenticating;
      notifyListeners();
      if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
        FacebookAccessToken facebookAccessToken =
            facebookLoginResult.accessToken;
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: facebookAccessToken.token);
        final FirebaseUser user = await _firebaseAuth
            .signInWithCredential(credential)
            .then((user) => user.user);
        final graphResponse = await http.get(
            'https://graph.facebook.com/v7.0/me?fields=name,first_name,last_name,email,link&access_token=${facebookLoginResult.accessToken.token}');
        final pictureResponse = await http.get(
            'https://graph.facebook.com/v7.0/me/picture?redirect=0&type=large&width=512&height=512&access_token=${facebookLoginResult.accessToken.token}');
        final profile = json.decode(graphResponse.body);

        final picture = json.decode(pictureResponse.body);

        print("El id del usuario de facebook es: ${profile.toString()}");

        UserUpdateInfo info = new UserUpdateInfo();
        info.displayName = profile['name'];
        info.photoUrl = picture['url'];
        currentUser = await _firebaseAuth.currentUser();

        currentUser.updateProfile(info);

        currentUser.reload();

        currentUser = await _firebaseAuth.currentUser();

        print(
            "El nombre del usuario es: ${currentUser.displayName} y su foto de perfil es: ${currentUser.photoUrl}");

        _user = currentUser;
      }
      return true;
    } catch (e) {
      Navigator.of(context).pop();
      _status = Status.Unauthenticated;
      print(e.toString());
      notifyListeners();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Hubo un error:'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'),
                )
              ],
              content: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Text(e.toString()),
                ),
              ),
            );
          });
      print(e);
      return false;
    }
  }

  Future<FirebaseUser> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((user) => user.user);
    return user;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    fbLogin.logOut();
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}
