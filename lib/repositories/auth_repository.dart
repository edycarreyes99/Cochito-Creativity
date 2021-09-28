import 'package:cochitocreativity/providers/auth_providers.dart';
import 'package:cochitocreativity/providers/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthRepository {
  final Reader _reader;

  const AuthRepository(this._reader);

  Stream<User?> get authStateChanges =>
      _reader(firebaseAuthProvider).authStateChanges();

  User? getCurrentUser() {
    return this._reader(firebaseAuthProvider).currentUser;
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result =
        await _reader(facebookRepositoryProvider).login();

    final facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);

    return await _reader(firebaseAuthProvider)
        .signInWithCredential(facebookAuthCredential);
  }

  Future<void> signOut() async {
    await this._reader(firebaseAuthProvider).signOut();
  }
}
