import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:loveliacreativity/services/auth.dart';

class LoginPage extends StatefulWidget {
  // constructor
  LoginPage({Key key, this.servicio, this.onIniciado, this.isAndroid})
      : super(key: key);

  final BaseAuth servicio;

  // variables que se inicializan mediante paso por valor desde el constructor para las acciones posteriores
  final VoidCallback onIniciado;

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

  String _email;
  String _password;

  bool validar() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void iniciarSesion() async {
    if (validar()) {
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
        String userEmail =
            await widget.servicio.signIn(_email, _password).then((user) {
          Navigator.of(context).pop();
          return user.email;
        }).catchError((e) {
          Navigator.of(context).pop();
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
        });
        print('Ha Iniciado sesion como: $userEmail');
        widget.onIniciado();
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: this.widget.isAndroid
                            ? TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                autofocus: false,
                                validator: (value) => value.isEmpty
                                    ? 'El email no puede estar en blanco.'
                                    : null,
                                onSaved: (value) => _email = value,
                                cursorColor: Colors.redAccent[100],
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  contentPadding: EdgeInsets.fromLTRB(
                                      15.0, 20.0, 20.0, 15.0),
                                  border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(30.0),
                                      ),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hasFloatingPlaceholder: true,
                                ),
                              )
                            : CupertinoTextField(
                                keyboardType: TextInputType.emailAddress,
                                autofocus: false,
                                onSubmitted: (value) => _email = value,
                                placeholder: 'Email',
                                cursorColor: Colors.redAccent[100],
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 20.0, 20.0, 15.0),
                              ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: this.widget.isAndroid
                            ? TextFormField(
                                autofocus: false,
                                obscureText: true,
                                validator: (value) => value.isEmpty
                                    ? 'La contraseña no puede estar en blanco.'
                                    : null,
                                onSaved: (value) => _password = value,
                                decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    contentPadding: EdgeInsets.fromLTRB(
                                        15.0, 20.0, 20.0, 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            const Radius.circular(30.0)),
                                        borderSide: BorderSide.none),
                                    filled: true,
                                    fillColor: Colors.grey[200]),
                              )
                            : CupertinoTextField(
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                obscureText: true,
                                onSubmitted: (value) => _password = value,
                                placeholder: 'Contraseña',
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 20.0, 20.0, 15.0),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 48, 0, 16),
                child: SizedBox(
                  height: 50.0,
                  child: this.widget.isAndroid
                      ? RaisedButton(
                          onPressed: () => this.iniciarSesion(),
                          elevation: 6.0,
                          color: Colors.redAccent[100],
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(50.0),
                          ),
                        )
                      : CupertinoButton(
                          color: Colors.redAccent[100],
                          child: Text(
                            'Iniciar Sesion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => {},
                        ),
                ),
              )
            ],
          ),
        ));

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.redAccent[100],
          primarySwatch: Colors.lightGreen,
          platform: this.widget.isAndroid
              ? TargetPlatform.android
              : TargetPlatform.iOS,
        ),
        home: Scaffold(
            backgroundColor: Colors.white,
            body: Builder(
                builder: (context) => Center(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 24.0, right: 24.0),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: Center(
                              child: Text(
                                'Te damos la bienvenida a',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: Center(
                              child: Text(
                                'Lovelia\nCreativity',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.redAccent[100],
                                  //color: Colors.black,
                                  fontSize: 50.0,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 28.0),
                                loginForm,
                              ],
                            ),
                          )
                        ],
                      ),
                    ))));
  }
}
