import 'dart:io' show Platform;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cochitocreativity/classes/Pedido.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class AgregarClientePage extends StatefulWidget {
  AgregarClientePage({Key key, this.idPedido, this.pedido}) : super(key: key);

  final String idPedido;
  final Pedido pedido;

  @override
  _AgregarClientePageState createState() => _AgregarClientePageState();
}

class _AgregarClientePageState extends State<AgregarClientePage> {
  final _formKey = new GlobalKey<FormState>();
  final _formKeyFecha = new GlobalKey<FormState>();
  final fs = Firestore.instance;

  DateTime fechaHoy = DateTime.now();
  TimeOfDay fechaModificada;

  String nombreCliente;
  String descripcion;
  String lugarEntrega;
  String redSocial;
  DateTime fechaEntrega;

  bool validar() {
    final form = this._formKey.currentState;
    // final formDate = this._formKeyFecha.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  String generarFechaPedidoParaBaseDeDatos(DateTime fecha) {
    return fecha.day.toString() +
        "-" +
        fecha.month.toString() +
        "-" +
        fecha.year.toString();
  }

  Future<Null> seleccionarLugarEntrega(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text('Chinandega'),
                  onTap: () {
                    setState(() {
                      this.lugarEntrega = 'Chinandega';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                ),
                ListTile(
                  title: Text('Chichigalpa'),
                  onTap: () {
                    setState(() {
                      this.lugarEntrega = 'Chichigalpa';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                ),
                ListTile(
                  title: Text('León'),
                  onTap: () {
                    setState(() {
                      this.lugarEntrega = 'León';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<Null> seleccionarRedSocial(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  title: Text('WhatsApp'),
                  onTap: () {
                    setState(() {
                      this.redSocial = 'WhatsApp';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[800],
                  ),
                ),
                ListTile(
                  title: Text('Facebook'),
                  onTap: () {
                    setState(() {
                      this.redSocial = 'Facebook';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[800],
                  ),
                ),
                ListTile(
                  title: Text('Instagram'),
                  onTap: () {
                    setState(() {
                      this.redSocial = 'Instagram';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.pinkAccent,
                  ),
                ),
                ListTile(
                  title: Text('Cochito Creativity'),
                  onTap: () {
                    setState(() {
                      this.redSocial = 'Cochito Creativity';
                    });
                    Navigator.of(context).pop();
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent[100],
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<Null> seleccionarHora(BuildContext context) async {
    TimeOfDay picked;
    if (Platform.isAndroid) {
      picked =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
    } else if (Platform.isIOS) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext ctx) {
            return CupertinoTimerPicker(
              initialTimerDuration: Duration(
                  hours: DateTime.now().hour,
                  minutes: DateTime.now().minute,
                  seconds: DateTime.now().second),
              onTimerDurationChanged: (duration) {
                setState(() {
                  this.fechaModificada = TimeOfDay.fromDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          duration.inMilliseconds,
                          isUtc: true));
                });
              },
            );
          });
    }
    if (picked != null)
      setState(() {
        fechaModificada = picked;
        this.fechaEntrega = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          int.parse(this.widget.idPedido.substring(0, 1)) < 10
              ? int.parse(this.widget.idPedido.substring(0, 1))
              : int.parse(this.widget.idPedido.substring(0, 2)),
          fechaModificada.hour,
          fechaModificada.minute,
        );
      });
  }

  Future<Null> agregarCliente() async {
    if (this.validar()) {
      await this.fs.collection('Pedidos/${this.widget.idPedido}/Clientes').add({
        'CantidadProductos': 0,
        'Compras': [],
        'TotalPago': 0.0,
        'NombreCliente': this.nombreCliente.toUpperCase(),
        'LugarEntrega': this.lugarEntrega,
        'RedSocial': this.redSocial,
        'Descripcion': this.descripcion,
        'FechaEntrega': this.fechaEntrega,
        'Ganancias': 0.0
      }).then((documento) async {
        await this
            .fs
            .document(
                'Pedidos/${this.widget.idPedido}/Clientes/${documento.documentID}')
            .updateData({'ID': documento.documentID})
            .then((value) => print("Documento Actualizado!"))
            .catchError((er) => print(er.toString()));
      }).catchError((e) {
        print(e.toString());
      });
    }
  }

  Future<Null> mostrarErrorDeCampos(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Faltan Campos'),
            content: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                'Debe de rellenar todos los campos antes de guardar el cliente.',
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cerrar'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Cliente'),
        actions: <Widget>[
          FlatButton(
            child: Text('Guardar'),
            onPressed: () async {
              if (this.validar()) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Agregando Cliente.'),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    });
                await this.agregarCliente().then((value) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }).catchError((e) {
                  print(e.toString());
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
                });
              } else if (this.lugarEntrega == null ||
                  this.redSocial == null ||
                  this.fechaEntrega == null) {
                mostrarErrorDeCampos(context);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          enabled: true,
                          autofocus: false,
                          onSaved: (value) => this.nombreCliente = value,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar un nombre para el cliente'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Nombre Cliente',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          cursorColor: Colors.redAccent[100],
                          keyboardType: TextInputType.text,
                          enabled: true,
                          autofocus: false,
                          maxLines: 5,
                          onSaved: (value) => this.descripcion = value,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar una descripción'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: InkWell(
                    onTap: () => this.seleccionarLugarEntrega(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          fontSize: 20.0,
                        ),
                        hasFloatingPlaceholder: true,
                        labelText: this.lugarEntrega == null
                            ? 'Lugar de Entrega'
                            : this.lugarEntrega,
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: InkWell(
                    onTap: () => this.seleccionarRedSocial(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          fontSize: 20.0,
                        ),
                        hasFloatingPlaceholder: true,
                        labelText: this.redSocial == null
                            ? 'Red Social'
                            : this.redSocial,
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: InkWell(
                        onTap: () => this.seleccionarHora(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              fontSize: 20.0,
                            ),
                            hasFloatingPlaceholder: true,
                            labelText: this.fechaModificada == null
                                ? 'Hora de Entrega'
                                : this.fechaModificada.format(context),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.redAccent[100],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
