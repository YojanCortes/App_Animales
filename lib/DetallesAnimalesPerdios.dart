import 'package:appanimales/ChatPage.dart';
import 'package:appanimales/MapaGoogleUnico.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'GoogleMap.dart'; // Importa tu archivo GoogleMap.dart aquí

class DetallesAnimalesPerdidos extends StatefulWidget {
  final Map<String, dynamic> ubicacionPerdida;
  final String nombre;
  final String horaPerdida;
  final String fechaPerdida;
  final String descripcion;
  final String imageUrl;
  final double? recompensa;
  final String nombreUsuario;
  final String idMascota;

  const DetallesAnimalesPerdidos({super.key, 
    required this.ubicacionPerdida,
    required this.nombre,
    required this.horaPerdida,
    required this.fechaPerdida,
    required this.descripcion,
    required this.imageUrl,
    this.recompensa,
    required this.nombreUsuario,
    required this.idMascota,
  });

  @override
  _DetallesAnimalesPerdidosState createState() =>
      _DetallesAnimalesPerdidosState();
}

class _DetallesAnimalesPerdidosState extends State<DetallesAnimalesPerdidos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombre,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.network(widget.imageUrl, width: 150, height: 150),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDetalle('Hora de Pérdida', _formatHoraPerdida()),
            _buildDetalle('Fecha de Pérdida', widget.fechaPerdida),
            _buildDetalle('Descripción', widget.descripcion),
            _buildRecompensa(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _mostrarDialogoContactar(context);
              },
              child: Text('Hablar con el Dueño (${widget.nombreUsuario})'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _mostrarEnMapa(context);
                    },
                    child: const Text('Mostrar en el Mapa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHoraPerdida() {
    try {
      DateTime parsedTime = DateFormat.jm().parse(widget.horaPerdida);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return widget.horaPerdida;
    }
  }

  Widget _buildDetalle(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRecompensa() {
    return widget.recompensa != null
        ? Container(
            color: Colors.amber,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.attach_money),
                const SizedBox(width: 5),
                Text('Recompensa: \$${widget.recompensa!.toString()}'),
              ],
            ),
          )
        : Container();
  }

  void _mostrarDialogoContactar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contactar al Dueño'),
          content: Text(
            'Puedes contactar al dueño del animal (${widget.nombreUsuario}) a través de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                print('Nombre de usuario: ${widget.nombreUsuario}');
                _navigateToChatPage(widget.nombreUsuario, widget.idMascota);
              },
              child: const Text('Hablar'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToChatPage(String nombreUsuario, String idMascota) {
    if (nombreUsuario.isNotEmpty && idMascota.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            nombreUsuario: nombreUsuario,
            idMascota: idMascota,
          ),
        ),
      );
    } else {
      print('Error: nombreUsuario o idMascota está vacío.');
    }
  }

  void _mostrarEnMapa(BuildContext context) {
    if (widget.ubicacionPerdida['latitude'] != null &&
        widget.ubicacionPerdida['longitude'] != null) {
      double latitude = widget.ubicacionPerdida['latitude'];
      double longitude = widget.ubicacionPerdida['longitude'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapaGoogleUnico(
            ubicacion: LatLng(latitude, longitude),
          ),
        ),
      );
    } else {
      print('Error: La ubicación es nula.');
    }
  }
}
