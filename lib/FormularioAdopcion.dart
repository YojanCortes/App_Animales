import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class FormularioAdopcion extends StatefulWidget {
  const FormularioAdopcion({super.key});

  @override
  _FormularioAdopcionState createState() => _FormularioAdopcionState();
}

class _FormularioAdopcionState extends State<FormularioAdopcion> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  String _tipoEdad = 'Días';
  String _tipoPeso = 'Kilogramos';
  bool _esterilizado = false;
  bool _noSabeEsterilizado = false;
  final List<File> _imagenes = [];

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  void _guardarInformacion() async {
    try {
      // Verificar que los campos requeridos estén completos
      if (_nombreController.text.isEmpty ||
          _edadController.text.isEmpty ||
          _pesoController.text.isEmpty ||
          _imagenes.isEmpty) {
        print(
            'Por favor, complete todos los campos y seleccione al menos una imagen.');
        return;
      }

      // Obtener el ID del usuario actual
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Si el usuario no está autenticado, no podemos guardar la información de la mascota
      if (userId == null) {
        print('El usuario no está autenticado.');
        return;
      }

      // Obtener una referencia a la colección 'animales_adopcion' en Firestore
      CollectionReference animalesAdopcionCollection =
          FirebaseFirestore.instance.collection('animales_adopcion');

      // Subir imágenes a Firebase Storage y obtener las URLs
      List<String> urls = await _subirImagenes();

      // Agregar la información a Firestore en la colección 'animales_adopcion'
      await animalesAdopcionCollection.add({
        'nombre': _nombreController.text,
        'edad': _edadController.text,
        'tipoEdad': _tipoEdad,
        'peso': _pesoController.text,
        'tipoPeso': _tipoPeso,
        'esterilizado': _esterilizado,
        'noSabeEsterilizado': _noSabeEsterilizado,
        'imagenes': urls,
        'propietario': userId,
        // Otros campos que desees agregar...
      });

      // Mensaje de éxito
      print(
          'Información guardada correctamente en la colección "animales_adopcion".');

      // Limpiar campos después de guardar la información
      _limpiarCampos();
    } catch (e) {
      // Manejo de errores
      print('Error al guardar la información en Firestore: $e');
    }
  }

  Future<List<String>> _subirImagenes() async {
    try {
      List<String> urls = [];

      // Subir cada imagen y obtener la URL
      for (File imagen in _imagenes) {
        final firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('imagenes_mascotas')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        // Subir la imagen
        await storageReference.putFile(imagen);

        // Obtener la URL de la imagen
        String imageUrl = await storageReference.getDownloadURL();
        urls.add(imageUrl);
      }

      return urls;
    } catch (e) {
      // Manejo de errores
      print('Error al subir imágenes a Firebase Storage: $e');
      return [];
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagenes.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imagenes.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      print('Error al seleccionar la foto: $e');
    }
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _edadController.clear();
    _pesoController.clear();
    _tipoEdad = 'Días';
    _tipoPeso = 'Kilogramos';
    _esterilizado = false;
    _noSabeEsterilizado = false;
    _imagenes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Adopción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nombreController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre de la mascota';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Nombre de la Mascota'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _edadController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese la edad de la mascota';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Edad'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _tipoEdad,
                    items: ['Días', 'Semanas', 'Años'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoEdad = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pesoController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el peso de la mascota';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Peso'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _tipoPeso,
                    items: ['Kilogramos', 'Gramos'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoPeso = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _esterilizado,
                    onChanged: (value) {
                      setState(() {
                        _esterilizado = value!;
                        // Desmarcar la opción 'No sé si está esterilizado' si se selecciona 'Está esterilizado'
                        if (_esterilizado) {
                          _noSabeEsterilizado = false;
                        }
                      });
                    },
                  ),
                  const Text('¿Está esterilizado?'),
                  const SizedBox(width: 10),
                  Checkbox(
                    value: _noSabeEsterilizado,
                    onChanged: (value) {
                      setState(() {
                        _noSabeEsterilizado = value!;
                        // Desmarcar la opción 'Está esterilizado' si se selecciona 'No sé si está esterilizado'
                        if (_noSabeEsterilizado) {
                          _esterilizado = false;
                        }
                      });
                    },
                  ),
                  const Text('No sé si está esterilizado'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _mostrarOpcionesFoto();
                },
                child: const Text('Tomar o Seleccionar Fotos'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarInformacion,
                child: const Text('Guardar Información'),
              ),
            ],
          ),
        ),
      ),
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
}
