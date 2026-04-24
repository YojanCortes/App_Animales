import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaGoogleUnico extends StatelessWidget {
  final LatLng ubicacion;

  const MapaGoogleUnico({super.key, required this.ubicacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: ubicacion,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('UbicacionUnica'),
            position: ubicacion,
          ),
        },
      ),
    );
  }
}
