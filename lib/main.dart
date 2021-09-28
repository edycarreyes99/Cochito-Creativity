import 'package:cochitocreativity/providers/auth_providers.dart';
import 'package:cochitocreativity/views/home/home_view.dart';
import 'package:cochitocreativity/views/login/login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/custom_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (kIsWeb) {
    print('Running app in WEB platform');
    FacebookAuth.i.webInitialize(
      appId: "250433569721333",
      cookie: true,
      xfbml: true,
      version: "v9.0",
    );
    print(
        'Facebook SDK were initialized?: ${FacebookAuth.i.isWebSdkInitialized}');
  }
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    CustomColors customColors = new CustomColors();
    final authState = watch(authStateProvider);
    return MaterialApp(
        title: 'Cochito Creativity',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColorBrightness: Brightness.light,
          primaryColorDark: customColors.accentColor,
          accentColor: customColors.accentColor,
          accentColorBrightness: Brightness.light,
          primarySwatch: customColors.primaryColor,
        ),
        home: authState.when(
          data: (user) => user != null ? HomeView() : LoginView(),
          loading: () => Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Scaffold(
            body: Center(
              child: Text('An error occurred while doing login'),
            ),
          ),
        ));
  }
}
