import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nombreUsuarioActual;
  final String correoActual;
  final String telefonoActual;
  final String direccionActual;
  final String nombreCompletoActual;

  const EditarPerfilPage({super.key, 
    required this.nombreUsuarioActual,
    required this.correoActual,
    required this.telefonoActual,
    required this.direccionActual,
    required this.nombreCompletoActual,
  });

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _passwordController;
  late TextEditingController _repeatPasswordController;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.nombreCompletoActual);
    _correoController = TextEditingController(text: widget.correoActual);
    _telefonoController = TextEditingController(text: widget.telefonoActual);
    _direccionController = TextEditingController(text: widget.direccionActual);
    _passwordController = TextEditingController();
    _repeatPasswordController = TextEditingController();
  }

  void _guardarCambios() async {
    // Lógica para guardar los cambios en el perfil
    String nuevoNombreCompleto = _nombreController.text;
    String nuevoCorreo = _correoController.text;
    String nuevoTelefono = _telefonoController.text;
    String nuevaDireccion = _direccionController.text;
    String nuevaContrasena = _passwordController.text;
    String repetirContrasena = _repeatPasswordController.text;

    // Validar que las contraseñas coincidan si se están modificando
    if (nuevaContrasena.isNotEmpty || repetirContrasena.isNotEmpty) {
      if (nuevaContrasena != repetirContrasena) {
        // Las contraseñas no coinciden, puedes manejar esto según tu lógica
        print('Las contraseñas no coinciden');
        return;
      }
    }

    // Obtener el ID del usuario actual
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Validar que el ID del usuario no esté vacío
    if (userId.isEmpty) {
      print('Error: No se pudo obtener el ID del usuario actual.');
      return;
    }

    // Actualizar el documento en Firestore
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .update({
        'nombreCompleto': nuevoNombreCompleto,
        'correo': nuevoCorreo,
        'telefono': nuevoTelefono,
        'direccion': nuevaDireccion,
        // Agregar la actualización de la contraseña si es necesario
      });

      // Una vez que hayas guardado los cambios, puedes navegar de nuevo a la página de Menú
      Navigator.pop(context);
    } catch (error) {
      print('Error al actualizar el perfil: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nombre de Usuario: ${widget.nombreUsuarioActual}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nuevo Nombre Completo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _correoController,
              decoration:
                  const InputDecoration(labelText: 'Nuevo Correo Electrónico'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: 'Nuevo Teléfono'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(labelText: 'Nueva Dirección'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _repeatPasswordController,
              decoration:
                  const InputDecoration(labelText: 'Repetir Nueva Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
