import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FacebookLogin fbLogin = FacebookLogin();

  Auth(){
    _firebaseAuth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      this._user = null;
    } else {
      this._user = firebaseUser;
    }
  }

  FirebaseUser _user;

  FirebaseUser get user => _user;

  Future<FirebaseUser> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((auth) => auth.user);
    return user;
  }

  Future<FirebaseUser> signInWithFacebook(BuildContext context) async {

    FirebaseUser currentUser;
    final FacebookLoginResult facebookLoginResult =
        await fbLogin.logIn(['email', 'public_profile']);
    if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken facebookAccessToken = facebookLoginResult.accessToken;
      final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: facebookAccessToken.token);
      final FirebaseUser user = await _firebaseAuth
          .signInWithCredential(credential)
          .then((user) => user.user);
      final graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,link&access_token=${facebookLoginResult.accessToken.token}');
      final profile = json.decode(graphResponse.body);
      print("El id del usuario de facebook es: ${profile.toString()}");
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);
      _user = currentUser;
  }
    return currentUser;
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
