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

  DateTime fechaHoy = DateTime.now();
  TimeOfDay fechaModificada;

  String generarFechaPedidoParaBaseDeDatos(DateTime fecha) {
    return fecha.day.toString() +
        "-" +
        fecha.month.toString() +
        "-" +
        fecha.year.toString();
  }

  Future<Null> seleccionarHora(BuildContext context) async {
    TimeOfDay picked;
    if (Platform.isIOS || Platform.isIOS) {
      picked =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
    } else if (Platform.isAndroid) {
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
        this._formKeyFecha.currentState.reset();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Cliente'),
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
                          validator: (value) => value.isEmpty
                              ? 'Debe de ingresar un nombre para el cliente'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Nombre Cliente',
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
