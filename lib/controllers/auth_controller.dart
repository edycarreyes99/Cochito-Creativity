import 'dart:async';

import 'package:cochitocreativity/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthController extends StateNotifier<User?> {
  final Reader _reader;

  StreamSubscription<User?>? _authStateChangesSubscription;

  AuthController(this._reader) : super(null) {
    this._authStateChangesSubscription?.cancel();
    this._authStateChangesSubscription = this
        ._reader(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }

  @override
  void dispose() {
    this._authStateChangesSubscription?.cancel();
    super.dispose();
  }

  User? currentUser() {
    return this._reader(authRepositoryProvider).getCurrentUser();
  }

  void loginWithFacebook() async {
    final user = this._reader(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      await this._reader(authRepositoryProvider).signInWithFacebook();
    }
  }

  void signOut() async {
    await this._reader(authRepositoryProvider).signOut();
  }
}
