import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class AgregarClientePage extends StatefulWidget {
  AgregarClientePage({this.idPedido});

  final String idPedido;

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

  Future<Null> seleccionarHora(BuildContext context) async {
    TimeOfDay picked;
    if (Platform.isAndroid || Platform.isFuchsia) {
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
          int.parse(this.widget.idPedido.substring(0, 2)),
          fechaModificada.hour,
          fechaModificada.minute,
        );
        this._formKeyFecha.currentState.reset();
      });
  }

  Future<Null> agregarCliente() async {
    if (this.validar()) {
      await this.fs.collection('Pedidos/${this.widget.idPedido}/Clientes').add({
        'CantidadProductos': 0,
        'Compras': [],
        'TotalPago': 0,
        'NombreCliente': this.nombreCliente.toUpperCase(),
        'LugarEntrega': this.lugarEntrega.toUpperCase(),
        'RedSocial': this.redSocial.toUpperCase(),
        'Descripcion': this.descripcion,
        'FechaEntrega': this.fechaEntrega
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Cliente'),
        actions: <Widget>[
          FlatButton(
            child: Text('Guardar'),
            onPressed: () async {
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
                          keyboardType: TextInputType.text,
                          enabled: true,
                          autofocus: false,
                          onSaved: (value) => this.lugarEntrega = value,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar un lugar de entrega'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Lugar Entrega',
                            hasFloatingPlaceholder: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          enabled: true,
                          autofocus: false,
                          onSaved: (value) => this.redSocial = value,
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar una red social'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Red Social',
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
