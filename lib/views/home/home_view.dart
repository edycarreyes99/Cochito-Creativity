import 'package:cochitocreativity/providers/auth_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeView extends HookWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider.notifier);
    final user = authControllerState.currentUser();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home view'),
        actions: [
          IconButton(
            onPressed: () =>
                context.read(authControllerProvider.notifier).signOut(),
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Center(
        child: Text(
          user != null ? 'Welcome ${user.displayName}' : 'User Initialized',
        ),
      ),
    );
  }
}
