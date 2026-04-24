import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class MascotasPage extends StatefulWidget {
  const MascotasPage({super.key});

  @override
  _MascotasPageState createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  final List<String> tiposAnimales = ['Todos', 'Perro', 'Gato'];
  String tipoSeleccionado = 'Todos';
  DateTime? fechaSeleccionada;

  // Stream activo (se actualiza cuando cambian los filtros)
  Stream<QuerySnapshot> _buildStream() {
    Query query = FirebaseFirestore.instance
        .collection('mascotas')
        .where('perdida', isEqualTo: true)
        .orderBy('fechaPerdida', descending: true);

    if (tipoSeleccionado != 'Todos') {
      query = query.where('tipo', isEqualTo: tipoSeleccionado);
    }
    return query.snapshots();
  }

  void _mostrarMenuFiltros() {
    String tempTipo = tipoSeleccionado;
    DateTime? tempFecha = fechaSeleccionada;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Filtrar mascotas',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),

                Text('Tipo de animal',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: tiposAnimales
                      .map((tipo) => ChoiceChip(
                            label: Text(tipo),
                            selected: tempTipo == tipo,
                            onSelected: (_) =>
                                setModalState(() => tempTipo = tipo),
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 20),
                Text('Fecha de pérdida',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => tempFecha = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_outlined,
                          size: 18),
                      label: Text(tempFecha != null
                          ? '${tempFecha!.day}/${tempFecha!.month}/${tempFecha!.year}'
                          : 'Seleccionar fecha'),
                    ),
                    if (tempFecha != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () =>
                            setModalState(() => tempFecha = null),
                      ),
                    ]
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            tipoSeleccionado = 'Todos';
                            fechaSeleccionada = null;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            tipoSeleccionado = tempTipo;
                            fechaSeleccionada = tempFecha;
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mascotas Perdidas'),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _mostrarMenuFiltros,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filtros',
              ),
              if (tipoSeleccionado != 'Todos' || fechaSeleccionada != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _buildStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList();
          }

          if (snapshot.hasError) {
            return _buildError();
          }

          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          // Filtrar por fecha localmente (Firestore no soporta múltiples filtros en rangos)
          if (fechaSeleccionada != null) {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final fechaStr = data['fechaPerdida'] as String? ?? '';
              try {
                final fecha = DateTime.parse(fechaStr);
                return fecha.year == fechaSeleccionada!.year &&
                    fecha.month == fechaSeleccionada!.month &&
                    fecha.day == fechaSeleccionada!.day;
              } catch (_) {
                return false;
              }
            }).toList();
          }

          if (docs.isEmpty) {
            return _buildEmpty();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) =>
                _MascotaPerdidaCard(doc: docs[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text('Error al cargar', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐾', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No hay mascotas perdidas',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            tipoSeleccionado != 'Todos' || fechaSeleccionada != null
                ? 'Prueba con otros filtros'
                : 'Todo está en orden 🎉',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _MascotaPerdidaCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _MascotaPerdidaCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final nombre = data['nombre'] as String? ?? 'Sin nombre';
    final tipo = data['tipo'] as String? ?? '';
    final ubicacion =
        data['ultimaDireccionVista'] as String? ?? 'Ubicación no disponible';
    final hora = data['horaPerdida'] as String? ?? '';
    final fecha = data['fechaPerdida'] as String? ?? '';
    final descripcion =
        data['descripcion'] as String? ?? '';
    final imageUrl = data['imagen'] as String? ?? '';
    final nombreUsuario =
        data['nombreUsuario'] as String? ?? 'Dueño desconocido';
    final tieneRecompensa = data['recompensa'] != null;
    final recompensa =
        tieneRecompensa ? (data['recompensa'] as num).toDouble() : 0.0;

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetallesAnimalesPerdidos(
              ubicacionPerdida:
                  data['ubicacionPerdida'] as Map<String, dynamic>? ?? {},
              nombre: nombre,
              horaPerdida: hora,
              fechaPerdida: fecha,
              descripcion: descripcion,
              imageUrl: imageUrl,
              recompensa: recompensa,
              nombreUsuario: nombreUsuario,
              idMascota: doc.id,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 88,
                          height: 88,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.pets_rounded,
                              color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 88,
                          height: 88,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.pets_rounded,
                              color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 88,
                        height: 88,
                        color: colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.pets_rounded,
                            color: colorScheme.primary, size: 36),
                      ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(nombre,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (tipo.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tipo,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(ubicacion,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    if (fecha.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            hora.isNotEmpty ? '$fecha · $hora' : fecha,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('@$nombreUsuario',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey)),
                        if (tieneRecompensa) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC535),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_money_rounded,
                                    size: 13, color: Colors.black87),
                                Text(
                                  recompensa.toStringAsFixed(0),
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
