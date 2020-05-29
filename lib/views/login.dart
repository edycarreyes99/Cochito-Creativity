import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cochitocreativity/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  // constructor
  LoginPage({Key key, this.authInstance, this.isAndroid}) : super(key: key);

  final Auth authInstance;

  // variable que se inicializa mediante paso por valor desde el constructor para conocer la plataforma en la que la aplicacion se esta corriendo
  final bool isAndroid;

  static String tag = 'login-page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;

  final fs = Firestore.instance;

  String usuariosRef = "/Vagos/Control/Usuarios/";

  final formKey = new GlobalKey<FormState>();
  final formKeyy = new GlobalKey<FormState>();

  final theme = SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    // navigation bar color
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.white,
    // status bar color
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));

  String _email;
  String _password;

  void iniciarSesion(Auth authProvider) async {
    try {
      await authProvider.signInWithFacebook(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 40),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Image(
                  width: 90,
                  height: 90,
                  image: AssetImage('assets/icon/Cochito-Logo.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Center(
                  child: Text(
                    'Cochito\nCreativity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(255, 161, 166, 1),
                      //color: Colors.black,
                      fontSize: 35.0,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Inicia sesión con Facebook para continuar.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 48, 0, 16),
                            child: SizedBox(
                              height: 50.0,
                              child: this.widget.isAndroid
                                  ? CupertinoButton(
                                      onPressed: () =>
                                          this.iniciarSesion(authProvider),
                                      color: Color.fromRGBO(255, 161, 166, 1),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SvgPicture.asset(
                                            "assets/custom_icons/facebook_icon.svg",
                                            color: Colors.white,
                                            width: 15,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              'Ingresar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : CupertinoButton(
                                      color: Colors.blue[800],
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SvgPicture.asset(
                                            "assets/custom_icons/facebook_icon.svg",
                                            color: Colors.white,
                                            width: 15,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              'Ingresar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onPressed: () =>
                                          this.iniciarSesion(authProvider),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
