import 'package:cochitocreativity/providers/auth_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginView extends HookWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login view'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              context.read(authControllerProvider.notifier).loginWithFacebook(),
          child: Text('Start with Facebook'),
        ),
      ),
    );
  }
}
