import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class EditarMascotaPage extends StatefulWidget {
  final DocumentSnapshot mascota;

  const EditarMascotaPage({super.key, required this.mascota});

  @override
  _EditarMascotaPageState createState() => _EditarMascotaPageState();
}

class _EditarMascotaPageState extends State<EditarMascotaPage> {
  late TextEditingController _nombreController;
  late TextEditingController _tipoController;
  late TextEditingController _razaController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;
  late TextEditingController _descripcionController;

  final ImagePicker _imagePicker = ImagePicker();
  String? _imagePath; // Variable para almacenar la ruta de la nueva imagen

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.mascota['nombre']);
    _tipoController = TextEditingController(text: widget.mascota['tipo']);
    _razaController = TextEditingController(text: widget.mascota['raza']);
    _edadController = TextEditingController(text: widget.mascota['edad']);
    _pesoController = TextEditingController(text: widget.mascota['peso']);
    _descripcionController =
        TextEditingController(text: widget.mascota['descripcion']);
  }

  Future<void> _seleccionarNuevaImagen() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Error al seleccionar la nueva imagen: $e');
    }
  }

  Future<String> _subirNuevaImagen() async {
    try {
      if (_imagePath != null) {
        // Obtener referencia al storage
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('imagenes_mascotas')
            .child(
                '${widget.mascota.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Subir la nueva imagen
        await storageReference.putFile(File(_imagePath!));

        // Obtener la URL de la nueva imagen
        String nuevaImageUrl = await storageReference.getDownloadURL();
        return nuevaImageUrl;
      } else {
        return widget
            .mascota['imagen']; // Devolver la URL actual si no hay nueva imagen
      }
    } catch (e) {
      print('Error al subir la nueva imagen: $e');
      return widget
          .mascota['imagen']; // Devolver la URL actual en caso de error
    }
  }

  Future<void> _guardarCambios() async {
    try {
      // Subir la nueva imagen y obtener su URL
      String nuevaImageUrl = await _subirNuevaImagen();

      // Actualizar los campos en la base de datos
      await widget.mascota.reference.update({
        'nombre': _nombreController.text,
        'tipo': _tipoController.text,
        'raza': _razaController.text,
        'edad': _edadController.text,
        'peso': _pesoController.text,
        'descripcion': _descripcionController.text,
        'imagen': nuevaImageUrl, // Actualizar la URL de la imagen
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados correctamente'),
          duration: Duration(seconds: 2),
        ),
      );

      // Puedes agregar lógica para navegar de regreso a la lista de mascotas
      Navigator.pop(context);
    } catch (e) {
      // Manejo de errores
      print('Error al guardar cambios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Mascota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mostrar imagen actual o nueva
              _imagePath != null
                  ? Image.file(
                      File(_imagePath!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.mascota['imagen'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await _seleccionarNuevaImagen();
                },
                child: const Text('Seleccionar Nueva Imagen'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre de la Mascota'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo de Mascota'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(labelText: 'Raza'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(labelText: 'Edad'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(labelText: 'Peso'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Lógica para guardar los cambios en la base de datos
                  await _guardarCambios();
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
