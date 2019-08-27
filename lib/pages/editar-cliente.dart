import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;

import 'package:loveliacreativity/classes/Detalle-Pedido.dart';

class EditarClientePage extends StatefulWidget {
  EditarClientePage({Key key, this.idPedido, this.cliente}) : super(key: key);

  final String idPedido;
  final DetallePedido cliente;

  @override
  _EditarClientePageState createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  final _formKey = new GlobalKey<FormState>();
  final _formKeyFecha = new GlobalKey<FormState>();
  final fs = Firestore.instance;

  DateTime fechaHoy = DateTime.now();
  TimeOfDay fechaModificada;

  final nombreCliente = TextEditingController();
  final descripcion = TextEditingController();
  final lugarEntrega = TextEditingController();
  final redSocial = TextEditingController();
  DateTime fechaEntrega;

  bool validar() {
    final form = this._formKey.currentState;
    final formDate = this._formKeyFecha.currentState;
    if (form.validate() && formDate.validate()) {
      form.save();
      formDate.save();
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
                      this.lugarEntrega.value =
                          TextEditingValue(text: 'Chinandega');
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
                      this.lugarEntrega.value =
                          TextEditingValue(text: 'Chichigalpa');
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
                      this.lugarEntrega.value = TextEditingValue(text: 'León');
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
                      this.redSocial.value = TextEditingValue(text: 'WhatsApp');
                    });
                    Navigator.of(context).pop();
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[600],
                  ),
                ),
                ListTile(
                  title: Text('Facebook'),
                  onTap: () {
                    setState(() {
                      this.redSocial.value = TextEditingValue(text: 'Facebook');
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
                      this.redSocial.value =
                          TextEditingValue(text: 'Instagram');
                    });
                    Navigator.of(context).pop();
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.pinkAccent,
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<Null> seleccionarHora(BuildContext context) async {
    TimeOfDay picked;
    if (Platform.isAndroid || Platform.isFuchsia) {
      picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          this.widget.cliente.fechaEntrega.toLocal(),
        ),
      );
    } else if (Platform.isIOS) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext ctx) {
            return CupertinoTimerPicker(
              initialTimerDuration: Duration(
                hours: this.widget.cliente.fechaEntrega.toLocal().hour,
                minutes: this.widget.cliente.fechaEntrega.toLocal().minute,
                seconds: this.widget.cliente.fechaEntrega.toLocal().second,
              ),
              onTimerDurationChanged: (duration) {
                setState(() {
                  this.fechaModificada = TimeOfDay.fromDateTime(
                    DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds,
                        isUtc: true),
                  );
                });
              },
            );
          });
    }
    if (picked != null)
      setState(() {
        fechaModificada = picked;
        this.fechaEntrega = DateTime(
          this.widget.cliente.fechaEntrega.toLocal().year,
          this.widget.cliente.fechaEntrega.toLocal().month,
          int.parse(this.widget.idPedido.substring(0, 2)),
          fechaModificada.hour,
          fechaModificada.minute,
        );
        this._formKeyFecha.currentState.reset();
      });
  }

  Future<Null> actualizarCliente() async {
    if (this.validar()) {
      await this
          .fs
          .document(
              'Pedidos/${this.widget.idPedido}/Clientes/${this.widget.cliente.id}')
          .updateData({
        'TotalPago': 0,
        'NombreCliente': this.nombreCliente.text.toUpperCase(),
        'LugarEntrega': this.lugarEntrega.text,
        'RedSocial': this.redSocial.text,
        'Descripcion': this.descripcion.text,
        'FechaEntrega': this.fechaEntrega
      }).then((documento) async {
        print("Documento Actualizado!");
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
  void dispose() {
    // TODO: implement dispose
    this.nombreCliente.dispose();
    this.lugarEntrega.dispose();
    this.redSocial.dispose();
    this.descripcion.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    this.nombreCliente.value =
        TextEditingValue(text: this.widget.cliente.nombreCliente);
    this.lugarEntrega.value =
        TextEditingValue(text: this.widget.cliente.lugarEntrega);
    this.redSocial.value =
        TextEditingValue(text: this.widget.cliente.redSocial);
    this.descripcion.value =
        TextEditingValue(text: this.widget.cliente.descripcion);
    this.fechaEntrega = this.widget.cliente.fechaEntrega;
    this.fechaModificada =
        TimeOfDay.fromDateTime(this.widget.cliente.fechaEntrega.toLocal());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cliente'),
        actions: <Widget>[
          FlatButton(
            child: Text('Actualizar'),
            onPressed: () async {
              if (this.validar()) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('Actualizando Cliente.'),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    });
                await this.actualizarCliente().then((value) {
                  Navigator.of(context).pop();
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
                          controller: this.nombreCliente,
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
                          controller: this.descripcion,
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
                            : this.lugarEntrega.text,
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
                            : this.redSocial.text,
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKeyFecha,
                child: ConstrainedBox(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
