import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appanimales/theme/app_theme.dart';

class GoogleMapPage extends StatefulWidget {
  final LatLng initialPosition;

  const GoogleMapPage({super.key, required this.initialPosition});

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Position? currentPosition;
  double radioSeleccionado = 200.0;
  DateTime lastUpdate = DateTime.now();
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermissions();
  }

  _checkAndRequestLocationPermissions() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      await Permission.location.request();
    }
  }

  _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
      });

      await _loadLostAnimals();

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );
    } catch (e) {
      print('Error obtaining location: $e');
    }
  }

  _loadLostAnimals() async {
    try {
      markers.clear();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('mascotas')
          .where('perdida', isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        if (document['ubicacionPerdida'] != null) {
          Map<String, dynamic> ubicacionPerdida = document['ubicacionPerdida'];
          double latitude = ubicacionPerdida['latitude'];
          double longitude = ubicacionPerdida['longitude'];

          double distancia = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            latitude,
            longitude,
          );

          if (distancia <= radioSeleccionado) {
            markers.add(
              Marker(
                markerId: MarkerId(document.id),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(
                  title: document['nombre'] ?? 'Animal Perdido',
                  snippet: document['descripcionPerdida'] ?? '',
                  onTap: () {
                    _showAnimalDetailsPopup(context, document);
                  },
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            );
          }
        }
      }

      setState(() {
        lastUpdate = DateTime.now();
      });
    } catch (e) {
      print('Error loading lost animals: $e');
    }
  }

  String _getRelativeTime() {
    Duration diff = DateTime.now().difference(lastUpdate);
    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
  }

  String _getRadioText() {
    if (radioSeleccionado == double.infinity) return 'Todos';
    if (radioSeleccionado >= 1000) return '${(radioSeleccionado / 1000).toStringAsFixed(0)}km';
    return '${radioSeleccionado.toStringAsFixed(0).replaceAll('.0', '')}m';
  }

  void _showAnimalDetailsPopup(
      BuildContext context, QueryDocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document['nombre'] ?? 'Animal Perdido',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Image.network(
                  document['imagen'] ?? '',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10.0),
                Text('Descripción: ${document['descripcion'] ?? ''}'),
                Text('Edad: ${document['edad'] ?? ''}'),
                Text('Fecha de Pérdida: ${document['fechaPerdida'] ?? ''}'),
                Text('Hora de Pérdida: ${document['horaPerdida'] ?? ''}'),
                Text('Raza: ${document['raza'] ?? ''}'),
                Text('Peso: ${document['peso'] ?? ''}'),
                Text('Tipo: ${document['tipo'] ?? ''}'),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToDetailsPage(document);
                  },
                  child: const Text('Ver Detalles'),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToDetailsPage(QueryDocumentSnapshot document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallesAnimalesPerdidos(
          ubicacionPerdida: document['ubicacionPerdida'],
          nombre: document['nombre'] ?? '',
          nombreUsuario: document['nombreUsuario'] ?? '',
          horaPerdida: document['horaPerdida'] ?? '',
          fechaPerdida: document['fechaPerdida'] ?? '',
          descripcion: document['descripcion'] ?? '',
          imageUrl: document['imagen'] ?? '',
          recompensa: document['recompensa']?.toDouble(),
          idMascota: document.id, // Asigna el ID del documento como idMascota
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, double value) {
    bool isSelected = radioSeleccionado == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            radioSeleccionado = value;
          });
          _loadLostAnimals();
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent : Colors.transparent,
            border: Border.all(color: isSelected ? AppTheme.accent : AppTheme.borderLight, width: 1.5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              if (isSelected) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.bgDeep, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.dmSans(
                  color: isSelected ? AppTheme.bgDeep : AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final String _mapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#132b1e"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#7fc4a0"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#0a1810"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#1b3d2c"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#265038"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#0a1810"}]
    }
  ]
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Mapa principal
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: widget.initialPosition,
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  mapType: _currentMapType,
                  markers: markers,
                  circles: currentPosition != null
                      ? {
                          Circle(
                            circleId: const CircleId('radius'),
                            center: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                            radius: radioSeleccionado,
                            fillColor: const Color(0xFF2ECC89).withOpacity(0.1),
                            strokeColor: const Color(0xFF2ECC89),
                            strokeWidth: 2,
                          ),
                        }
                      : {},
                ),
                
                // Selector Mapa / Satélite
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _currentMapType = MapType.normal),
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Text('Mapa', style: GoogleFonts.inter(color: _currentMapType == MapType.normal ? Colors.blue : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                        Container(height: 1, width: 80, color: Colors.grey.shade200),
                        InkWell(
                          onTap: () => setState(() => _currentMapType = MapType.satellite),
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Text('Satélite', style: GoogleFonts.inter(color: _currentMapType == MapType.satellite ? Colors.blue : Colors.black87, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Botones de Zoom
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => mapController?.animateCamera(CameraUpdate.zoomIn()),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.add, color: Colors.black87, size: 20),
                          ),
                        ),
                        Container(height: 1, width: 40, color: Colors.grey.shade200),
                        InkWell(
                          onTap: () => mapController?.animateCamera(CameraUpdate.zoomOut()),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.remove, color: Colors.black87, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón Mi Ubicación
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: InkWell(
                    onTap: () {
                      if (currentPosition != null) {
                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(currentPosition!.latitude, currentPosition!.longitude),
                            16.0,
                          ),
                        );
                      } else {
                        _getCurrentLocation();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: const BoxDecoration(
              color: AppTheme.bgDark,
              border: Border(
                top: BorderSide(color: AppTheme.border),
                bottom: BorderSide(color: AppTheme.border),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('200m', 200.0),
                  _buildFilterChip('500m', 500.0),
                  _buildFilterChip('1km', 1000.0),
                  _buildFilterChip('5km', 5000.0),
                ],
              ),
            ),
          ),
          // Info Panel
          Container(
            width: double.infinity,
            color: AppTheme.bgDark,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mascotas cercanas', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.15),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${markers.length} en ${_getRadioText()}',
                        style: GoogleFonts.dmSans(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.border, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Última actualización', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
                    Text(_getRelativeTime(), style: GoogleFonts.dmSans(color: AppTheme.textPrimaryNew, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    // Acción para ver lista
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderLight),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.grid_view_rounded, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 7),
                        Text('Ver lista completa', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
