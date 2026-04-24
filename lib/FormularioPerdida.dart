import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:appanimales/SeleccionarUbicacionEnMapa.dart';
import 'package:intl/intl.dart';

class FormularioPerdida extends StatefulWidget {
  final String mascotaId; // Id de la mascota seleccionada

  const FormularioPerdida({super.key, required this.mascotaId});

  @override
  _FormularioPerdidaState createState() => _FormularioPerdidaState();
}

class _FormularioPerdidaState extends State<FormularioPerdida> {
  late String horaPerdida;
  late String direccionPerdida;
  late String descripcionPerdida;
  bool agregarDireccionManualmente = false;
  LatLng? ubicacionSeleccionada;
  bool agregarRecompensa = false;
  double? cantidadRecompensa;
  DateTime? fechaPerdida;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Pérdida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Complete el formulario de pérdida:'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón para seleccionar la fecha
                ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await _seleccionarFecha(context);
                    if (selectedDate != null) {
                      setState(() {
                        fechaPerdida = selectedDate;
                      });
                    }
                  },
                  child: const Text('Fecha de Pérdida'),
                ),
                // Botón para seleccionar la hora
                ElevatedButton(
                  onPressed: () async {
                    final selectedTime = await _seleccionarHora(context);
                    if (selectedTime != null) {
                      setState(() {
                        horaPerdida = selectedTime;
                      });
                    }
                  },
                  child: const Text('Hora de Pérdida'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: agregarDireccionManualmente,
                  onChanged: (value) {
                    setState(() {
                      agregarDireccionManualmente = value!;
                    });
                  },
                ),
                const Text('Agregar dirección manualmente'),
              ],
            ),
            if (!agregarDireccionManualmente)
              TextField(
                onChanged: (value) {
                  direccionPerdida = value;
                },
                decoration: const InputDecoration(labelText: 'Dirección de pérdida'),
              ),
            if (agregarDireccionManualmente)
              ElevatedButton(
                onPressed: () {
                  _seleccionarDireccionEnMapa();
                },
                child: const Text('Seleccionar dirección en el mapa'),
              ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                descripcionPerdida = value;
              },
              decoration:
                  const InputDecoration(labelText: 'Descripción de la pérdida'),
            ),
            const SizedBox(height: 20),
            // Checkbox para agregar recompensa
            Row(
              children: [
                Checkbox(
                  value: agregarRecompensa,
                  onChanged: (value) {
                    setState(() {
                      agregarRecompensa = value!;
                    });
                  },
                ),
                const Text('Agregar recompensa'),
              ],
            ),
            // Campo para ingresar la cantidad de la recompensa
            if (agregarRecompensa)
              TextField(
                onChanged: (value) {
                  cantidadRecompensa = double.tryParse(value);
                },
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Cantidad de recompensa'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _generarAlerta();
              },
              child: const Text('Generar Alerta'),
            ),
          ],
        ),
      ),
    );
  }

  void _seleccionarDireccionEnMapa() async {
    final LatLng? ubicacionSeleccionadaNueva = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeleccionarUbicacionEnMapa(),
      ),
    );

    if (ubicacionSeleccionadaNueva != null) {
      setState(() {
        ubicacionSeleccionada = ubicacionSeleccionadaNueva;
      });
    }
  }

  void _generarAlerta() async {
    try {
      DocumentReference mascotaRef = FirebaseFirestore.instance
          .collection('mascotas')
          .doc(widget.mascotaId);

      DocumentSnapshot mascotaSnapshot = await mascotaRef.get();
      if (mascotaSnapshot.exists) {
        if (mascotaSnapshot['perdida'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta mascota ya está marcada como perdida.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          await mascotaRef.update({
            'perdida': true,
            'horaPerdida': horaPerdida,
            'descripcionPerdida': descripcionPerdida,
            if (!agregarDireccionManualmente)
              'direccionPerdida': direccionPerdida,
            if (ubicacionSeleccionada != null)
              'ubicacionPerdida': {
                'latitude': ubicacionSeleccionada!.latitude,
                'longitude': ubicacionSeleccionada!.longitude,
              },
            'recompensa': agregarRecompensa ? cantidadRecompensa : null,
            'fechaPerdida': fechaPerdida != null
                ? DateFormat('yyyy-MM-dd').format(fechaPerdida!)
                : null,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta generada correctamente.'),
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pop(context);
        }
      }
    } catch (error) {
      print('Error al generar la alerta: $error');
    }
  }

  Future<DateTime?> _seleccionarFecha(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
  }

  Future<String?> _seleccionarHora(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      return selectedTime.format(context);
    }

    return null;
  }
}
