import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Alertas.dart';

class AdoptadosPage extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const AdoptadosPage({super.key, this.onMenuTap});

  @override
  _AdoptadosPageState createState() => _AdoptadosPageState();
}

class _AdoptadosPageState extends State<AdoptadosPage> {
  final Color bgDark = const Color(0xFF0D0A14);
  final Color cardBg = const Color(0xFF1A1423);
  final Color primaryPurple = const Color(0xFF9872FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildRefugiosHeader()),
            SliverToBoxAdapter(child: _buildRefugiosList()),
            SliverToBoxAdapter(child: _buildFeatured()),
            SliverToBoxAdapter(child: _buildGridHeader()),
            _buildGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: widget.onMenuTap ?? () {},
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_rounded, color: Colors.grey, size: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.maps_home_work_rounded, color: primaryPurple, size: 24),
              ),
              const SizedBox(width: 12),
              Text('Adoptados', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertasPage()));
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.grey, size: 28),
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Color(0xFFFF5656), shape: BoxShape.circle),
                    child: const Text('5', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Raza, color, zona, edad...',
                  hintStyle: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_list_rounded, color: Colors.grey, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.pets, 'count': '142', 'active': true},
      {'icon': Icons.pets_outlined, 'count': '67', 'active': false},
      {'icon': Icons.cruelty_free_rounded, 'count': '18', 'active': false},
      {'icon': Icons.flutter_dash_rounded, 'count': '11', 'active': false},
      {'icon': Icons.pets_rounded, 'count': '10', 'active': false},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat['active'] as bool;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: isActive ? primaryPurple : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isActive ? primaryPurple : Colors.white.withOpacity(0.05)),
                  ),
                  child: Icon(cat['icon'] as IconData, color: isActive ? bgDark : Colors.amber, size: 28),
                ),
                const SizedBox(height: 6),
                Text(cat['count'] as String, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatured() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF26183A), // Púrpura oscuro para el destacado
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0, bottom: 0, top: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset('assets/perro.jpeg', width: 160, fit: BoxFit.cover), // Reemplazar con imagen transparente si se tiene
            ),
          ),
          // Gradiente para oscurecer la imagen y fusionarla
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [const Color(0xFF26183A), const Color(0xFF26183A).withOpacity(0.1)],
                begin: Alignment.centerLeft, end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(text: '8 meses esperando', color: const Color(0xFFFF6B6B)),
                    const SizedBox(width: 8),
                    _Badge(text: 'Vacunado', color: const Color(0xFF00D287)),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Bruno', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Macho · 3 años · Labrador cruzado', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFF00D287), size: 12),
                          const SizedBox(width: 4),
                          Expanded(child: Text('Refugio Huellas · 1.4km', style: GoogleFonts.inter(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20, right: 20,
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Quiero\nadoptarlo', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Cerca de ti · 142', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              Text('Más urgentes', style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final items = [
      {'nombre': 'Luna', 'raza': 'Hembra · 1 año', 'distancia': '0.8km', 'badge': 'NUEVO', 'tags': ['Castrada', 'Tranquila']},
      {'nombre': 'Thor', 'raza': 'Macho · 4 años', 'distancia': '1.2km', 'tags': ['Juguetón', 'Con niños']},
      {'nombre': 'Sombra', 'raza': 'Hembra · 5 años', 'distancia': '3km', 'badge': 'URGENTE', 'badgeColor': const Color(0xFFFF6B6B), 'tags': ['Vacunada']},
      {'nombre': 'Copito', 'raza': 'Macho · 2 años', 'distancia': '2.1km', 'badge': 'NUEVO', 'tags': ['Sano', 'Dócil']},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            final badge = item['badge'] as String?;
            final badgeColor = item['badgeColor'] as Color? ?? primaryPurple;
            final tags = item['tags'] as List<String>;

            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF131A15),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: const Center(child: Icon(Icons.pets, color: Colors.amber, size: 60)), // Placeholder
                        ),
                        if (badge != null)
                          Positioned(
                            top: 10, left: 10,
                            child: _Badge(text: badge, color: badgeColor),
                          ),
                        Positioned(
                          top: 10, right: 10,
                          child: Icon(Icons.bookmark_border_rounded, color: Colors.white.withOpacity(0.7), size: 20),
                        ),
                      ],
                    ),
                  ),
                  // Info
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['nombre'] as String, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(item['raza'] as String, style: GoogleFonts.inter(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4, runSpacing: 4,
                            children: tags.map((t) => _Tag(text: t, isPurple: t == 'Tranquila')).toList(),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.grey, size: 12),
                                    const SizedBox(width: 2),
                                    Flexible(child: Text(item['distancia'] as String, style: GoogleFonts.inter(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryPurple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: primaryPurple.withOpacity(0.5)),
                                  ),
                                  child: Text('Ver', style: GoogleFonts.inter(color: primaryPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildRefugiosHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Refugios', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Ver todos →', style: GoogleFonts.inter(color: primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRefugiosList() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(isFirst ? Icons.maps_home_work_rounded : Icons.pets, color: isFirst ? primaryPurple : Colors.orange, size: 24),
                ),
                const Spacer(),
                Text(isFirst ? 'Refugio Huellas' : 'Patitas Felices', style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
                Text(isFirst ? '42 animales' : '28 animales', style: GoogleFonts.inter(color: primaryPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(isFirst ? '1.4 km' : '2.8 km', style: GoogleFonts.inter(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF00D287).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Color(0xFF00D287), size: 10),
                      const SizedBox(width: 2),
                      Text('Verificado', style: GoogleFonts.inter(color: Color(0xFF00D287), fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool isPurple;
  const _Tag({required this.text, this.isPurple = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPurple ? const Color(0xFF9872FF).withOpacity(0.2) : const Color(0xFF00D287).withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isPurple ? const Color(0xFF9872FF).withOpacity(0.3) : const Color(0xFF00D287).withOpacity(0.3)),
      ),
      child: Text(text, style: GoogleFonts.inter(color: isPurple ? const Color(0xFF9872FF) : const Color(0xFF00D287), fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
