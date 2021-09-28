import 'package:cochitocreativity/controllers/auth_controller.dart';
import 'package:cochitocreativity/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read));

final facebookRepositoryProvider =
    Provider<FacebookAuth>((ref) => FacebookAuth.instance);

final authControllerProvider = StateNotifierProvider<AuthController, User?>(
    (ref) => AuthController(ref.read));

final authStateProvider =
    StreamProvider((ref) => ref.watch(authRepositoryProvider).authStateChanges);
