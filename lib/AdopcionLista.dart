import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'detalles_de_adopcion.dart';

class ListaAnimalesAdopcion extends StatelessWidget {
  const ListaAnimalesAdopcion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Animales en Adopción'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('animales_adopcion')
            .orderBy('fechaPublicacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          }
          if (snapshot.hasError) {
            return _buildError(context);
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmpty(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;
              return _AdopcionCard(animal: data);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text('Error al cargar',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💚', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No hay animales en adopción',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('¡Sé el primero en publicar!',
              style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AdopcionCard extends StatelessWidget {
  final Map<String, dynamic> animal;

  const _AdopcionCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = (animal['imagenes'] != null &&
            (animal['imagenes'] as List).isNotEmpty)
        ? animal['imagenes'][0] as String
        : '';
    final nombre = animal['nombre'] as String? ?? 'Sin nombre';
    final edad = animal['edad']?.toString() ?? '';
    final tipoEdad = animal['tipoEdad'] as String? ?? '';
    final peso = animal['peso']?.toString() ?? '';
    final tipoPeso = animal['tipoPeso'] as String? ?? '';
    final esterilizado = animal['esterilizado'];
    final isEsterilizado =
        esterilizado == true || esterilizado == 'Sí' || esterilizado == 'si';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetallesDeAdopcion(adopcion: animal)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.pets_rounded,
                            color: Colors.grey, size: 40),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 140,
                        color: colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.pets_rounded,
                            color: colorScheme.primary, size: 40),
                      ),
                    )
                  : Container(
                      height: 140,
                      color: colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.pets_rounded,
                          color: colorScheme.primary, size: 40),
                    ),
            ),

            // Datos
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (edad.isNotEmpty)
                    Text(
                      '$edad $tipoEdad',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  if (peso.isNotEmpty)
                    Text(
                      '$peso $tipoPeso',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  const SizedBox(height: 8),
                  // Badge esterilizado
                  if (isEsterilizado)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 12, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Esterilizado',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
