import 'package:appanimales/AdopcionLista.dart';
import 'package:appanimales/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AgregarMascota.dart';
import 'EditarPerfil.dart';
import 'FormularioAdopcion.dart';
import 'GoogleMap.dart';
import 'Mascotas.dart';
import 'Alertas.dart';
import 'Adoptados.dart';
import 'MiAdopcionLista.dart';
import 'MisMascotas.dart';
import 'package:appanimales/theme/app_theme.dart';

class MenuPage extends StatefulWidget {
  final User? user;

  const MenuPage({super.key, required this.user});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String nombreUsuario = '';
  String telefono = '';
  String direccion = '';
  String nombreCompleto = '';
  String _currentTab = 'Mapa';

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.home_outlined, label: 'Inicio'),
    _TabItem(icon: Icons.my_location_rounded, label: 'Mapa'),
    _TabItem(icon: Icons.add, label: ''),
    _TabItem(icon: Icons.maps_home_work_outlined, label: 'Adoptados'),
    _TabItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  void initState() {
    super.initState();
    // Inicia en la pestaña "Mapa" (índice 1) como en la maqueta
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _currentTab = _tabs[_tabController.index].label);
        }
      });
    _currentTab = _tabs[1].label;
    _cargarInformacionUsuario();
    _checkAndRequestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ... (keeping other methods same, redefining them for safety)
  Future<void> _cargarInformacionUsuario() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user?.uid)
          .get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            nombreUsuario = data['nombreUsuario'] ?? '';
            nombreCompleto = data['nombreCompleto'] ?? '';
            telefono = data['telefono'] ?? '';
            direccion = data['direccion'] ?? '';
          });
        }
      }
    } catch (error) {
      debugPrint('Error al cargar usuario: $error');
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    await _checkAndRequestLocationPermissions();
    await _checkAndRequestNotificationPermissions();
  }

  Future<void> _checkAndRequestLocationPermissions() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        await _getCurrentLocation();
      }
    }
  }

  Future<void> _checkAndRequestNotificationPermissions() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      debugPrint(
          'Ubicación: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const MascotasPage();
      case 1:
        return GoogleMapPage(initialPosition: const LatLng(-33.0458, -71.6197));
      case 3:
        return const AdoptadosPage();
      case 4:
        return const ListaAnimalesAdopcion();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cerrar sesión',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text('¿Estás seguro de que deseas salir?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  void _navigate(Widget page) {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = nombreCompleto.isNotEmpty
        ? nombreCompleto
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0] : '')
            .join()
            .toUpperCase()
        : (widget.user?.email?.substring(0, 1).toUpperCase() ?? '?');

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar
            Container(
              color: AppTheme.bgDark,
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              border: Border.all(color: AppTheme.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.menu_rounded, color: AppTheme.textMuted, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Mapa', style: GoogleFonts.dmSans(color: AppTheme.textPrimaryNew, fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MisMascotasPage(seleccionarPerdida: true)),
                    ),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerBg,
                        border: Border.all(color: AppTheme.dangerBorder),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.45, end: 1.0),
                            duration: const Duration(seconds: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: 0.85 + (0.15 * ((value - 0.45) / 0.55)),
                                  child: child,
                                ),
                              );
                            },
                            onEnd: () {}, 
                            child: Container(
                              width: 7, height: 7,
                              decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Perdí mi mascota',
                            style: GoogleFonts.dmSans(
                                color: AppTheme.danger,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage(0),
                  _buildPage(1),
                  const SizedBox.shrink(),
                  _buildPage(3),
                  _buildPage(4),
                ],
              ),
            ),
            
            // Custom Bottom Nav
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.bgDeep,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              padding: const EdgeInsets.only(top: 10, bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabs.length, (index) {
                  final t = _tabs[index];
                  
                  if (index == 2) {
                    return GestureDetector(
                      onTap: () => _navigate(AgregarMascotaPage()),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: AppTheme.accent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: AppTheme.accent, size: 24),
                      ),
                    );
                  }

                  final isSelected = _tabController.index == index;
                  final color = isSelected ? AppTheme.accent : AppTheme.textFaint;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _tabController.animateTo(index);
                      setState(() => _currentTab = t.label);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, color: color, size: 24),
                        const SizedBox(height: 3),
                        Text(t.label, style: GoogleFonts.dmSans(color: color, fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                        if (isSelected) ...[
                          const SizedBox(height: 1),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
                        ] else const SizedBox(height: 5),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Header del drawer
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D5C3A), Color(0xFF2ECC89)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar con iniciales
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nombreCompleto.isNotEmpty
                        ? nombreCompleto
                        : 'Usuario',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (nombreUsuario.isNotEmpty)
                    Text(
                      '@$nombreUsuario',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  if (widget.user?.email != null)
                    Text(
                      widget.user!.email!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                ],
              ),
            ),

            // Opciones del menú
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerTile(
                    icon: Icons.person_outline,
                    label: 'Mi Perfil',
                    onTap: () => _navigate(EditarPerfilPage(
                      nombreUsuarioActual: nombreUsuario,
                      nombreCompletoActual: nombreCompleto,
                      correoActual: widget.user?.email ?? '',
                      telefonoActual: telefono,
                      direccionActual: direccion,
                    )),
                  ),
                  _DrawerTile(
                    icon: Icons.pets_rounded,
                    label: 'Agregar Mascota',
                    onTap: () => _navigate(AgregarMascotaPage()),
                  ),
                  _DrawerTile(
                    icon: Icons.list_alt_rounded,
                    label: 'Mis Mascotas',
                    onTap: () => _navigate(
                        MisMascotasPage(seleccionarPerdida: false)),
                  ),
                  _DrawerTile(
                    icon: Icons.volunteer_activism_rounded,
                    label: 'Poner en Adopción',
                    onTap: () => _navigate(FormularioAdopcion()),
                  ),
                  _DrawerTile(
                    icon: Icons.favorite_rounded,
                    label: 'Mi Lista de Adopción',
                    onTap: () => _navigate(MiAdopcionLista()),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _DrawerTile(
                    icon: Icons.sentiment_very_dissatisfied_rounded,
                    label: 'Perdí mi Mascota',
                    onTap: () => _navigate(
                        MisMascotasPage(seleccionarPerdida: true)),
                    color: colorScheme.secondary,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _DrawerTile(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar Sesión',
                    onTap: () {
                      Navigator.pop(context);
                      _cerrarSesion();
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            // Footer versión
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'PetFinder v2.0',
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 22),
      ),
      title: Text(label,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w500, fontSize: 15)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
