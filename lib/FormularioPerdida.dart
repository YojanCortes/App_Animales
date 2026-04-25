import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:appanimales/SeleccionarUbicacionEnMapa.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appanimales/theme/app_theme.dart';

class FormularioPerdida extends StatefulWidget {
  final String mascotaId;

  const FormularioPerdida({super.key, required this.mascotaId});

  @override
  _FormularioPerdidaState createState() => _FormularioPerdidaState();
}

class _FormularioPerdidaState extends State<FormularioPerdida> {
  String? horaPerdida;
  String? direccionPerdida;
  String? descripcionPerdida;
  bool agregarDireccionManualmente = false;
  LatLng? ubicacionSeleccionada;
  bool agregarRecompensa = false;
  double? cantidadRecompensa;
  DateTime? fechaPerdida;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textMuted),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reportar Pérdida', style: GoogleFonts.outfit(color: AppTheme.accent, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles del incidente', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Por favor, indica cuándo y dónde viste a tu mascota por última vez.', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            
            // Fecha y Hora
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.calendar_today_rounded,
                    label: fechaPerdida == null ? 'Fecha' : DateFormat('dd/MM/yyyy').format(fechaPerdida!),
                    onTap: () async {
                      final selectedDate = await _seleccionarFecha(context);
                      if (selectedDate != null) setState(() => fechaPerdida = selectedDate);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.access_time_rounded,
                    label: horaPerdida ?? 'Hora',
                    onTap: () async {
                      final selectedTime = await _seleccionarHora(context);
                      if (selectedTime != null) setState(() => horaPerdida = selectedTime);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ubicación
            Text('Ubicación de extravío', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            _buildCustomSwitch(
              label: 'Usar mapa para la dirección exacta',
              value: agregarDireccionManualmente,
              onChanged: (val) => setState(() => agregarDireccionManualmente = val),
            ),
            const SizedBox(height: 16),
            if (!agregarDireccionManualmente)
              _buildTextField(
                label: 'Escribe la dirección',
                icon: Icons.location_on_outlined,
                onChanged: (val) => direccionPerdida = val,
              ),
            if (agregarDireccionManualmente)
              _buildActionButton(
                icon: Icons.map_rounded,
                label: ubicacionSeleccionada == null ? 'Abrir mapa' : 'Ubicación guardada ✓',
                color: ubicacionSeleccionada == null ? AppTheme.bgDeep : AppTheme.accent.withOpacity(0.2),
                textColor: ubicacionSeleccionada == null ? Colors.white : AppTheme.accent,
                onTap: _seleccionarDireccionEnMapa,
              ),
            
            const SizedBox(height: 24),
            
            // Descripción
            Text('Información adicional', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            _buildTextField(
              label: '¿Llevaba collar? ¿Alguna seña particular?',
              icon: Icons.notes_rounded,
              maxLines: 3,
              onChanged: (val) => descripcionPerdida = val,
            ),
            const SizedBox(height: 24),

            // Recompensa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildCustomSwitch(
                    label: 'Ofrecer recompensa (Opcional)',
                    value: agregarRecompensa,
                    onChanged: (val) => setState(() => agregarRecompensa = val),
                  ),
                  if (agregarRecompensa) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Monto de recompensa (\$)',
                      icon: Icons.monetization_on_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => cantidadRecompensa = double.tryParse(val),
                    ),
                  ]
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botón Generar Alerta
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _generarAlerta,
                child: Text('Emitir Alerta S.O.S', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, Color? color, Color? textColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color ?? AppTheme.bgDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(color: textColor ?? Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSwitch({required String label, required bool value, required Function(bool) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accent,
          inactiveTrackColor: AppTheme.bgDeep,
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required IconData icon, int maxLines = 1, TextInputType? keyboardType, required Function(String) onChanged}) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
        prefixIcon: Icon(icon, color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.bgDeep,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accent)),
      ),
    );
  }

  void _seleccionarDireccionEnMapa() async {
    final LatLng? ubicacionSeleccionadaNueva = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SeleccionarUbicacionEnMapa(),
      ),
    );

    if (ubicacionSeleccionadaNueva != null) {
      setState(() {
        ubicacionSeleccionada = ubicacionSeleccionadaNueva;
      });
    }
  }

  void _generarAlerta() async {
    try {
      DocumentReference mascotaRef = FirebaseFirestore.instance.collection('mascotas').doc(widget.mascotaId);

      DocumentSnapshot mascotaSnapshot = await mascotaRef.get();
      if (mascotaSnapshot.exists) {
        if (mascotaSnapshot['perdida'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Esta mascota ya está marcada como perdida.'), backgroundColor: AppTheme.danger),
          );
        } else {
          await mascotaRef.update({
            'perdida': true,
            'horaPerdida': horaPerdida,
            'descripcionPerdida': descripcionPerdida,
            if (!agregarDireccionManualmente) 'direccionPerdida': direccionPerdida,
            if (ubicacionSeleccionada != null)
              'ubicacionPerdida': {
                'latitude': ubicacionSeleccionada!.latitude,
                'longitude': ubicacionSeleccionada!.longitude,
              },
            'recompensa': agregarRecompensa ? cantidadRecompensa : null,
            'fechaPerdida': fechaPerdida != null ? DateFormat('yyyy-MM-dd').format(fechaPerdida!) : null,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alerta S.O.S generada correctamente.'), backgroundColor: AppTheme.accent),
          );

          Navigator.pop(context);
        }
      }
    } catch (error) {
      print('Error al generar la alerta: $error');
    }
  }

  Future<DateTime?> _seleccionarFecha(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              onPrimary: Colors.white,
              surface: AppTheme.bgDeep,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<String?> _seleccionarHora(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              surface: AppTheme.bgDeep,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      return selectedTime.format(context);
    }
    return null;
  }
}

