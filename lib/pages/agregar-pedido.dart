import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class AgregarPedidoPage extends StatefulWidget {
  @override
  _AgregarPedidoPageState createState() => _AgregarPedidoPageState();
}

class _AgregarPedidoPageState extends State<AgregarPedidoPage> {
  List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  List<String> mesesAno = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  DateTime fechaHoy = DateTime.now();

  DateTime fechaModificada;

  String generarFechaPedido(DateTime date) {
    return diasSemana[date.weekday - 1] +
        ", " +
        date.day.toString() +
        " de ${mesesAno[date.month - 1]}";
  }

  Future<Null> seleccionarFecha(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate:
            this.fechaModificada == null ? this.fechaHoy : this.fechaModificada,
        firstDate: DateTime(
          this.fechaHoy.year,
          this.fechaHoy.month,
          this.fechaHoy.day,
        ),
        lastDate: DateTime(2101));
    if (picked != null && picked != fechaHoy)
      setState(() {
        fechaModificada = picked;
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this.fechaModificada = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Pedido'),
        actions: <Widget>[
          FlatButton(
            child: Text('Guardar'),
            onPressed: () => null,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('El pedido se agregará para la fecha:'),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                this.fechaModificada == null
                    ? this.generarFechaPedido(fechaHoy)
                    : this.generarFechaPedido(this.fechaModificada),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            RaisedButton(
              child: Text('Cambiar Fecha'),
              onPressed: () => this.seleccionarFecha(context),
              color: Colors.redAccent[100],
            )
          ],
        ),
      ),
    );
  }
}
