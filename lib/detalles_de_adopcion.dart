import 'package:flutter/material.dart';

class DetallesDeAdopcion extends StatelessWidget {
  final Map<String, dynamic> adopcion;

  const DetallesDeAdopcion({super.key, required this.adopcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Adopción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${adopcion['nombre']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text('Edad: ${adopcion['edad']} ${adopcion['tipoEdad']}'),
            Text('Esterilizado: ${adopcion['esterilizado']}'),
            Text('Peso: ${adopcion['peso']} ${adopcion['tipoPeso']}'),

            // Mostrar imágenes en una cuadrícula
            if (adopcion['imagenes'] != null && adopcion['imagenes'].length > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Imágenes:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: adopcion['imagenes'].length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _mostrarImagenEnGrande(
                                context, adopcion['imagenes'][index]);
                          },
                          child: Image.network(
                            adopcion['imagenes'][index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            // Botón para hablar con el dueño
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para iniciar una conversación con el dueño
                // Puedes usar algún servicio de mensajería o implementar tu propio flujo de chat.
              },
              child: const Text('Hablar con el dueño'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarImagenEnGrande(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
