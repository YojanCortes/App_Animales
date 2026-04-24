// detalles_animales_adopcion.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class DetallesAnimalesAdopcion extends StatefulWidget {
  final Map<String, dynamic> animal;

  const DetallesAnimalesAdopcion({super.key, required this.animal});

  @override
  _DetallesAnimalesAdopcionState createState() =>
      _DetallesAnimalesAdopcionState();
}

class _DetallesAnimalesAdopcionState extends State<DetallesAnimalesAdopcion> {
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;
  bool _esterilizado = false;
  final List<File> _nuevasImagenes = [];
  String nuevaImageUrl = "";

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.animal['nombre'] ?? '');
    _edadController = TextEditingController(text: widget.animal['edad'] ?? '');
    _pesoController = TextEditingController(text: widget.animal['peso'] ?? '');
    _esterilizado = widget.animal['esterilizado'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Animal en Adopción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre:'),
            TextField(
              controller: _nombreController,
            ),
            const SizedBox(height: 16),
            const Text('Edad:'),
            TextField(
              controller: _edadController,
            ),
            const SizedBox(height: 16),
            const Text('Peso:'),
            TextField(
              controller: _pesoController,
            ),
            const SizedBox(height: 16),
            _buildCheckbox('Esterilizado', _esterilizado, (value) {
              setState(() {
                _esterilizado = value ?? false;
              });
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _mostrarOpcionesFoto();
              },
              child: const Text('Cambiar Imagen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _guardarCambios();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }

  Future<void> _mostrarOpcionesFoto() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Fuente de Fotos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _tomarFoto();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Foto tomada correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Tomar Foto'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _seleccionarFoto();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fotos seleccionadas correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Seleccionar desde Galería'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _nuevasImagenes.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _nuevasImagenes.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error al seleccionar la foto: $e');
    }
  }

  Future<void> _subirNuevaImagen() async {
    try {
      if (_nuevasImagenes.isNotEmpty) {
        final firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('imagenes_mascotas')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        for (var nuevaImagen in _nuevasImagenes) {
          await storageReference.putFile(nuevaImagen);
          nuevaImageUrl = await storageReference.getDownloadURL();
        }
      }
    } catch (e) {
      print('Error al subir la nueva imagen: $e');
    }
  }

  void _guardarCambios() async {
    try {
      await _subirNuevaImagen();

      final animalId = widget.animal['id'];

      // Verificar si el documento existe antes de intentar actualizarlo
      final existingDoc = await FirebaseFirestore.instance
          .collection('animales_adopcion')
          .doc(animalId)
          .get();

      if (existingDoc.exists) {
        await FirebaseFirestore.instance
            .collection('animales_adopcion')
            .doc(animalId)
            .update({
          'nombre': _nombreController.text,
          'edad': _edadController.text,
          'peso': _pesoController.text,
          'esterilizado': _esterilizado,
          'imagenes': nuevaImageUrl.isNotEmpty
              ? [nuevaImageUrl]
              : widget.animal['imagenes'],
          // Otros campos que desees actualizar...
        });

        Navigator.pop(context, {'animalActualizado': true});
      } else {
        print('Error: El documento no existe en Firestore. ID: $animalId');
      }
    } catch (e) {
      print('Error al guardar cambios: $e');
      // Mostrar mensaje de error al usuario o realizar alguna acción adicional.
    }
  }
}
