import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editarMascota.dart';
import 'formularioPerdida.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MisMascotasPage extends StatefulWidget {
  final bool seleccionarPerdida;

  const MisMascotasPage({super.key, required this.seleccionarPerdida});

  @override
  _MisMascotasPageState createState() => _MisMascotasPageState();
}

class _MisMascotasPageState extends State<MisMascotasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
      ),
      body: _buildMascotasList(),
    );
  }

  Widget _buildMascotasList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('mascotas')
          .where('idUsuario', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var mascotas = snapshot.data?.docs;
        List<Widget> mascotasWidgets = [];

        for (var mascota in mascotas!) {
          var nombre = mascota['nombre'];
          var tipo = mascota['tipo'];
          var raza = mascota['raza'];

          var iconoMascota = tipo == 'Perro'
              ? Image.asset('assets/perro.jpeg', width: 24, height: 24)
              : Image.asset('assets/gato.jpeg', width: 24, height: 24);

          var mascotaWidget = ListTile(
            leading: iconoMascota,
            title: Text(nombre),
            subtitle: Text('Tipo: $tipo - Raza: $raza'),
            tileColor: mascota['perdida'] ? Colors.red.withOpacity(0.3) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de Edición
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditarMascotaPage(mascota: mascota),
                      ),
                    );
                  },
                ),
                // Botón de Eliminación
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _mostrarDialogoConfirmacion(mascota);
                  },
                ),
                // Botón para marcar como perdida
                if (widget.seleccionarPerdida)
                  IconButton(
                    icon: const Icon(Icons.warning),
                    onPressed: () {
                      _irAFormularioPerdida(mascota.id);
                    },
                  ),
                // Botón para marcar como no perdida
                if (widget.seleccionarPerdida)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      _marcarComoNoPerdida(mascota.id);
                    },
                  ),
              ],
            ),
          );

          mascotasWidgets.add(mascotaWidget);
        }

        return ListView(
          children: mascotasWidgets,
        );
      },
    );
  }

  Future<void> _mostrarDialogoConfirmacion(DocumentSnapshot mascota) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Mascota'),
          content: const Text('¿Estás seguro de que quieres eliminar esta mascota?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _eliminarMascota(mascota.id);
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarMascota(String mascotaId) {
    FirebaseFirestore.instance.collection('mascotas').doc(mascotaId).delete();
  }

  void _irAFormularioPerdida(String mascotaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioPerdida(mascotaId: mascotaId),
      ),
    );
  }

  void _marcarComoNoPerdida(String mascotaId) {
    FirebaseFirestore.instance
        .collection('mascotas')
        .doc(mascotaId)
        .update({'perdida': false});
    // Puedes agregar aquí lógica adicional si es necesario
  }
}
