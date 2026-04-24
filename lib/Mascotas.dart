import 'package:appanimales/DetallesAnimalesPerdios.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:appanimales/theme/app_theme.dart';

class MascotasPage extends StatefulWidget {
  const MascotasPage({super.key});

  @override
  _MascotasPageState createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  int _selectedTab = 0; // 0: Cerca de mí, 1: Perdidos, 2: Avistados, 3: Encontrados

  Stream<QuerySnapshot> _buildStream() {
    return FirebaseFirestore.instance
        .collection('mascotas')
        .orderBy('fechaPerdida', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopHeader()),
            SliverToBoxAdapter(child: _buildTabs()),
            SliverToBoxAdapter(child: _buildAlertasUrgentes()),
            
            StreamBuilder<QuerySnapshot>(
              stream: _buildStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(child: _buildShimmerList());
                }

                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Error al cargar datos', style: TextStyle(color: Colors.red)),
                    )),
                  );
                }

                List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
                
                // Filtrar según la pestaña (Simulado para demostración)
                if (_selectedTab == 1) {
                  docs = docs.where((d) => (d.data() as Map)['perdida'] == true).toList();
                } else if (_selectedTab == 3) {
                  docs = docs.where((d) => (d.data() as Map)['perdida'] == false).toList();
                }

                if (docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text('No hay mascotas en esta categoría', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PremiumPetCard(doc: docs[index]),
                    childCount: docs.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Margen inferior
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PetFind', style: GoogleFonts.outfit(color: AppTheme.accent, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Santiago · 14 alertas activas', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppTheme.textMuted),
                  Positioned(
                    right: 2, top: 2, 
                    child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle))
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Icon(Icons.search_rounded, color: AppTheme.textMuted),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Cerca de mí', 'Perdidos', 'Avistados', 'Encontrados'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isSelected ? AppTheme.accent : Colors.transparent, width: 2)),
              ),
              child: Text(
                tabs[index], 
                style: GoogleFonts.inter(
                  color: isSelected ? AppTheme.accent : AppTheme.textMuted, 
                  fontSize: 13, 
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400
                )
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAlertasUrgentes() {
    final alertas = [
      {'nombre': 'Rocky', 'tiempo': '1h', 'color': AppTheme.danger, 'img': 'assets/perro.jpeg'},
      {'nombre': 'Misi', 'tiempo': '2h', 'color': AppTheme.danger, 'img': 'assets/gato.jpeg'},
      {'nombre': 'Coco', 'tiempo': 'hallado', 'color': AppTheme.accent, 'img': 'assets/perro.jpeg'},
      {'nombre': 'Bunny', 'tiempo': '5h', 'color': AppTheme.danger, 'img': 'assets/gato.jpeg'},
      {'nombre': 'Thor', 'tiempo': '6h', 'color': AppTheme.danger, 'img': 'assets/perro.jpeg'},
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('Alertas urgentes — últimas 6 horas', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: alertas.length,
              itemBuilder: (context, index) {
                final alerta = alertas[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 62, height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: alerta['color'] as Color, width: 2),
                          image: DecorationImage(image: AssetImage(alerta['img'] as String), fit: BoxFit.cover),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: Text(alerta['tiempo'] as String, style: GoogleFonts.inter(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(alerta['nombre'] as String, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppTheme.bgDeep,
      highlightColor: AppTheme.border,
      child: Column(
        children: List.generate(3, (index) => Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        )),
      ),
    );
  }
}

class _PremiumPetCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  
  const _PremiumPetCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final nombre = data['nombre'] as String? ?? 'Sin nombre';
    final raza = data['raza'] as String? ?? 'Desconocida';
    final tipo = data['tipo'] as String? ?? 'Mascota';
    final perdida = data['perdida'] as bool? ?? true;
    final ubicacion = data['ultimaDireccionVista'] as String? ?? 'Desconocida';
    final imageUrl = data['imagen'] as String? ?? '';
    final recompensa = data['recompensa'] != null ? (data['recompensa'] as num).toDouble() : 0.0;
    final descripcion = data['descripcion'] as String? ?? '';
    final nombreUsuario = data['nombreUsuario'] as String? ?? 'Dueño';

    final Color statusColor = perdida ? AppTheme.danger : AppTheme.accent;
    final String statusText = perdida ? 'PERDIDO' : 'ENCONTRADA';
    final String statusDesc = perdida ? 'Perdido · hace poco' : 'Encontrada · esperando dueño';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgDeep, // Un tono ligeramente más claro que bgDark
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : const AssetImage('assets/perro.jpeg') as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$nombre — $raza', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(statusDesc, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(perdida ? 'Lo vi' : 'Es mía', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          
          // Imagen Principal
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF131A15),
              image: DecorationImage(
                image: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : const AssetImage('assets/perro.jpeg') as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.5))),
                    child: Text(statusText, style: GoogleFonts.inter(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(ubicacion.split(',')[0], style: GoogleFonts.inter(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                // Gradiente inferior
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12, left: 16, right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(tipo, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('1.2 km', 'de ti'),
                Container(width: 1, height: 30, color: AppTheme.border),
                _buildStat('3', 'avistamientos'),
                Container(width: 1, height: 30, color: AppTheme.border),
                _buildStat('47', 'compartidos'),
              ],
            ),
          ),
          
          // Recompensa
          if (recompensa > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2C220E),
                border: Border.all(color: const Color(0xFFD49E34).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFD49E34), size: 18),
                  const SizedBox(width: 8),
                  Text('Recompensa', style: GoogleFonts.inter(color: const Color(0xFFD49E34), fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Text('\$${recompensa.toStringAsFixed(0)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white, side: const BorderSide(color: AppTheme.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Contactar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white, side: const BorderSide(color: AppTheme.borderLight),
                      padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Comentarios / Descripción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
                    children: [
                      TextSpan(text: '$nombreUsuario: ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      TextSpan(text: descripcion.isNotEmpty ? descripcion : '"Se perdió ayer cerca del parque. Por favor ayúdenme a encontrarlo."'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: statusColor, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Último avistamiento: ${ubicacion}, hace poco', style: GoogleFonts.inter(color: AppTheme.accent, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}
