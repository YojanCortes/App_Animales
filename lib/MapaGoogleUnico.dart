import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaGoogleUnico extends StatefulWidget {
  final LatLng ubicacion;

  const MapaGoogleUnico({super.key, required this.ubicacion});

  @override
  State<MapaGoogleUnico> createState() => _MapaGoogleUnicoState();
}

class _MapaGoogleUnicoState extends State<MapaGoogleUnico> {
  List<AnimalData> animals = [];
  double radioSeleccionado = 200.0;
  double zoomLevel = 1.0;
  double panX = 0.0;
  double panY = 0.0;
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadLostAnimals();
  }

  Future<void> _loadLostAnimals() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('mascotas')
          .where('perdida', isEqualTo: true)
          .get();

      List<AnimalData> loadedAnimals = [];

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        if (document['ubicacionPerdida'] != null) {
          Map<String, dynamic> ubicacionPerdida = document['ubicacionPerdida'];
          double latitude = ubicacionPerdida['latitude'];
          double longitude = ubicacionPerdida['longitude'];

          double distancia = Geolocator.distanceBetween(
            widget.ubicacion.latitude,
            widget.ubicacion.longitude,
            latitude,
            longitude,
          );

          if (distancia <= radioSeleccionado) {
            loadedAnimals.add(
              AnimalData(
                id: document.id,
                nombre: document['nombre'] ?? 'Animal Perdido',
                imagen: document['imagen'] ?? '',
                latitude: latitude,
                longitude: longitude,
                distancia: distancia,
                descripcion: document['descripcion'] ?? '',
                edad: document['edad'] ?? '',
                fechaPerdida: document['fechaPerdida'] ?? '',
                horaPerdida: document['horaPerdida'] ?? '',
                raza: document['raza'] ?? '',
                peso: document['peso'] ?? '',
                tipo: document['tipo'] ?? '',
                descripcionPerdida: document['descripcionPerdida'] ?? '',
                nombreUsuario: document['nombreUsuario'] ?? '',
                recompensa: document['recompensa']?.toDouble(),
                ubicacionPerdida: ubicacionPerdida,
                document: document,
              ),
            );
          }
        }
      }

      setState(() {
        animals = loadedAnimals;
        lastUpdate = DateTime.now();
      });
    } catch (e) {
      print('Error loading lost animals: $e');
    }
  }

  String _getRadioText() {
    if (radioSeleccionado == double.infinity) return 'Todos';
    if (radioSeleccionado >= 1000) {
      return '${(radioSeleccionado / 1000).toStringAsFixed(0)}km';
    }
    return '${radioSeleccionado.toStringAsFixed(0).replaceAll('.0', '')}m';
  }

  String _getRelativeTime() {
    Duration diff = DateTime.now().difference(lastUpdate);
    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    }
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    }
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text('Perdí mi mascota', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                panX += details.delta.dx;
                panY += details.delta.dy;
              });
            },
            child: CustomPaint(
              painter: GridMapPainter(
                animals: animals,
                userLocation: widget.ubicacion,
                zoom: zoomLevel,
                panX: panX,
                panY: panY,
                radioSeleccionado: radioSeleccionado,
              ),
              size: Size.infinite,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.greenAccent,
                  elevation: 0,
                  onPressed: () {
                    setState(() {
                      zoomLevel += 0.2;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.greenAccent,
                  elevation: 0,
                  onPressed: () {
                    setState(() {
                      zoomLevel = (zoomLevel - 0.2).clamp(0.5, 3.0);
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mascotas cercanas',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.greenAccent, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${animals.length} en ${_getRadioText()}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Última actualización',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        _getRelativeTime(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton('200m', 200.0),
                        const SizedBox(width: 8),
                        _buildFilterButton('500m', 500.0),
                        const SizedBox(width: 8),
                        _buildFilterButton('1km', 1000.0),
                        const SizedBox(width: 8),
                        _buildFilterButton('5km', 5000.0),
                        const SizedBox(width: 8),
                        _buildFilterButton('Ver Todos', double.infinity),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (animals.isNotEmpty)
            Positioned(
              bottom: 250,
              left: 16,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    border: Border.all(color: Colors.greenAccent, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.grid_view_rounded, color: Colors.grey, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Ver lista completa',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, double value) {
    bool isSelected = radioSeleccionado == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          radioSeleccionado = value;
        });
        _loadLostAnimals();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AnimalData {
  final String id;
  final String nombre;
  final String imagen;
  final double latitude;
  final double longitude;
  final double distancia;
  final String descripcion;
  final String edad;
  final String fechaPerdida;
  final String horaPerdida;
  final String raza;
  final String peso;
  final String tipo;
  final String descripcionPerdida;
  final String nombreUsuario;
  final double? recompensa;
  final Map<String, dynamic> ubicacionPerdida;
  final QueryDocumentSnapshot document;

  AnimalData({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.latitude,
    required this.longitude,
    required this.distancia,
    required this.descripcion,
    required this.edad,
    required this.fechaPerdida,
    required this.horaPerdida,
    required this.raza,
    required this.peso,
    required this.tipo,
    required this.descripcionPerdida,
    required this.nombreUsuario,
    required this.recompensa,
    required this.ubicacionPerdida,
    required this.document,
  });
}

class GridMapPainter extends CustomPainter {
  final List<AnimalData> animals;
  final LatLng userLocation;
  final double zoom;
  final double panX;
  final double panY;
  final double radioSeleccionado;

  GridMapPainter({
    required this.animals,
    required this.userLocation,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.radioSeleccionado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2 + panX;
    final centerY = size.height / 2 + panY;
    final gridSize = 50.0 * zoom;

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (double x = -gridSize * 5; x < size.width + gridSize * 5; x += gridSize) {
      canvas.drawLine(
        Offset(centerX + x, 0),
        Offset(centerX + x, size.height),
        gridPaint,
      );
    }

    for (double y = -gridSize * 5; y < size.height + gridSize * 5; y += gridSize) {
      canvas.drawLine(
        Offset(0, centerY + y),
        Offset(size.width, centerY + y),
        gridPaint,
      );
    }

    // Draw center circle for user
    final userCirclePaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(centerX, centerY), 40 * zoom, userCirclePaint);

    // Draw animals
    const pixelsPerMeter = 0.5;

    for (var animal in animals) {
      final deltaLat = animal.latitude - userLocation.latitude;
      final deltaLng = animal.longitude - userLocation.longitude;

      final x = centerX + (deltaLng * 111000 * pixelsPerMeter * zoom);
      final y = centerY + (deltaLat * 111000 * pixelsPerMeter * zoom);

      // Draw animal marker circle
      final markerPaint = Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(x, y), 30 * zoom, markerPaint);

      // Draw animal icon background
      final bgPaint = Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 20 * zoom, bgPaint);

      // Draw animal emoji/icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: animal.tipo?.toLowerCase().contains('gato') ?? false ? '🐱' : '🐕',
          style: TextStyle(fontSize: 20 * zoom),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Draw distance label
      final distanceLabel = animal.distancia < 1000
          ? '${animal.distancia.toStringAsFixed(0).replaceAll('.0', '')}m'
          : '${(animal.distancia / 1000).toStringAsFixed(1)}km';

      final distancePainter = TextPainter(
        text: TextSpan(
          text: '${animal.nombre} - $distanceLabel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      distancePainter.layout();
      distancePainter.paint(
        canvas,
        Offset(x - distancePainter.width / 2, y + 35 * zoom),
      );
    }
  }

  @override
  bool shouldRepaint(GridMapPainter oldDelegate) {
    return oldDelegate.animals != animals ||
        oldDelegate.zoom != zoom ||
        oldDelegate.panX != panX ||
        oldDelegate.panY != panY;
  }
}
