import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'editarMascota.dart';
import 'formularioPerdida.dart';

class MisMascotasPage extends StatefulWidget {
  final bool seleccionarPerdida;

  const MisMascotasPage({super.key, required this.seleccionarPerdida});

  @override
  _MisMascotasPageState createState() => _MisMascotasPageState();
}

class _MisMascotasPageState extends State<MisMascotasPage> {
  final Color bgDark = const Color(0xFF0A0F0D);
  final Color cardBg = const Color(0xFF121A16);
  final Color greenAccent = const Color(0xFF00D287);
  final Color redAccent = const Color(0xFFFF6B6B);
  final Color purpleAccent = const Color(0xFF9872FF);

  String _filtro = 'Todas'; // Todas, En casa, Perdida, Adopción

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('mascotas')
              .where('idUsuario', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var mascotas = snapshot.data?.docs ?? [];
            int total = mascotas.length;
            int perdidas = mascotas.where((m) => (m.data() as Map)['perdida'] == true).toList().length;
            int enCasa = mascotas.where((m) => (m.data() as Map)['perdida'] == false).toList().length;
            // Si tuvieras un campo 'enAdopcion', lo contaríamos aquí. Por ahora, mockeamos 0 o calculamos si existe.
            int adopcion = mascotas.where((m) => (m.data() as Map)['enAdopcion'] == true).toList().length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildProfileCard(total, enCasa, perdidas, adopcion)),
                SliverToBoxAdapter(child: _buildFilters(total, enCasa, perdidas, adopcion)),
                SliverToBoxAdapter(child: _buildSubHeader()),
                _buildMascotasList(mascotas),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (Navigator.canPop(context))
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                  ),
                )
              else
                Builder(
                  builder: (context) => InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_rounded, color: Colors.white),
                    ),
                  ),
                ),
              Text('Mis mascotas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          InkWell(
            onTap: () {
               Navigator.pushNamed(context, '/agregarMascota');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('Agregar', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(int total, int enCasa, int perdidas, int adopcion) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).get(),
      builder: (context, snapshot) {
        String nombre = 'Usuario';
        String ubicacion = 'Santiago';

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          nombre = data['nombreCompleto'] ?? data['nombreUsuario'] ?? 'Usuario';
          ubicacion = data['direccion'] ?? 'Santiago';
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: greenAccent, width: 2),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 12),
                        const SizedBox(width: 4),
                        Expanded(child: Text(ubicacion, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('$total', 'mascotas', Colors.white),
                        _buildStat('$enCasa', 'en casa', greenAccent),
                        _buildStat('$perdidas', 'perdida', redAccent),
                        _buildStat('0', 'ayudas', Colors.orange), // Hardcode por ahora
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.inter(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildFilters(int total, int enCasa, int perdidas, int adopcion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterBox('$total', 'Todas', greenAccent, _filtro == 'Todas'),
          _buildFilterBox('$enCasa', 'En casa', Colors.white, _filtro == 'En casa'),
          _buildFilterBox('$perdidas', 'Perdida', redAccent, _filtro == 'Perdida'),
          _buildFilterBox('$adopcion', 'Adopción', purpleAccent, _filtro == 'Adopción'),
        ],
      ),
    );
  }

  Widget _buildFilterBox(String count, String label, Color color, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _filtro = label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(count, style: GoogleFonts.outfit(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(color: isSelected ? color : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Todas las mascotas', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: greenAccent, borderRadius: BorderRadius.circular(20)),
                child: Text('Todas', style: GoogleFonts.inter(color: bgDark, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Activas', style: GoogleFonts.inter(color: Colors.grey, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMascotasList(List<DocumentSnapshot> mascotas) {
    // Client-side filtering
    if (_filtro == 'Perdida') {
      mascotas = mascotas.where((m) => (m.data() as Map)['perdida'] == true).toList();
    } else if (_filtro == 'En casa') {
      mascotas = mascotas.where((m) => (m.data() as Map)['perdida'] == false).toList();
    } else if (_filtro == 'Adopción') {
      mascotas = mascotas.where((m) => (m.data() as Map)['enAdopcion'] == true).toList();
    }

    if (mascotas.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: Text('No tienes mascotas en esta categoría.', style: GoogleFonts.inter(color: Colors.grey))),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var mascota = mascotas[index];
          return _buildMascotaCard(mascota);
        },
        childCount: mascotas.length,
      ),
    );
  }

  Widget _buildMascotaCard(DocumentSnapshot mascota) {
    var data = mascota.data() as Map<String, dynamic>;
    var nombre = data['nombre'] ?? 'Sin nombre';
    var tipo = data['tipo'] ?? 'Perro';
    var raza = data['raza'] ?? 'Desconocida';
    var edad = data['edad'] ?? 'Desconocida';
    var perdida = data['perdida'] ?? false;
    var imagenUrl = data['imagen'] as String?;

    Color bgColor = cardBg;
    Color statusColor = greenAccent;
    String statusText = 'En casa';
    String statusDot = 'En casa · Vacunada · Esterilizada';
    
    if (perdida) {
      bgColor = const Color(0xFF241515);
      statusColor = redAccent;
      statusText = 'PERDIDO';
      statusDot = 'Perdido · 3 avistamientos · 1.2km';
    } else if (tipo.toLowerCase() == 'gato') {
      bgColor = const Color(0xFF141F1A);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Box
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: imagenUrl != null && imagenUrl.isNotEmpty
                          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(imagenUrl, width: 80, height: 80, fit: BoxFit.cover))
                          : Icon(tipo == 'Perro' ? Icons.pets : Icons.catching_pokemon, color: Colors.amber, size: 40),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                        ),
                        child: Text(statusText, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(nombre, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(perdida ? 'hace 1h' : 'seguro', style: GoogleFonts.inter(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Text('$raza · $tipo · $edad', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(statusDot, style: GoogleFonts.inter(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    if (perdida) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('47 compartidos', style: GoogleFonts.inter(color: Colors.white, fontSize: 10)),
                          const SizedBox(width: 10),
                          Text('3 avistamientos', style: GoogleFonts.inter(color: greenAccent, fontSize: 10)),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (perdida) {
                       // Ver en mapa
                    } else {
                       // Editar perfil
                       Navigator.push(context, MaterialPageRoute(builder: (context) => EditarMascotaPage(mascota: mascota)));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: perdida ? Colors.orange : greenAccent, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(perdida ? 'Ver en mapa' : 'Editar perfil', textAlign: TextAlign.center, style: GoogleFonts.inter(color: perdida ? Colors.orange : greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (perdida) {
                       _marcarComoNoPerdida(mascota.id);
                    } else {
                       _irAFormularioPerdida(mascota.id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: redAccent, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(perdida ? 'Actualizar alerta' : 'Reportar perdida', textAlign: TextAlign.center, style: GoogleFonts.inter(color: redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _mostrarDialogoOpciones(mascota),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoOpciones(DocumentSnapshot mascota) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: Text('Editar Mascota', style: GoogleFonts.inter(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditarMascotaPage(mascota: mascota)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar Mascota', style: GoogleFonts.inter(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarDialogoConfirmacion(mascota);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _mostrarDialogoConfirmacion(DocumentSnapshot mascota) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBg,
          title: Text('Eliminar Mascota', style: GoogleFonts.outfit(color: Colors.white)),
          content: Text('¿Estás seguro de que quieres eliminar esta mascota?', style: GoogleFonts.inter(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _eliminarMascota(mascota.id);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _eliminarMascota(String mascotaId) {
    FirebaseFirestore.instance.collection('mascotas').doc(mascotaId).delete();
  }

  void _irAFormularioPerdida(String mascotaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioPerdida(mascotaId: mascotaId),
      ),
    );
  }

  void _marcarComoNoPerdida(String mascotaId) {
    FirebaseFirestore.instance
        .collection('mascotas')
        .doc(mascotaId)
        .update({'perdida': false});
  }
}
